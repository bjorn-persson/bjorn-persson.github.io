---
title: "Simpson's Paradox"
description: "Interactive scatterplot demonstrating how an overall negative correlation can reverse into positive within-group correlations when data is grouped. Drag the grouping slider to watch the paradox unfold."
summary: "Watch a global negative trend shatter into positive within-group trends as you reveal hidden group structure — a live demonstration of Simpson's Paradox."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');

.sp-wrap { font-family: 'IBM Plex Mono', monospace; }
.sp-subtitle {
  font-size: 0.78rem;
  color: var(--secondary);
  margin-bottom: 18px;
  line-height: 1.6;
}
.sp-controls {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 16px;
  font-size: 0.78rem;
}
.sp-control-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.sp-control-group label {
  color: var(--secondary);
  font-size: 0.72rem;
}
.sp-val { color: #0d8a74; font-weight: 600; }
.sp-controls input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: #e0e0ec;
  border-radius: 2px;
  outline: none;
  cursor: pointer;
}
.sp-controls input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
}
.sp-controls input[type="range"]::-moz-range-thumb {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
  border: none;
}
.sp-canvas-wrap canvas {
  display: block;
  width: 100%;
  aspect-ratio: 4 / 3;
  border-radius: 6px;
  background: #f4f4f8;
}
.sp-readout {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 20px;
  margin-top: 12px;
  font-size: 0.72rem;
}
.sp-badge {
  padding: 3px 10px;
  border-radius: 4px;
  background: #f0f0f8;
  border: 1px solid #e0e0ec;
  color: var(--secondary);
}
.sp-badge .sp-badge-val { font-weight: 600; }
.sp-note {
  margin-top: 12px;
  font-size: 0.68rem;
  color: var(--secondary);
  line-height: 1.6;
}
.sp-phase-label {
  margin-bottom: 10px;
  font-size: 0.8rem;
  color: #0d8a74;
  font-weight: 600;
  min-height: 1.2em;
}
</style>

<div class="sp-wrap">
  <p class="sp-subtitle">
    A dataset shows a clear <em>negative</em> overall correlation between study hours and exam score — until you account for academic major. Drag the slider to reveal the hidden group structure. Each major shows a <em>positive</em> within-group correlation, reversing the overall trend.
  </p>
  <div class="sp-controls">
    <div class="sp-control-group">
      <label>Group by Academic Major: <span class="sp-val" id="sp_mix_val">0%</span></label>
      <input type="range" id="sp_mix" min="0" max="1" step="0.01" value="0">
    </div>
  </div>
  <div class="sp-phase-label" id="sp_phase">Overall view: one aggregate group</div>
  <div class="sp-canvas-wrap">
    <canvas id="sp_canvas"></canvas>
  </div>
  <div class="sp-readout">
    <div class="sp-badge">Overall r: <span class="sp-badge-val" id="sp_overall_r" style="color:#c83c5a">—</span></div>
    <div class="sp-badge" id="sp_g1_badge" style="display:none">Major A r: <span class="sp-badge-val" id="sp_g1_r"></span></div>
    <div class="sp-badge" id="sp_g2_badge" style="display:none">Major B r: <span class="sp-badge-val" id="sp_g2_r"></span></div>
    <div class="sp-badge" id="sp_g3_badge" style="display:none">Major C r: <span class="sp-badge-val" id="sp_g3_r"></span></div>
    <div class="sp-badge" id="sp_g4_badge" style="display:none">Major D r: <span class="sp-badge-val" id="sp_g4_r"></span></div>
    <div class="sp-badge" id="sp_g5_badge" style="display:none">Major E r: <span class="sp-badge-val" id="sp_g5_r"></span></div>
  </div>
  <p class="sp-note">
    This is Simpson's Paradox: an association that holds in each subgroup can reverse (or vanish) in the aggregate.<br>
    The mechanism here: harder majors require more study hours yet produce lower average scores (confound). Within each major, more studying does improve scores — but the major-level confound overwhelms this within-group effect in the aggregate.<br>
    Named after Edward H. Simpson (1951), though the phenomenon was noted earlier by Yule (1903).
  </p>
