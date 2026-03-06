---
title: "Mediation vs. Moderation"
description: "Side-by-side interactive diagrams contrasting mediation (X → M → Y path model) and moderation (the slope of X on Y changes as a function of a third variable). Sliders let you adjust path strengths and moderator level in real time."
summary: "Clarify the classic confusion between mediation (mechanism: X affects Y through M) and moderation (condition: the X–Y relationship depends on W) with linked interactive diagrams."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');

.mm-wrap { font-family: 'IBM Plex Mono', monospace; max-width: 54rem; margin: 0 auto; }
.mm-subtitle {
  font-family: 'Source Serif 4', Georgia, serif;
  font-size: 1.0rem;
  color: var(--secondary);
  margin-bottom: 18px;
  line-height: 1.6;
}
.mm-panels {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}
.mm-panel {
  display: flex;
  flex-direction: column;
  gap: 10px;
  height: 100%;
}
.mm-panel-header {
  font-size: 1.05rem;
  font-weight: 600;
  color: var(--primary);
  border-bottom: 2px solid #2a2d3a;
  padding-bottom: 6px;
  white-space: nowrap;
}
.mm-panel-header span {
  font-size: 0.9rem;
  font-weight: 400;
  color: var(--secondary);
  margin-left: 8px;
}
.mm-canvas-wrap canvas {
  display: block;
  width: 100%;
  height: 264px;
  border-radius: 6px;
  background: #181a24;
}
.mm-control-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 0.92rem;
}
.mm-control-group label { color: var(--secondary); }
.mm-val { color: #2dd4bf; font-weight: 600; }
.mm-panel input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: #2a2d3a;
  border-radius: 2px;
  outline: none;
  cursor: pointer;
}
.mm-panel input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #2dd4bf;
  cursor: pointer;
}
.mm-panel input[type="range"]::-moz-range-thumb {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #2dd4bf;
  cursor: pointer;
  border: none;
}
.mm-readout {
  font-size: 0.9rem;
  color: var(--secondary);
  display: flex;
  flex-direction: column;
  gap: 4px;
  background: #181a24;
  border-radius: 5px;
  padding: 10px 12px;
  margin-top: auto;
}
.mm-readout .mm-row {
  display: flex;
  justify-content: space-between;
}
.mm-readout .mm-rval { color: #2dd4bf; font-weight: 600; }
.mm-readout .mm-rval.accent { color: #c2640a; }
.mm-note {
  margin-top: 12px;
  font-size: 0.88rem;
  color: var(--secondary);
  line-height: 1.6;
}
@media (max-width: 640px) {
  .mm-panels { grid-template-columns: 1fr; }
}
</style>

<div class="mm-wrap">
  <p class="mm-subtitle">
    <strong>Mediation</strong>: X affects Y <em>through</em> a third variable M (the mechanism).<br>
    <strong>Moderation</strong>: the strength or direction of the X → Y relationship <em>depends on</em> a third variable W (the condition).<br><br>
    Use the sliders to adjust effect sizes and watch the path diagrams and regression plots update.
  </p>
  <div class="mm-panels">
    <!-- MEDIATION -->
    <div class="mm-panel">
      <div class="mm-panel-header">Mediation <span>X → M → Y</span></div>
      <div class="mm-canvas-wrap"><canvas id="med_canvas" height="264"></canvas></div>
      <div class="mm-control-group">
        <label>a path  (X → M): <span class="mm-val" id="med_a_val">0.70</span></label>
        <input type="range" id="med_a" min="-1" max="1" step="0.01" value="0.70">
      </div>
      <div class="mm-control-group">
        <label>b path  (M → Y): <span class="mm-val" id="med_b_val">0.70</span></label>
        <input type="range" id="med_b" min="-1" max="1" step="0.01" value="0.70">
      </div>
      <div class="mm-control-group">
        <label>c′ path (direct X → Y): <span class="mm-val" id="med_cp_val">0.20</span></label>
        <input type="range" id="med_cp" min="-1" max="1" step="0.01" value="0.20">
      </div>
      <div class="mm-readout">
        <div class="mm-row"><span>Indirect effect (a×b):</span><span class="mm-rval" id="med_indirect">—</span></div>
        <div class="mm-row"><span>Direct effect (c′):</span><span class="mm-rval accent" id="med_direct">—</span></div>
        <div class="mm-row"><span>Total effect (a×b + c′):</span><span class="mm-rval" id="med_total">—</span></div>
        <div class="mm-row"><span>Proportion mediated:</span><span class="mm-rval" id="med_prop">—</span></div>
      </div>
    </div>
    <!-- MODERATION -->
    <div class="mm-panel">
      <div class="mm-panel-header">Moderation <span>Y = β₀ + β₁X + β₂W + β₃(X×W)</span></div>
      <div class="mm-canvas-wrap"><canvas id="mod_canvas" height="264"></canvas></div>
      <div class="mm-control-group">
        <label>Main effect of X (β₁): <span class="mm-val" id="mod_b1_val">0.50</span></label>
        <input type="range" id="mod_b1" min="-1" max="1" step="0.01" value="0.50">
      </div>
      <div class="mm-control-group">
        <label>Main effect of W (β₂): <span class="mm-val" id="mod_b2_val">0.30</span></label>
        <input type="range" id="mod_b2" min="-0.5" max="0.5" step="0.01" value="0.30">
      </div>
      <div class="mm-control-group">
        <label>Interaction X×W (β₃): <span class="mm-val" id="mod_b3_val">0.60</span></label>
        <input type="range" id="mod_b3" min="-1.5" max="1.5" step="0.01" value="0.60">
      </div>
      <div class="mm-control-group">
        <label>Moderator W level: <span class="mm-val" id="mod_w_val">0.00</span> σ</label>
        <input type="range" id="mod_w" min="-2" max="2" step="0.05" value="0">
      </div>
      <div class="mm-readout">
        <div class="mm-row"><span>Slope at W = −1σ:</span><span class="mm-rval" id="mod_slope_lo">—</span></div>
        <div class="mm-row"><span>Slope at W =  0:</span><span class="mm-rval" id="mod_slope_mid">—</span></div>
        <div class="mm-row"><span>Slope at W = +1σ:</span><span class="mm-rval accent" id="mod_slope_hi">—</span></div>
        <div class="mm-row"><span>Current slope (W = <span id="mod_w_cur">0.00</span>σ):</span><span class="mm-rval" id="mod_slope_cur">—</span></div>
      </div>
    </div>
  </div>
  <p class="mm-note">
    <strong>Key distinction:</strong> In mediation, removing M from the model changes the X–Y coefficient (the effect is "explained away").
    In moderation, the X–Y relationship is literally different for different people — the slope tilts as W changes.<br>
    Full moderation model: Y = β₀ + β₁X + β₂W + β₃(X×W). The β₂W term shifts each line's intercept (parallel offset); β₃(X×W) tilts the slopes. Omitting β₂W forces all lines to share the same intercept at X=0, which is rarely realistic.<br>
    Full mediation: c′ ≈ 0 (the direct path vanishes). Partial mediation: c′ remains nonzero.
  </p>
</div>

<script>
(function () {
  let dpr = window.devicePixelRatio || 1;

  // ── MEDIATION DIAGRAM ──────────────────────────────────────────────
  const medCanvas = document.getElementById('med_canvas');
  const mCtx = medCanvas.getContext('2d');

  function arrowHead(ctx, x, y, angle, size, color) {
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(angle);
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(-size, -size * 0.5);
    ctx.lineTo(-size, size * 0.5);
    ctx.closePath();
    ctx.fillStyle = color;
    ctx.fill();
    ctx.restore();
  }

  function drawArrow(ctx, x1, y1, x2, y2, thickness, color, dashed) {
    const dx = x2 - x1, dy = y2 - y1;
    const len = Math.sqrt(dx*dx + dy*dy);
    const ux = dx/len, uy = dy/len;
    const gap = 32;
    const ax1 = x1 + ux * gap, ay1 = y1 + uy * gap;
    const ax2 = x2 - ux * gap, ay2 = y2 - uy * gap;
    ctx.beginPath();
    ctx.moveTo(ax1, ay1);
    ctx.lineTo(ax2, ay2);
    ctx.strokeStyle = color;
    ctx.lineWidth = Math.max(0.5, Math.abs(thickness) * 5);
    if (dashed) ctx.setLineDash([5, 4]);
    else ctx.setLineDash([]);
    ctx.stroke();
    ctx.setLineDash([]);
    const angle = Math.atan2(ay2 - ay1, ax2 - ax1);
    arrowHead(ctx, ax2, ay2, angle, 8, color);
  }

  function drawNode(ctx, x, y, label, sub, color) {
    ctx.beginPath();
    ctx.arc(x, y, 28, 0, Math.PI * 2);
    ctx.fillStyle = color || '#181a24';
    ctx.fill();
    ctx.strokeStyle = '#2a2d3a';
    ctx.lineWidth = 1.5;
    ctx.stroke();
    ctx.fillStyle = '#c9cdd8';
    ctx.textAlign = 'center';
    ctx.font = `bold 17px IBM Plex Mono, monospace`;
    ctx.fillText(label, x, y + 3);
    if (sub) {
      ctx.font = '15px IBM Plex Mono, monospace';
      ctx.fillStyle = '#6b7084';
      ctx.fillText(sub, x, y + 18);
    }
  }

  function drawMed() {
    const W = medCanvas.width / dpr;
    const H = medCanvas.height / dpr;
    mCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    mCtx.clearRect(0, 0, W, H);

    const a  = parseFloat(document.getElementById('med_a').value);
    const b  = parseFloat(document.getElementById('med_b').value);
    const cp = parseFloat(document.getElementById('med_cp').value);

    const Xc = W * 0.15, Yc = H * 0.72;
    const Mc = W * 0.50, Mc_y = H * 0.18;
    const Yc_x = W * 0.85, Yc_y = H * 0.72;

    // Paths
    const aColor = a >= 0 ? '#2dd4bf' : '#ef4444';
    const bColor = b >= 0 ? '#2dd4bf' : '#ef4444';
    const cpColor = Math.abs(cp) < 0.05 ? '#2a2d3a' : (cp >= 0 ? '#c2640a' : '#6d28d9');

    drawArrow(mCtx, Xc, Yc, Mc, Mc_y, a, aColor, false);
    drawArrow(mCtx, Mc, Mc_y, Yc_x, Yc_y, b, bColor, false);
    drawArrow(mCtx, Xc, Yc, Yc_x, Yc_y, cp, cpColor, Math.abs(cp) < 0.05);

    // Path labels
    mCtx.font = '14px IBM Plex Mono, monospace';
    mCtx.textAlign = 'center';

    mCtx.fillStyle = aColor;
    mCtx.fillText(`a = ${a.toFixed(2)}`, (Xc + Mc) / 2 - 10, (Yc + Mc_y) / 2 - 8);

    mCtx.fillStyle = bColor;
    mCtx.fillText(`b = ${b.toFixed(2)}`, (Mc + Yc_x) / 2 + 10, (Mc_y + Yc_y) / 2 - 8);

    mCtx.fillStyle = cpColor;
    mCtx.fillText(`c′ = ${cp.toFixed(2)}`, W / 2, Yc + 22);

    // Nodes
    drawNode(mCtx, Xc, Yc, 'X', 'predictor', '#1e2a28');
    drawNode(mCtx, Mc, Mc_y, 'M', 'mediator', '#1e2a28');
    drawNode(mCtx, Yc_x, Yc_y, 'Y', 'outcome', '#1e2a28');

    // Update readout
    const indirect = a * b;
    const total = indirect + cp;
    const prop = Math.abs(total) > 0.001 ? indirect / total : 0;
    document.getElementById('med_indirect').textContent = indirect.toFixed(3);
    document.getElementById('med_direct').textContent = cp.toFixed(3);
    document.getElementById('med_total').textContent = total.toFixed(3);
    document.getElementById('med_prop').textContent = (prop * 100).toFixed(1) + '%';
    document.getElementById('med_a_val').textContent = a.toFixed(2);
    document.getElementById('med_b_val').textContent = b.toFixed(2);
    document.getElementById('med_cp_val').textContent = cp.toFixed(2);
  }

  // ── MODERATION PLOT ────────────────────────────────────────────────
  const modCanvas = document.getElementById('mod_canvas');
  const rCtx = modCanvas.getContext('2d');

  const PAD_L = 52, PAD_R = 16, PAD_T = 16, PAD_B = 40;

  function drawMod() {
    const W = modCanvas.width / dpr;
    const H = modCanvas.height / dpr;
    rCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    rCtx.clearRect(0, 0, W, H);

    const pw = W - PAD_L - PAD_R;
    const ph = H - PAD_T - PAD_B;

    const b1 = parseFloat(document.getElementById('mod_b1').value);
    const b2 = parseFloat(document.getElementById('mod_b2').value);
    const b3 = parseFloat(document.getElementById('mod_b3').value);
    const wCur = parseFloat(document.getElementById('mod_w').value);

    // Y = b0 + b1*X + b3*X*W  (b0 = 0.5, at X in [0,1], W in [-2,2])
    // Slope at W: b1 + b3*W
    const slopeLo  = b1 + b3 * (-1);
    const slopeMid = b1 + b3 * 0;
    const slopeHi  = b1 + b3 * 1;
    const slopeCur = b1 + b3 * wCur;

    function toSx(v) { return PAD_L + v * pw; }

    // Y range: always show [-0.2, 1.2] for stability
    const yMin = -0.2, yMax = 1.2;
    function toSy(v) { return PAD_T + (1 - (v - yMin) / (yMax - yMin)) * ph; }

    // Grid
    rCtx.strokeStyle = '#1e2030'; rCtx.lineWidth = 0.5;
    for (let i = 0; i <= 4; i++) {
      const v = i / 4;
      rCtx.beginPath(); rCtx.moveTo(toSx(v), PAD_T); rCtx.lineTo(toSx(v), PAD_T + ph); rCtx.stroke();
    }
    for (let y = -0.2; y <= 1.21; y += 0.35) {
      rCtx.beginPath(); rCtx.moveTo(PAD_L, toSy(y)); rCtx.lineTo(PAD_L + pw, toSy(y)); rCtx.stroke();
    }

    // Axes
    rCtx.strokeStyle = '#2a2d3a'; rCtx.lineWidth = 1;
    rCtx.beginPath(); rCtx.moveTo(PAD_L, PAD_T + ph); rCtx.lineTo(PAD_L + pw, PAD_T + ph); rCtx.stroke();
    rCtx.beginPath(); rCtx.moveTo(PAD_L, PAD_T); rCtx.lineTo(PAD_L, PAD_T + ph); rCtx.stroke();

    // Y=0 line
    const y0line = toSy(0);
    rCtx.beginPath(); rCtx.moveTo(PAD_L, y0line); rCtx.lineTo(PAD_L + pw, y0line);
    rCtx.strokeStyle = 'rgba(255,255,255,0.1)'; rCtx.lineWidth = 1; rCtx.stroke();

    // Reference lines W = -1, 0, +1 (thin, colored)
    const wLines = [
      { w: -1, color: '#a78bfa', label: 'W=−1σ', dash: [4,4] },
      { w:  0, color: '#6b7084', label: 'W=0',   dash: [4,4] },
      { w:  1, color: '#f59e0b', label: 'W=+1σ', dash: [4,4] },
    ];
    for (const wl of wLines) {
      const s = b1 + b3 * wl.w;
      const y0 = 0.5 + b2 * wl.w;
      const y1 = 0.5 + b2 * wl.w + s * 1;
      rCtx.beginPath();
      rCtx.moveTo(toSx(0), toSy(y0));
      rCtx.lineTo(toSx(1), toSy(y1));
      rCtx.strokeStyle = wl.color;
      rCtx.lineWidth = 1.5;
      rCtx.setLineDash(wl.dash);
      rCtx.globalAlpha = 0.5;
      rCtx.stroke();
      rCtx.globalAlpha = 1;
      rCtx.setLineDash([]);
    }

    // Current W line (solid, thick)
    {
      const y0 = 0.5 + b2 * wCur;
      const y1 = 0.5 + b2 * wCur + slopeCur * 1;
      const lineColor = wCur > 0.1 ? '#c2640a' : wCur < -0.1 ? '#6d28d9' : '#2dd4bf';
      rCtx.beginPath();
      rCtx.moveTo(toSx(0), toSy(y0));
      rCtx.lineTo(toSx(1), toSy(y1));
      rCtx.strokeStyle = lineColor;
      rCtx.lineWidth = 3;
      rCtx.setLineDash([]);
      rCtx.stroke();
    }

    // Slope = 0 annotation
    if (Math.abs(slopeCur) < 0.08) {
      rCtx.fillStyle = '#2a2d3a';
      rCtx.font = '13px IBM Plex Mono, monospace';
      rCtx.textAlign = 'center';
      rCtx.fillText('slope ≈ 0', toSx(0.5), toSy(0.5) - 10);
    }

    // X axis label
    rCtx.fillStyle = '#6b7084';
    rCtx.font = '14px IBM Plex Mono, monospace';
    rCtx.textAlign = 'center';
    rCtx.fillText('X (predictor)', PAD_L + pw / 2, PAD_T + ph + 30);
    rCtx.save();
    rCtx.translate(15, PAD_T + ph / 2);
    rCtx.rotate(-Math.PI / 2);
    rCtx.fillText('Y (outcome)', 0, 0);
    rCtx.restore();

    // X ticks
    rCtx.textAlign = 'center';
    rCtx.fillStyle = '#6b7084';
    rCtx.font = '13px IBM Plex Mono, monospace';
    for (let i = 0; i <= 4; i++) {
      rCtx.fillText(['Low','','','','High'][i] || '', toSx(i/4), PAD_T + ph + 17);
    }

    // Legend
    rCtx.font = '12px IBM Plex Mono, monospace';
    const legEntries = [
      { label: 'W = −1σ', color: '#6d28d9' },
      { label: 'W =  0',  color: '#6b7084' },
      { label: 'W = +1σ', color: '#c2640a' },
    ];
    const legX = PAD_L + 6;
    for (let i = 0; i < legEntries.length; i++) {
      const ly = PAD_T + 8 + i * 14;
      rCtx.strokeStyle = legEntries[i].color;
      rCtx.lineWidth = 1.5;
      rCtx.setLineDash([4, 4]);
      rCtx.globalAlpha = 0.5;
      rCtx.beginPath(); rCtx.moveTo(legX, ly); rCtx.lineTo(legX + 20, ly); rCtx.stroke();
      rCtx.setLineDash([]); rCtx.globalAlpha = 1;
      rCtx.fillStyle = legEntries[i].color;
      rCtx.textAlign = 'left';
      rCtx.fillText(legEntries[i].label, legX + 24, ly + 4);
    }

    // Update readout
    document.getElementById('mod_slope_lo').textContent  = slopeLo.toFixed(3);
    document.getElementById('mod_slope_mid').textContent = slopeMid.toFixed(3);
    document.getElementById('mod_slope_hi').textContent  = slopeHi.toFixed(3);
    document.getElementById('mod_slope_cur').textContent = slopeCur.toFixed(3);
    document.getElementById('mod_w_cur').textContent     = wCur.toFixed(2);
    document.getElementById('mod_b1_val').textContent  = b1.toFixed(2);
    document.getElementById('mod_b2_val').textContent  = b2.toFixed(2);
    document.getElementById('mod_b3_val').textContent  = b3.toFixed(2);
    document.getElementById('mod_w_val').textContent   = wCur.toFixed(2);
  }

  function updateMed() { drawMed(); }
  function updateMod() { drawMod(); }

  for (const id of ['med_a','med_b','med_cp']) {
    document.getElementById(id).addEventListener('input', updateMed);
  }
  for (const id of ['mod_b1','mod_b2','mod_b3','mod_w']) {
    document.getElementById(id).addEventListener('input', updateMod);
  }

  function resize() {
    dpr = window.devicePixelRatio || 1;
    for (const c of [medCanvas, modCanvas]) {
      const rect = c.getBoundingClientRect();
      c.width = rect.width * dpr;
      c.height = rect.height * dpr;
    }
    drawMed();
    drawMod();
  }

  window.addEventListener('resize', resize);
  resize();
})();
</script>

---

##### Citation

Persson, B. N. (2026). *Mediation vs. moderation* [Interactive visualization]. https://bnpersson.github.io/visualizations/mediation-moderation/

```BibTeX
@misc{Persson2026medmod,
  author = {Björn N. Persson},
  year = {2026},
  title = {Mediation vs. Moderation},
  note = {Interactive visualization},
  url = {https://bnpersson.github.io/visualizations/mediation-moderation/}}
```
