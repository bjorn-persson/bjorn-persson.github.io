---
title: "Regression to the Mean"
description: "Interactive scatterplot demonstrating how extreme scorers at Time 1 tend to score closer to the mean at Time 2, purely due to measurement error. A reliability slider controls the test-retest correlation, and you can click to highlight top and bottom performers."
summary: "Explore why extreme scores regress toward the mean across repeated measurement — a consequence of measurement error, not genuine change — using an interactive test-retest scatterplot."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');

.rtm-wrap { font-family: 'IBM Plex Mono', monospace; }
.rtm-subtitle {
  font-size: 0.78rem;
  color: var(--secondary);
  margin-bottom: 18px;
  line-height: 1.6;
}
.rtm-controls {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px 24px;
  margin-bottom: 16px;
  font-size: 0.78rem;
}
.rtm-control-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.rtm-control-group label { color: var(--secondary); font-size: 0.72rem; }
.rtm-val { color: #0d8a74; font-weight: 600; }
.rtm-controls input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: #e0e0ec;
  border-radius: 2px;
  outline: none;
  cursor: pointer;
}
.rtm-controls input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
}
.rtm-controls input[type="range"]::-moz-range-thumb {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
  border: none;
}
.rtm-btn-row {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}
.rtm-btn {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.72rem;
  background: none;
  border: 1px solid var(--border);
  color: var(--secondary);
  padding: 5px 12px;
  border-radius: 4px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}