</div>

<script>
(function () {
  const canvas = document.getElementById('sp_canvas');
  const ctx = canvas.getContext('2d');
  let dpr = window.devicePixelRatio || 1;

  // Group definitions: [centerX, centerY, withinSlope, color, name]
  // X = study hours (0-1), Y = depression (0-1)
  // Groups are arranged so that overall: high study → high depression (confound by major stress level)
  // Within each group: more study → lower depression (positive slope actually)
  // We'll use: X = study hours normalized, Y = depression normalized
  // Group centers arranged from bottom-left to top-right (low stress → high stress majors)
  const GROUP_DEFS = [
    { cx: 0.15, cy: 0.18, slope:  0.38, sigma: 0.07, color: '#0d8a74',  name: 'Education'      },
    { cx: 0.32, cy: 0.35, slope:  0.35, sigma: 0.07, color: '#6d28d9',  name: 'Social Science' },
    { cx: 0.50, cy: 0.50, slope:  0.32, sigma: 0.07, color: '#c2640a',  name: 'Business'       },
    { cx: 0.68, cy: 0.65, slope:  0.30, sigma: 0.07, color: '#c83c5a',  name: 'Engineering'    },
    { cx: 0.84, cy: 0.80, slope:  0.28, sigma: 0.07, color: '#1565c0',  name: 'Medicine'       },
  ];

  const N_PER_GROUP = 28;
  const SEED_BASE = 99;

  function makeRng(seed) {
    let s = seed >>> 0;
    return function () {
      s += 0x6D2B79F5;
      let t = s;
      t = Math.imul(t ^ (t >>> 15), t | 1);
      t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }

  function randn(rng) {
    let u, v, s;
    do { u = rng()*2-1; v = rng()*2-1; s = u*u+v*v; } while (s >= 1 || s === 0);
    return u * Math.sqrt(-2 * Math.log(s) / s);
  }

  function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)); }

  // Generate raw group data
  const groups = GROUP_DEFS.map((g, gi) => {
    const rng = makeRng(SEED_BASE + gi * 17);
    const pts = [];
    for (let i = 0; i < N_PER_GROUP; i++) {
      const dx = randn(rng) * g.sigma;
      const dy = g.slope * dx + randn(rng) * g.sigma * 0.55;
      pts.push({
        gx: clamp(g.cx + dx, 0.02, 0.98),
        gy: clamp(g.cy + dy, 0.02, 0.98),
        // Blended position towards aggregate blob for t=0
        // At t=0 all points collapse to a single spread showing overall -r
        group: gi
      });
    }
    return { ...g, pts };
  });

  // Aggregate cloud: a single blob with overall negative correlation
  // We'll compute the "aggregate" position of each point as: position on the overall negative line
  // overall: high study (right) = high depression (top) — confound drives this
  // We want overall r ≈ -0.55 between study hours and depression, but this is the AGGREGATE pattern
  // Actually: the aggregate SHOULD show that groups cluster from bottom-left to top-right
  // meaning: more hours overall → higher depression (because medicine students do both more)
  // So overall r is POSITIVE (not negative as originally described — let me reconsider)
  //
  // Standard Simpson's Paradox setup for this domain:
  // Overall: negative r (more study → less depression, naive conclusion)
  // Within groups: actually depends on confound direction
  //
  // Let's do the classic:
  // Overall negative: more study hours → lower depression scores
  // But when you split by major: each major shows POSITIVE within-group relationship
  //   (within a major, students who study more are actually MORE stressed/depressed)
  // The confound: easy majors have low hours AND high well-being; hard majors have high hours AND low well-being
  // Wait, that gives overall: hard major → more hours + lower well-being → overall positive r between hours and depression
  //
  // Let me flip to make it work cleanly:
  // Y axis: "Exam Score" (not depression)
  // Easy majors: low study hours, high scores (natural talent + easy material)
  // Hard majors: high study hours, lower scores (despite effort, material is hard)
  // Overall: more hours → lower score (negative overall r)
  // Within group: more hours → higher score (positive within-group r)
  // This is the classic and intuitive version.

  // Actually let me keep it as the description says. Let me restate:
  // Overall negative r: high hours → lower depression (looks like studying helps)
  // Groups: Education (low hours, low depression), Medicine (high hours, high depression)
  // Within each group: more hours within that major → higher depression (positive r)
  // The confound is major stress level.
  // So at t=0, blob shows negative overall r.
  // At t=1, groups separate and each shows positive within-group r.

  // Recompute group positions to achieve this:
  // Group centers from top-left to bottom-right for overall NEGATIVE r
  // Education: low hours (left), low depression (bottom)
  // Medicine: high hours (right), high depression (top)
  // Overall cloud: negative r (more hours → less depression) — WAIT this is positive r (top-right is high depression)
  //
  // For overall NEGATIVE r between study hours (X) and depression (Y):
  // We need: right side (high hours) → bottom (low depression)
  // Groups should be arranged: high-hours groups have low depression
  // That doesn't match the "medicine stress" narrative.
  //
  // Let me just implement it accurately: X = hours, Y = exam score
  // Overall: high hours → low score (negative r) — seems counterintuitive
  // Within each major: high hours → high score (positive r)
  // Confound: hard majors force more studying but have lower average scores
  // This is the clean classic example.

  // I'll redefine GROUP_DEFS inline with the data generation for this setup.

  const GP = [
    { cx: 0.18, cy: 0.80, slope: 0.40, sigma: 0.065, color: '#0d8a74',  name: 'Education',       label: 'A' },
    { cx: 0.34, cy: 0.65, slope: 0.38, sigma: 0.065, color: '#6d28d9',  name: 'Social Sciences', label: 'B' },
    { cx: 0.50, cy: 0.50, slope: 0.36, sigma: 0.065, color: '#c2640a',  name: 'Business',        label: 'C' },
    { cx: 0.66, cy: 0.35, slope: 0.34, sigma: 0.065, color: '#c83c5a',  name: 'Engineering',     label: 'D' },
    { cx: 0.82, cy: 0.20, slope: 0.32, sigma: 0.065, color: '#1565c0',  name: 'Medicine',        label: 'E' },
  ];
  // X = study hours (0=low, 1=high), Y = exam score (0=low, 1=high)
  // Groups from top-right to bottom-left:
  // Education: low hours, high scores (easy major + talented students)
  // Medicine: high hours, low scores (hard major, despite effort)
  // Overall r is negative (more hours → lower score due to confound)
  // Within each group: more hours → higher score (positive r)

  const allGroups = GP.map((g, gi) => {
    const rng = makeRng(SEED_BASE + gi * 31 + 7);
    const pts = [];
    for (let i = 0; i < N_PER_GROUP; i++) {
      const dx = randn(rng) * g.sigma;
      const dy = g.slope * dx + randn(rng) * g.sigma * 0.5;
      pts.push({
        gx: clamp(g.cx + dx, 0.02, 0.98),
        gy: clamp(g.cy + dy, 0.02, 0.98),
        group: gi
      });
    }
    return { ...g, pts };
  });

  const PAD_L = 48, PAD_R = 16, PAD_T = 16, PAD_B = 38;

  function pearsonR(pts) {
    const n = pts.length;
    if (n < 3) return 0;
    let sx = 0, sy = 0, sxx = 0, syy = 0, sxy = 0;
    for (const p of pts) { sx += p.x; sy += p.y; sxx += p.x*p.x; syy += p.y*p.y; sxy += p.x*p.y; }
    const num = n*sxy - sx*sy;
    const den = Math.sqrt((n*sxx - sx*sx) * (n*syy - sy*sy));
    return den < 1e-12 ? 0 : num/den;
  }

  function linReg(pts) {
    const n = pts.length;
    if (n < 2) return { m: 0, b: 0.5 };
    let sx = 0, sy = 0, sxx = 0, sxy = 0;
    for (const p of pts) { sx += p.x; sy += p.y; sxx += p.x*p.x; sxy += p.x*p.y; }
    const mx = sx/n, my = sy/n;
    const ssxx = sxx - n*mx*mx;
    const ssxy = sxy - n*mx*my;
    const m = Math.abs(ssxx) < 1e-12 ? 0 : ssxy/ssxx;
    const b = my - m*mx;
    return { m, b };
  }

  function draw(t) {
    const W = canvas.width / dpr;
    const H = canvas.height / dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, W, H);

    const pw = W - PAD_L - PAD_R;
    const ph = H - PAD_T - PAD_B;

    function toSx(v) { return PAD_L + v * pw; }
    function toSy(v) { return PAD_T + (1 - v) * ph; }

    // Grid
    ctx.strokeStyle = '#e4e4f0';
    ctx.lineWidth = 0.5;
    for (let i = 0; i <= 4; i++) {
      const v = i / 4;
      ctx.beginPath(); ctx.moveTo(toSx(v), PAD_T); ctx.lineTo(toSx(v), PAD_T + ph); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(PAD_L, toSy(v)); ctx.lineTo(PAD_L + pw, toSy(v)); ctx.stroke();
    }

    // Axes
    ctx.strokeStyle = '#c0c0d8'; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(PAD_L, PAD_T + ph); ctx.lineTo(PAD_L + pw, PAD_T + ph); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(PAD_L, PAD_T); ctx.lineTo(PAD_L, PAD_T + ph); ctx.stroke();

    // Collect all blended points
    const allPts = [];
    for (const g of allGroups) {
      for (const p of g.pts) {
        // At t=0: all in aggregate cloud → blend all group points toward a single cloud
        // The aggregate positions are just the raw positions (which already form a negative overall r)
        // At t=1: points are colored and spread as group clusters
        allPts.push({ x: p.gx, y: p.gy, group: p.group, raw: p });
      }
    }

    // Compute interpolated positions
    // At t=0: all points same color (grey), positions stay as-is (aggregate shows negative r)
    // At t=1: colored by group
    const blended = allPts.map(p => {
      const g = allGroups[p.group];
      // At t=1, keep raw position; at t=0 keep raw (positions already good)
      return { x: p.x, y: p.y, group: p.group };
    });

    // Draw per-group regression lines (only when t > 0)
    if (t > 0.05) {
      for (let gi = 0; gi < allGroups.length; gi++) {
        const g = allGroups[gi];
        const gPts = blended.filter(p => p.group === gi);
        const reg = linReg(gPts);
        const x0 = 0, x1 = 1;
        const y0 = reg.m * x0 + reg.b;
        const y1 = reg.m * x1 + reg.b;
        ctx.beginPath();
        ctx.moveTo(toSx(x0), toSy(y0));
        ctx.lineTo(toSx(x1), toSy(y1));
        ctx.strokeStyle = g.color;
        ctx.lineWidth = 2;
        ctx.globalAlpha = Math.min(1, t * 2);
        ctx.stroke();
        ctx.globalAlpha = 1;
      }
    }

    // Draw overall regression line (fades out as t → 1)
    {
      const reg = linReg(blended);
      const x0 = 0, x1 = 1;
      ctx.beginPath();
      ctx.moveTo(toSx(x0), toSy(reg.m * x0 + reg.b));
      ctx.lineTo(toSx(x1), toSy(reg.m * x1 + reg.b));
      ctx.strokeStyle = '#888899';
      ctx.lineWidth = 2.5;
      ctx.setLineDash([6, 4]);
      ctx.globalAlpha = Math.max(0, 1 - t * 1.4);
      ctx.stroke();
      ctx.globalAlpha = 1;
      ctx.setLineDash([]);
    }

    // Draw points
    for (const p of blended) {
      const g = allGroups[p.group];
      const alpha = t > 0 ? 0.75 : 0.65;
      const color = t < 0.05 ? 'rgba(100, 80, 160, 0.65)' : g.color;
      ctx.beginPath();
      ctx.arc(toSx(p.x), toSy(p.y), 4.5, 0, Math.PI * 2);
      ctx.fillStyle = color;
      ctx.globalAlpha = t < 0.05 ? 0.65 : Math.min(0.85, 0.35 + t * 0.5);
      ctx.fill();
      ctx.globalAlpha = 1;
    }

    // Axis labels
    ctx.fillStyle = '#888899';
    ctx.font = '11px IBM Plex Mono, monospace';
    ctx.textAlign = 'center';
    ctx.fillText('Study Hours →', PAD_L + pw / 2, PAD_T + ph + 28);
    ctx.save();
    ctx.translate(13, PAD_T + ph / 2);
    ctx.rotate(-Math.PI / 2);
    ctx.fillText('Exam Score →', 0, 0);
    ctx.restore();

    // X tick labels
    ctx.textAlign = 'center';
    ctx.fillStyle = '#888899';
    ctx.font = '10px IBM Plex Mono, monospace';
    const xLabels = ['Low', '', 'Mid', '', 'High'];
    for (let i = 0; i <= 4; i++) {
      if (xLabels[i]) ctx.fillText(xLabels[i], toSx(i/4), PAD_T + ph + 15);
    }

    // Group legend (visible when t > 0.1)
    if (t > 0.1) {
      const legAlpha = Math.min(1, (t - 0.1) / 0.3);
      ctx.globalAlpha = legAlpha;
      const legX = PAD_L + pw - 4;
      const legY0 = PAD_T + 8;
      ctx.font = '10px IBM Plex Mono, monospace';
      for (let gi = 0; gi < allGroups.length; gi++) {
        const g = allGroups[gi];
        const ly = legY0 + gi * 18;
        ctx.fillStyle = g.color;
        ctx.beginPath(); ctx.arc(legX - 68, ly + 4, 4, 0, Math.PI*2); ctx.fill();
        ctx.textAlign = 'left';
        ctx.fillStyle = g.color;
        ctx.fillText(g.name, legX - 60, ly + 8);
      }
      ctx.globalAlpha = 1;
      ctx.textAlign = 'left';
    }

    // Update readouts
    const allR = pearsonR(blended);
    document.getElementById('sp_overall_r').textContent = allR.toFixed(3);
    document.getElementById('sp_overall_r').style.color = allR < 0 ? '#c83c5a' : '#0d8a74';

    for (let gi = 0; gi < allGroups.length; gi++) {
      const gPts = blended.filter(p => p.group === gi).map(p => ({ x: p.x, y: p.y }));
      const r = pearsonR(gPts);
      const el = document.getElementById(`sp_g${gi+1}_r`);
      const badge = document.getElementById(`sp_g${gi+1}_badge`);
      if (el) {
        el.textContent = r.toFixed(3);
        el.style.color = r > 0 ? '#0d8a74' : '#c83c5a';
      }
      if (badge) badge.style.display = t > 0.15 ? '' : 'none';
    }

    // Phase label
    const phaseEl = document.getElementById('sp_phase');
    if (t < 0.05) phaseEl.textContent = 'Overall view: one aggregate group — overall r is negative';
    else if (t < 0.5) phaseEl.textContent = 'Groups separating… watch the regression lines appear';
    else phaseEl.textContent = 'Grouped view: each major shows a positive within-group correlation';
  }

  const slider = document.getElementById('sp_mix');
  const valEl = document.getElementById('sp_mix_val');

  slider.addEventListener('input', () => {
    const t = parseFloat(slider.value);
    valEl.textContent = Math.round(t * 100) + '%';
    draw(t);
  });

  function resize() {
    dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    draw(parseFloat(slider.value));
  }

  window.addEventListener('resize', resize);
  resize();
})();
</script>