.rtm-btn:hover { border-color: #0d8a74; color: #0d8a74; }
.rtm-btn.active-top { border-color: #c83c5a; color: #c83c5a; }
.rtm-btn.active-bot { border-color: #6d28d9; color: #6d28d9; }
.rtm-canvas-wrap canvas {
  display: block;
  width: 100%;
  aspect-ratio: 1;
  border-radius: 6px;
  background: #f4f4f8;
}
.rtm-readout {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 20px;
  margin-top: 12px;
  font-size: 0.72rem;
}
.rtm-badge {
  padding: 3px 10px;
  border-radius: 4px;
  background: #f0f0f8;
  border: 1px solid #e0e0ec;
  color: var(--secondary);
}
.rtm-badge .rtm-bval { font-weight: 600; color: #0d8a74; }
.rtm-badge .rtm-bval.hi { color: #c83c5a; }
.rtm-badge .rtm-bval.lo { color: #6d28d9; }
.rtm-note {
  margin-top: 12px;
  font-size: 0.68rem;
  color: var(--secondary);
  line-height: 1.6;
}
@media (max-width: 500px) {
  .rtm-controls { grid-template-columns: 1fr; }
}
</style>

<div class="rtm-wrap">
  <p class="rtm-subtitle">
    Students take the same test twice. The test-retest reliability slider controls how much random error affects scores.
    At low reliability, extreme Time-1 scorers regress strongly toward the mean at Time-2 — not because they changed, but because their extreme score partly reflected luck.
    Highlight the top or bottom performers to see the regression effect in action.
  </p>
  <div class="rtm-controls">
    <div class="rtm-control-group">
      <label>Test-retest reliability (ρ): <span class="rtm-val" id="rtm_rho_val">0.80</span></label>
      <input type="range" id="rtm_rho" min="0.01" max="0.99" step="0.01" value="0.80">
    </div>
    <div class="rtm-control-group">
      <label>Extreme group threshold: top/bottom <span class="rtm-val" id="rtm_pct_val">15</span>%</label>
      <input type="range" id="rtm_pct" min="5" max="40" step="1" value="15">
    </div>
  </div>
  <div class="rtm-btn-row">
    <button class="rtm-btn" id="rtm_btn_top" onclick="rtmHighlight('top')">Highlight top performers</button>
    <button class="rtm-btn" id="rtm_btn_bot" onclick="rtmHighlight('bot')">Highlight bottom performers</button>
    <button class="rtm-btn" onclick="rtmHighlight('none')">Clear highlight</button>
    <button class="rtm-btn" onclick="rtmReseed()">New sample</button>
  </div>
  <div class="rtm-canvas-wrap">
    <canvas id="rtm_canvas"></canvas>
  </div>
  <div class="rtm-readout">
    <div class="rtm-badge">Test-retest r: <span class="rtm-bval" id="rtm_obs_r">—</span></div>
    <div class="rtm-badge">Top group: T1 mean = <span class="rtm-bval hi" id="rtm_top_t1">—</span>, T2 mean = <span class="rtm-bval" id="rtm_top_t2">—</span></div>
    <div class="rtm-badge">Bot group: T1 mean = <span class="rtm-bval lo" id="rtm_bot_t1">—</span>, T2 mean = <span class="rtm-bval" id="rtm_bot_t2">—</span></div>
    <div class="rtm-badge">Expected regression: <span class="rtm-bval" id="rtm_expected">—</span></div>
  </div>
  <p class="rtm-note">
    The diagonal dashed line is the identity (T1 = T2). The solid line is the OLS regression of T2 on T1 — its slope equals the test-retest reliability ρ.<br>
    When ρ &lt; 1, the regression line is less steep than the identity. This means: if you scored 2 SD above the mean at T1, your expected T2 score is only 2ρ SD above the mean.<br>
    This has real-world consequences: top scorers who receive an intervention appear to "improve" the control group, and bottom scorers appear to "improve" after treatment — even if the treatment does nothing. Always include a control group.
  </p>
</div>

<script>
(function () {
  let dpr = window.devicePixelRatio || 1;
  const canvas = document.getElementById('rtm_canvas');
  const ctx = canvas.getContext('2d');

  const N = 120;
  let seed = 42;
  let highlight = 'none';

  function makeRng(s) {
    let st = s >>> 0;
    return () => {
      st += 0x6D2B79F5;
      let t = st;
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

  function generateData(rho) {
    const rng = makeRng(seed);
    const pts = [];
    for (let i = 0; i < N; i++) {
      const trueScore = randn(rng);
      const e1 = randn(rng), e2 = randn(rng);
      // Observed = sqrt(rho)*trueScore + sqrt(1-rho)*error
      const t1 = Math.sqrt(rho) * trueScore + Math.sqrt(1 - rho) * e1;
      const t2 = Math.sqrt(rho) * trueScore + Math.sqrt(1 - rho) * e2;
      pts.push({ t1, t2 });
    }
    return pts;
  }

  function pearsonR(pts) {
    const n = pts.length;
    let sx = 0, sy = 0, sxx = 0, syy = 0, sxy = 0;
    for (const p of pts) {
      sx += p.t1; sy += p.t2;
      sxx += p.t1*p.t1; syy += p.t2*p.t2;
      sxy += p.t1*p.t2;
    }
    const num = n*sxy - sx*sy;
    const den = Math.sqrt((n*sxx - sx*sx) * (n*syy - sy*sy));
    return den < 1e-12 ? 0 : num/den;
  }

  function mean(arr) { return arr.reduce((s, v) => s + v, 0) / arr.length; }

  const PAD_L = 50, PAD_R = 18, PAD_T = 18, PAD_B = 42;

  function draw() {
    const rho = parseFloat(document.getElementById('rtm_rho').value);
    const pct = parseInt(document.getElementById('rtm_pct').value) / 100;
    const pts = generateData(rho);

    // Rescale to percentile-like display range
    const allT1 = pts.map(p => p.t1);
    const allT2 = pts.map(p => p.t2);
    const mn = Math.min(...allT1, ...allT2) - 0.2;
    const mx = Math.max(...allT1, ...allT2) + 0.2;

    // Determine extremes by T1
    const sorted = [...pts].sort((a, b) => a.t1 - b.t1);
    const cutK = Math.max(1, Math.round(N * pct));
    const topT1set = new Set(sorted.slice(N - cutK).map((_, i) => pts.indexOf(sorted[N - cutK + i])));
    const botT1set = new Set(sorted.slice(0, cutK).map((_, i) => pts.indexOf(sorted[i])));

    // Actually easier to just mark by value threshold
    const t1sorted = [...allT1].sort((a, b) => a - b);
    const topThresh = t1sorted[N - cutK];
    const botThresh = t1sorted[cutK - 1];

    const W = canvas.width / dpr;
    const H = canvas.height / dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, W, H);

    const pw = W - PAD_L - PAD_R, ph = H - PAD_T - PAD_B;

    function sx(v) { return PAD_L + (v - mn) / (mx - mn) * pw; }
    function sy(v) { return PAD_T + (1 - (v - mn) / (mx - mn)) * ph; }

    // Grid
    ctx.strokeStyle = '#e4e4f0'; ctx.lineWidth = 0.5;
    for (let i = 0; i <= 4; i++) {
      const v = mn + i * (mx - mn) / 4;
      ctx.beginPath(); ctx.moveTo(sx(v), PAD_T); ctx.lineTo(sx(v), PAD_T + ph); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(PAD_L, sy(v)); ctx.lineTo(PAD_L + pw, sy(v)); ctx.stroke();
    }

    // Axes
    ctx.strokeStyle = '#c0c0d8'; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(PAD_L, PAD_T + ph); ctx.lineTo(PAD_L + pw, PAD_T + ph); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(PAD_L, PAD_T); ctx.lineTo(PAD_L, PAD_T + ph); ctx.stroke();

    // Identity line (dashed)
    ctx.beginPath();
    ctx.moveTo(sx(mn), sy(mn));
    ctx.lineTo(sx(mx), sy(mx));
    ctx.strokeStyle = '#c0c0d8';
    ctx.lineWidth = 1.5;
    ctx.setLineDash([6, 4]);
    ctx.stroke();
    ctx.setLineDash([]);

    // OLS regression line of T2 on T1
    {
      let sx2 = 0, st2 = 0, sxx2 = 0, sxt = 0;
      for (const p of pts) { sx2 += p.t1; st2 += p.t2; sxx2 += p.t1*p.t1; sxt += p.t1*p.t2; }
      const mx2 = sx2/N, mt2 = st2/N;
      const regSlope = (sxt - N*mx2*mt2) / (sxx2 - N*mx2*mx2 + 1e-12);
      const regInt = mt2 - regSlope * mx2;
      ctx.beginPath();
      ctx.moveTo(sx(mn), sy(regSlope * mn + regInt));
      ctx.lineTo(sx(mx), sy(regSlope * mx + regInt));
      ctx.strokeStyle = '#0d8a74';
      ctx.lineWidth = 2.5;
      ctx.stroke();

      // Slope annotation
      ctx.font = '10px IBM Plex Mono, monospace';
      ctx.fillStyle = '#0d8a74';
      ctx.textAlign = 'left';
      ctx.fillText(`slope = ρ ≈ ${regSlope.toFixed(2)}`, PAD_L + pw * 0.05, PAD_T + 14);
    }

    // Highlight bands
    if (highlight === 'top' || highlight === 'bot') {
      const thresh = highlight === 'top' ? topThresh : botThresh;
      const x0 = highlight === 'top' ? sx(thresh) : PAD_L;
      const x1 = highlight === 'top' ? PAD_L + pw : sx(thresh);
      ctx.fillStyle = highlight === 'top' ? 'rgba(200,60,90,0.07)' : 'rgba(109,40,217,0.07)';
      ctx.fillRect(x0, PAD_T, x1 - x0, ph);
    }

    // Points
    for (const p of pts) {
      let color = 'rgba(100,80,160,0.45)';
      let radius = 3.5;
      if (highlight === 'top' && p.t1 >= topThresh) {
        color = 'rgba(200,60,90,0.85)';
        radius = 5;
      } else if (highlight === 'bot' && p.t1 <= botThresh) {
        color = 'rgba(109,40,217,0.85)';
        radius = 5;
      }
      ctx.beginPath();
      ctx.arc(sx(p.t1), sy(p.t2), radius, 0, Math.PI*2);
      ctx.fillStyle = color;
      ctx.fill();
    }

    // T2 mean lines for extreme groups
    if (highlight !== 'none') {
      const grp = highlight === 'top'
        ? pts.filter(p => p.t1 >= topThresh)
        : pts.filter(p => p.t1 <= botThresh);
      if (grp.length > 0) {
        const t2mean = mean(grp.map(p => p.t2));
        const t1mean = mean(grp.map(p => p.t1));
        const lineColor = highlight === 'top' ? 'rgba(200,60,90,0.7)' : 'rgba(109,40,217,0.7)';
        // Vertical mean T1 line
        ctx.beginPath(); ctx.moveTo(sx(t1mean), PAD_T); ctx.lineTo(sx(t1mean), PAD_T+ph);
        ctx.strokeStyle = lineColor; ctx.lineWidth = 1.2; ctx.setLineDash([4,3]); ctx.stroke(); ctx.setLineDash([]);
        // Horizontal mean T2 line
        ctx.beginPath(); ctx.moveTo(PAD_L, sy(t2mean)); ctx.lineTo(PAD_L+pw, sy(t2mean));
        ctx.strokeStyle = lineColor; ctx.lineWidth = 1.2; ctx.setLineDash([4,3]); ctx.stroke(); ctx.setLineDash([]);

        // Arrow from T1 mean to T2 mean (regression effect)
        const ax = sx(t1mean), ay1 = sy(t1mean), ay2 = sy(t2mean);
        ctx.beginPath(); ctx.moveTo(ax, ay1); ctx.lineTo(ax, ay2);
        ctx.strokeStyle = lineColor; ctx.lineWidth = 2; ctx.setLineDash([]); ctx.stroke();
        const dir = ay2 > ay1 ? 1 : -1;
        ctx.beginPath();
        ctx.moveTo(ax, ay2);
        ctx.lineTo(ax - 5, ay2 - dir*8);
        ctx.lineTo(ax + 5, ay2 - dir*8);
        ctx.closePath();
        ctx.fillStyle = lineColor; ctx.fill();

        // Update badges
        document.getElementById('rtm_top_t1').textContent =
          highlight === 'top' ? t1mean.toFixed(2) : document.getElementById('rtm_top_t1').textContent;
        document.getElementById('rtm_top_t2').textContent =
          highlight === 'top' ? t2mean.toFixed(2) : document.getElementById('rtm_top_t2').textContent;
        document.getElementById('rtm_bot_t1').textContent =
          highlight === 'bot' ? t1mean.toFixed(2) : document.getElementById('rtm_bot_t1').textContent;
        document.getElementById('rtm_bot_t2').textContent =
          highlight === 'bot' ? t2mean.toFixed(2) : document.getElementById('rtm_bot_t2').textContent;
      }
    }

    // Axis labels
    ctx.fillStyle = '#888899';
    ctx.font = '11px IBM Plex Mono, monospace';
    ctx.textAlign = 'center';
    ctx.fillText('Score at Time 1', PAD_L + pw/2, PAD_T + ph + 32);
    ctx.save();
    ctx.translate(14, PAD_T + ph/2);
    ctx.rotate(-Math.PI/2);
    ctx.fillText('Score at Time 2', 0, 0);
    ctx.restore();

    // Tick labels
    ctx.textAlign = 'center';
    ctx.fillStyle = '#888899';
    ctx.font = '10px IBM Plex Mono, monospace';
    for (let i = 0; i <= 4; i++) {
      const v = mn + i * (mx - mn) / 4;
      ctx.beginPath(); ctx.moveTo(sx(v), PAD_T+ph); ctx.lineTo(sx(v), PAD_T+ph+4);
      ctx.strokeStyle='#c0c0d8'; ctx.lineWidth=1; ctx.stroke();
      ctx.fillText(v.toFixed(1), sx(v), PAD_T+ph+16);
    }

    // Overall r
    const r = pearsonR(pts);
    document.getElementById('rtm_obs_r').textContent = r.toFixed(3);

    // Group means
    const topPts = pts.filter(p => p.t1 >= topThresh);
    const botPts = pts.filter(p => p.t1 <= botThresh);
    if (topPts.length > 0) {
      document.getElementById('rtm_top_t1').textContent = mean(topPts.map(p => p.t1)).toFixed(2);
      document.getElementById('rtm_top_t2').textContent = mean(topPts.map(p => p.t2)).toFixed(2);
    }
    if (botPts.length > 0) {
      document.getElementById('rtm_bot_t1').textContent = mean(botPts.map(p => p.t1)).toFixed(2);
      document.getElementById('rtm_bot_t2').textContent = mean(botPts.map(p => p.t2)).toFixed(2);
    }

    // Expected regression
    document.getElementById('rtm_expected').textContent =
      `T2 | extreme T1 ≈ ρ × T1 mean ≈ ${(rho).toFixed(2)} × T1`;

    document.getElementById('rtm_rho_val').textContent = rho.toFixed(2);
    document.getElementById('rtm_pct_val').textContent = Math.round(pct * 100);
  }

  window.rtmHighlight = function(mode) {
    highlight = mode;
    document.getElementById('rtm_btn_top').className = 'rtm-btn' + (mode === 'top' ? ' active-top' : '');
    document.getElementById('rtm_btn_bot').className = 'rtm-btn' + (mode === 'bot' ? ' active-bot' : '');
    draw();
  };

  window.rtmReseed = function() {
    seed = (seed * 1664525 + 1013904223) >>> 0;
    draw();
  };

  for (const id of ['rtm_rho','rtm_pct']) {
    document.getElementById(id).addEventListener('input', draw);
  }

  function resize() {
    dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    draw();
  }

  window.addEventListener('resize', resize);
  resize();
})();
</script>
