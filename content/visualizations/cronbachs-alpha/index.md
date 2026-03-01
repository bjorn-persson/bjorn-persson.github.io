---
title: "Cronbach's Alpha and Measurement Reliability"
description: "Interactive visualization of how Cronbach's alpha determines the Standard Error of Measurement, true-score confidence intervals, and the attenuation of correlations - with direct consequences for psychological assessment."
summary: "Explore how Cronbach's alpha shapes the Standard Error of Measurement, the width of true-score confidence intervals, and how much reliability degrades observed correlations between constructs."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');

.ca-wrap { font-family: 'IBM Plex Mono', monospace; }
.ca-subtitle {
  font-size: 0.78rem;
  color: var(--secondary);
  margin-bottom: 18px;
  line-height: 1.6;
}
.ca-layout {
  display: flex;
  flex-direction: column;
  gap: 22px;
}
.ca-controls {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 10px 20px;
  font-size: 0.72rem;
}
.ca-control-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.ca-control-group label { color: var(--secondary); }
.ca-val { color: #0d8a74; font-weight: 600; }
.ca-controls input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: #e0e0ec;
  border-radius: 2px;
  outline: none;
  cursor: pointer;
}
.ca-controls input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
}
.ca-controls input[type="range"]::-moz-range-thumb {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
  border: none;
}
.ca-stat-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
}
.ca-stat {
  background: #f4f4f8;
  border-radius: 5px;
  padding: 8px 10px;
  border-left: 3px solid #e0e0ec;
  transition: border-color 0.3s;
}
.ca-stat.warn { border-left-color: #c83c5a; }
.ca-stat.ok   { border-left-color: #0d8a74; }
.ca-stat-label {
  font-size: 0.62rem;
  color: var(--secondary);
  margin-bottom: 2px;
  line-height: 1.3;
}
.ca-stat-value {
  font-size: 1.05rem;
  font-weight: 600;
  color: #0d8a74;
  transition: color 0.3s;
}
.ca-stat-value.warn { color: #c83c5a; }
.ca-panels {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}
.ca-panel {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.ca-panel-label {
  font-size: 0.7rem;
  color: var(--secondary);
  text-transform: uppercase;
  letter-spacing: 0.07em;
}
.ca-panel canvas {
  display: block;
  width: 100%;
  border-radius: 6px;
  background: #f4f4f8;
}
.ca-interp {
  font-size: 0.72rem;
  color: var(--secondary);
  line-height: 1.6;
  padding: 8px 10px;
  background: #f4f4f8;
  border-radius: 5px;
  border-left: 3px solid #e0e0ec;
  transition: border-color 0.3s;
  min-height: 2.8em;
}
.ca-interp.warn { border-left-color: #c83c5a; }
.ca-interp span.hl { color: #c83c5a; font-weight: 600; }
.ca-interp span.ok { color: #0d8a74; font-weight: 600; }
.ca-note {
  font-size: 0.68rem;
  color: var(--secondary);
  line-height: 1.6;
  margin-top: 4px;
}
@media (max-width: 600px) {
  .ca-controls { grid-template-columns: 1fr 1fr; }
  .ca-stat-row  { grid-template-columns: 1fr 1fr; }
  .ca-panels    { grid-template-columns: 1fr; }
}
@media (max-width: 400px) {
  .ca-controls { grid-template-columns: 1fr; }
}
</style>

<div class="ca-wrap">
  <p class="ca-subtitle">
    Cronbach's α determines the <strong>Standard Error of Measurement (SEM)</strong>: how much a single observed score differs from a person's true score.
    A score is not a point — it is an interval. Low α widens that interval, increases classification errors, and attenuates observed correlations between constructs.
  </p>
  <div class="ca-layout">
    <div class="ca-controls">
      <div class="ca-control-group">
        <label>Cronbach's α: <span class="ca-val" id="ca_alpha_val">0.80</span></label>
        <input type="range" id="ca_alpha" min="0.40" max="1.00" step="0.01" value="0.80">
      </div>
      <div class="ca-control-group">
        <label>True score (0–100): <span class="ca-val" id="ca_true_val">65</span></label>
        <input type="range" id="ca_true" min="0" max="100" step="1" value="65">
      </div>
      <div class="ca-control-group">
        <label>Test SD (score units): <span class="ca-val" id="ca_sd_val">15</span></label>
        <input type="range" id="ca_sd" min="5" max="25" step="1" value="15">
      </div>
    </div>
    <div class="ca-stat-row">
      <div class="ca-stat" id="ca_sem_card">
        <div class="ca-stat-label">SEM (score units)</div>
        <div class="ca-stat-value" id="ca_sem_val">—</div>
      </div>
      <div class="ca-stat" id="ca_ci68_card">
        <div class="ca-stat-label">68% true-score CI width</div>
        <div class="ca-stat-value" id="ca_ci68_val">—</div>
      </div>
      <div class="ca-stat" id="ca_ci95_card">
        <div class="ca-stat-label">95% true-score CI width</div>
        <div class="ca-stat-value" id="ca_ci95_val">—</div>
      </div>
      <div class="ca-stat" id="ca_ratt_card">
        <div class="ca-stat-label">Max observable r (same α)</div>
        <div class="ca-stat-value" id="ca_ratt_val">—</div>
      </div>
    </div>
    <div class="ca-interp" id="ca_interp">—</div>
    <div class="ca-panels">
      <div class="ca-panel">
        <div class="ca-panel-label">Observed score → true-score CI</div>
        <canvas id="ca_score" height="290"></canvas>
      </div>
      <div class="ca-panel">
        <div class="ca-panel-label">Repeated testing distribution</div>
        <canvas id="ca_dist" height="290"></canvas>
      </div>
    </div>
    <div class="ca-panel">
      <div class="ca-panel-label">Correlation attenuation by reliability</div>
      <canvas id="ca_att" height="220"></canvas>
    </div>
  </div>
  <p class="ca-note">
    <strong>SEM = SD × √(1 − α).</strong>
    The 95% true-score CI for an observed score X is [X − 1.96·SEM, X + 1.96·SEM].<br>
    Correlation attenuation: observed r = true r × α (when both measures have the same α). At α = 0.70, a true r = 0.50 appears as r ≈ 0.35 — a 30% underestimate.<br>
    Rules of thumb: α ≥ 0.90 for high-stakes individual decisions; α ≥ 0.70 for research/group comparisons.
  </p>
</div>

<script>
(function () {
  let dpr = window.devicePixelRatio || 1;

  const scoreCanvas = document.getElementById('ca_score');
  const distCanvas  = document.getElementById('ca_dist');
  const attCanvas   = document.getElementById('ca_att');
  const sCtx = scoreCanvas.getContext('2d');
  const dCtx = distCanvas.getContext('2d');
  const aCtx = attCanvas.getContext('2d');

  function normalPdf(x, mu, sigma) {
    if (sigma <= 0) return 0;
    const z = (x - mu) / sigma;
    return Math.exp(-0.5 * z * z) / (sigma * Math.sqrt(2 * Math.PI));
  }

  // ── Score scale panel ─────────────────────────────────────────────────────
  function drawScore(alpha, trueScore, sd) {
    const W = scoreCanvas.width / dpr;
    const H = scoreCanvas.height / dpr;
    sCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    sCtx.clearRect(0, 0, W, H);

    const sem = sd * Math.sqrt(1 - alpha);
    const PAD_L = 20, PAD_R = 20, PAD_T = 36, PAD_B = 48;
    const pw = W - PAD_L - PAD_R;
    const midY = PAD_T + (H - PAD_T - PAD_B) / 2;

    const xMin = 0, xMax = 100;
    function toX(v) { return PAD_L + (v - xMin) / (xMax - xMin) * pw; }

    // Axis
    sCtx.beginPath(); sCtx.moveTo(toX(0), midY); sCtx.lineTo(toX(100), midY);
    sCtx.strokeStyle = '#c0c0d8'; sCtx.lineWidth = 1; sCtx.stroke();

    // Tick marks
    sCtx.font = '9px IBM Plex Mono, monospace';
    sCtx.fillStyle = '#888899';
    sCtx.textAlign = 'center';
    for (let t = 0; t <= 100; t += 10) {
      const tx = toX(t);
      sCtx.beginPath(); sCtx.moveTo(tx, midY - 4); sCtx.lineTo(tx, midY + 4);
      sCtx.strokeStyle = '#c0c0d8'; sCtx.lineWidth = 1; sCtx.stroke();
      sCtx.fillText(t, tx, midY + 15);
    }

    // 95% CI band
    const lo95 = Math.max(0, trueScore - 1.96 * sem);
    const hi95 = Math.min(100, trueScore + 1.96 * sem);
    const lo68 = Math.max(0, trueScore - sem);
    const hi68 = Math.min(100, trueScore + sem);

    const bandH = 22;
    // 95% fill
    sCtx.fillStyle = 'rgba(200,60,90,0.10)';
    sCtx.fillRect(toX(lo95), midY - bandH, toX(hi95) - toX(lo95), bandH * 2);
    // 68% fill
    sCtx.fillStyle = 'rgba(200,60,90,0.22)';
    sCtx.fillRect(toX(lo68), midY - bandH, toX(hi68) - toX(lo68), bandH * 2);

    // 95% bracket
    sCtx.strokeStyle = 'rgba(200,60,90,0.55)'; sCtx.lineWidth = 1.5; sCtx.setLineDash([4,3]);
    sCtx.beginPath(); sCtx.moveTo(toX(lo95), midY - bandH - 8); sCtx.lineTo(toX(hi95), midY - bandH - 8); sCtx.stroke();
    sCtx.setLineDash([]);
    sCtx.beginPath(); sCtx.moveTo(toX(lo95), midY - bandH - 12); sCtx.lineTo(toX(lo95), midY - bandH - 4); sCtx.stroke();
    sCtx.beginPath(); sCtx.moveTo(toX(hi95), midY - bandH - 12); sCtx.lineTo(toX(hi95), midY - bandH - 4); sCtx.stroke();

    // 95% label above bracket
    sCtx.font = '9px IBM Plex Mono, monospace';
    sCtx.fillStyle = 'rgba(200,60,90,0.8)';
    sCtx.textAlign = 'center';
    sCtx.fillText('95% CI', toX((lo95 + hi95) / 2), midY - bandH - 14);

    // True score marker
    const tsx = toX(trueScore);
    sCtx.beginPath(); sCtx.moveTo(tsx, midY - bandH - 2); sCtx.lineTo(tsx, midY + bandH + 2);
    sCtx.strokeStyle = '#0d8a74'; sCtx.lineWidth = 2; sCtx.stroke();

    // Observed score marker (same as true — user sets true score, observed = true)
    sCtx.beginPath();
    sCtx.arc(tsx, midY, 6, 0, Math.PI * 2);
    sCtx.fillStyle = '#0d8a74';
    sCtx.fill();

    // Labels
    sCtx.font = '10px IBM Plex Mono, monospace';
    sCtx.fillStyle = '#0d8a74';
    sCtx.textAlign = 'center';
    sCtx.fillText(`Score = ${trueScore}`, tsx, midY - bandH - 28);

    // SEM annotation below axis
    sCtx.font = '9px IBM Plex Mono, monospace';
    sCtx.fillStyle = '#888899';
    sCtx.textAlign = 'center';
    sCtx.fillText(`SEM = ${sem.toFixed(1)} pts  |  68% CI: [${lo68.toFixed(0)}, ${hi68.toFixed(0)}]  |  95% CI: [${lo95.toFixed(0)}, ${hi95.toFixed(0)}]`, W / 2, H - 10);

    // Title
    sCtx.font = 'bold 10px IBM Plex Mono, monospace';
    sCtx.fillStyle = alpha >= 0.9 ? '#0d8a74' : alpha >= 0.7 ? '#c2640a' : '#c83c5a';
    sCtx.textAlign = 'center';
    sCtx.fillText(`α = ${alpha.toFixed(2)}  →  SEM = ${sem.toFixed(1)}`, W / 2, 16);
  }

  // ── Repeated-testing distribution ────────────────────────────────────────
  function drawDist(alpha, trueScore, sd) {
    const W = distCanvas.width / dpr;
    const H = distCanvas.height / dpr;
    dCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    dCtx.clearRect(0, 0, W, H);

    const sem = sd * Math.sqrt(1 - alpha);
    const PAD_L = 44, PAD_R = 14, PAD_T = 28, PAD_B = 36;
    const pw = W - PAD_L - PAD_R;
    const ph = H - PAD_T - PAD_B;

    const xMin = Math.max(0, trueScore - 4 * Math.max(sem, sd * 0.3));
    const xMax = Math.min(100, trueScore + 4 * Math.max(sem, sd * 0.3));
    function toX(v) { return PAD_L + (v - xMin) / (xMax - xMin) * pw; }

    const steps = 300;
    const peakPdf = normalPdf(trueScore, trueScore, Math.max(sem, 0.01));
    function toY(density) { return PAD_T + ph - (density / (peakPdf * 1.18)) * ph; }

    // Grid
    dCtx.strokeStyle = '#e4e4f0'; dCtx.lineWidth = 0.5;
    for (let i = 0; i <= 4; i++) {
      const xv = xMin + (xMax - xMin) * i / 4;
      dCtx.beginPath(); dCtx.moveTo(toX(xv), PAD_T); dCtx.lineTo(toX(xv), PAD_T + ph); dCtx.stroke();
    }

    // SEM shading regions: 68% and 95%
    const lo95 = trueScore - 1.96 * sem, hi95 = trueScore + 1.96 * sem;
    const lo68 = trueScore - sem, hi68 = trueScore + sem;

    function shadeCurve(loVal, hiVal, color) {
      dCtx.beginPath();
      const loClamped = Math.max(xMin, loVal);
      const hiClamped = Math.min(xMax, hiVal);
      dCtx.moveTo(toX(loClamped), toY(0));
      for (let i = 0; i <= steps; i++) {
        const x = loClamped + (hiClamped - loClamped) * i / steps;
        dCtx.lineTo(toX(x), toY(normalPdf(x, trueScore, sem)));
      }
      dCtx.lineTo(toX(hiClamped), toY(0));
      dCtx.closePath();
      dCtx.fillStyle = color;
      dCtx.fill();
    }

    shadeCurve(lo95, hi95, 'rgba(200,60,90,0.12)');
    shadeCurve(lo68, hi68, 'rgba(200,60,90,0.25)');

    // Full curve
    dCtx.beginPath();
    for (let i = 0; i <= steps; i++) {
      const x = xMin + (xMax - xMin) * i / steps;
      const y = toY(normalPdf(x, trueScore, sem));
      i === 0 ? dCtx.moveTo(toX(x), y) : dCtx.lineTo(toX(x), y);
    }
    dCtx.strokeStyle = '#c83c5a'; dCtx.lineWidth = 2; dCtx.stroke();

    // True score vertical line
    const tsx = toX(trueScore);
    dCtx.beginPath(); dCtx.moveTo(tsx, PAD_T); dCtx.lineTo(tsx, PAD_T + ph);
    dCtx.strokeStyle = '#0d8a74'; dCtx.lineWidth = 1.5; dCtx.setLineDash([4, 3]);
    dCtx.stroke(); dCtx.setLineDash([]);

    // Axes
    dCtx.strokeStyle = '#c0c0d8'; dCtx.lineWidth = 1;
    dCtx.beginPath(); dCtx.moveTo(PAD_L, PAD_T + ph); dCtx.lineTo(PAD_L + pw, PAD_T + ph); dCtx.stroke();
    dCtx.beginPath(); dCtx.moveTo(PAD_L, PAD_T); dCtx.lineTo(PAD_L, PAD_T + ph); dCtx.stroke();

    // X-axis ticks
    dCtx.font = '9px IBM Plex Mono, monospace';
    dCtx.fillStyle = '#888899';
    dCtx.textAlign = 'center';
    for (let i = 0; i <= 4; i++) {
      const xv = xMin + (xMax - xMin) * i / 4;
      const sx = toX(xv);
      dCtx.beginPath(); dCtx.moveTo(sx, PAD_T + ph); dCtx.lineTo(sx, PAD_T + ph + 4);
      dCtx.strokeStyle = '#c0c0d8'; dCtx.lineWidth = 1; dCtx.stroke();
      dCtx.fillText(xv.toFixed(0), sx, PAD_T + ph + 16);
    }

    // Y-axis label
    dCtx.save();
    dCtx.translate(13, PAD_T + ph / 2);
    dCtx.rotate(-Math.PI / 2);
    dCtx.textAlign = 'center';
    dCtx.fillStyle = '#888899';
    dCtx.font = '9px IBM Plex Mono, monospace';
    dCtx.fillText('frequency', 0, 0);
    dCtx.restore();

    // Title
    dCtx.font = 'bold 10px IBM Plex Mono, monospace';
    dCtx.fillStyle = '#888899';
    dCtx.textAlign = 'center';
    dCtx.fillText(`Observed scores if true score = ${trueScore}`, W / 2, 16);

    // Legend
    dCtx.font = '9px IBM Plex Mono, monospace';
    dCtx.textAlign = 'left';
    dCtx.fillStyle = '#0d8a74';
    dCtx.fillText(`true score = ${trueScore}`, toX(trueScore) + 6, PAD_T + 14);

    // 68%/95% labels
    const lo68x = Math.max(xMin, lo68);
    const hi68x = Math.min(xMax, hi68);
    dCtx.fillStyle = 'rgba(200,60,90,0.9)';
    dCtx.textAlign = 'center';
    dCtx.fillText('68%', toX((lo68x + hi68x) / 2), PAD_T + ph - 8);
  }

  // ── Attenuation curve ─────────────────────────────────────────────────────
  function drawAttenuation(alpha) {
    const W = attCanvas.width / dpr;
    const H = attCanvas.height / dpr;
    aCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    aCtx.clearRect(0, 0, W, H);

    const PAD_L = 48, PAD_R = 16, PAD_T = 28, PAD_B = 40;
    const pw = W - PAD_L - PAD_R;
    const ph = H - PAD_T - PAD_B;

    function toX(a) { return PAD_L + (a - 0.4) / (1.0 - 0.4) * pw; }
    function toY(r) { return PAD_T + ph - r * ph; }

    // Grid
    aCtx.strokeStyle = '#e4e4f0'; aCtx.lineWidth = 0.5;
    for (let r = 0; r <= 1.01; r += 0.25) {
      aCtx.beginPath(); aCtx.moveTo(PAD_L, toY(r)); aCtx.lineTo(PAD_L + pw, toY(r)); aCtx.stroke();
    }
    for (let a = 0.4; a <= 1.01; a += 0.1) {
      aCtx.beginPath(); aCtx.moveTo(toX(a), PAD_T); aCtx.lineTo(toX(a), PAD_T + ph); aCtx.stroke();
    }

    // True r curves: 0.30, 0.50, 0.70
    const trueRs = [0.30, 0.50, 0.70];
    const rColors = ['#6d28d9', '#c2640a', '#0d8a74'];
    const rLabels = ['true r = 0.30', 'true r = 0.50', 'true r = 0.70'];

    for (let ri = 0; ri < trueRs.length; ri++) {
      const trueR = trueRs[ri];
      aCtx.beginPath();
      for (let ai = 0; ai <= 200; ai++) {
        const a = 0.4 + (1.0 - 0.4) * ai / 200;
        // attenuation: observed r = true_r * alpha (both measures same alpha)
        const obsR = trueR * a;
        const x = toX(a), y = toY(obsR);
        ai === 0 ? aCtx.moveTo(x, y) : aCtx.lineTo(x, y);
      }
      aCtx.strokeStyle = rColors[ri]; aCtx.lineWidth = 1.8;
      aCtx.setLineDash(ri === 2 ? [] : ri === 1 ? [6, 3] : [3, 3]);
      aCtx.stroke(); aCtx.setLineDash([]);
    }

    // Current alpha vertical marker
    const ax = toX(alpha);
    aCtx.beginPath(); aCtx.moveTo(ax, PAD_T); aCtx.lineTo(ax, PAD_T + ph);
    aCtx.strokeStyle = 'rgba(200,60,90,0.6)'; aCtx.lineWidth = 1.5;
    aCtx.setLineDash([4, 3]); aCtx.stroke(); aCtx.setLineDash([]);

    // Dots at intersection
    for (let ri = 0; ri < trueRs.length; ri++) {
      const obsR = trueRs[ri] * alpha;
      aCtx.beginPath(); aCtx.arc(ax, toY(obsR), 4, 0, Math.PI * 2);
      aCtx.fillStyle = rColors[ri]; aCtx.fill();
    }

    // Axes
    aCtx.strokeStyle = '#c0c0d8'; aCtx.lineWidth = 1;
    aCtx.beginPath(); aCtx.moveTo(PAD_L, PAD_T + ph); aCtx.lineTo(PAD_L + pw, PAD_T + ph); aCtx.stroke();
    aCtx.beginPath(); aCtx.moveTo(PAD_L, PAD_T); aCtx.lineTo(PAD_L, PAD_T + ph); aCtx.stroke();

    // X-axis ticks and labels
    aCtx.font = '9px IBM Plex Mono, monospace';
    aCtx.fillStyle = '#888899';
    aCtx.textAlign = 'center';
    for (let a = 0.4; a <= 1.01; a += 0.1) {
      const sx = toX(a);
      aCtx.beginPath(); aCtx.moveTo(sx, PAD_T + ph); aCtx.lineTo(sx, PAD_T + ph + 4);
      aCtx.strokeStyle = '#c0c0d8'; aCtx.lineWidth = 1; aCtx.stroke();
      aCtx.fillText(a.toFixed(1), sx, PAD_T + ph + 16);
    }

    // Y-axis ticks and labels
    aCtx.textAlign = 'right';
    for (let r = 0; r <= 1.01; r += 0.25) {
      const sy = toY(r);
      aCtx.beginPath(); aCtx.moveTo(PAD_L, sy); aCtx.lineTo(PAD_L - 4, sy);
      aCtx.strokeStyle = '#c0c0d8'; aCtx.lineWidth = 1; aCtx.stroke();
      aCtx.fillText(r.toFixed(2), PAD_L - 7, sy + 3);
    }

    // Axis labels
    aCtx.textAlign = 'center';
    aCtx.fillText("Cronbach's α", PAD_L + pw / 2, PAD_T + ph + 30);
    aCtx.save();
    aCtx.translate(13, PAD_T + ph / 2);
    aCtx.rotate(-Math.PI / 2);
    aCtx.fillText('Observed r', 0, 0);
    aCtx.restore();

    // Legend — bottom-right
    const legX = PAD_L + pw - 4;
    const legY = PAD_T + ph - 14;
    for (let ri = trueRs.length - 1; ri >= 0; ri--) {
      const ly = legY - ri * 16;
      aCtx.strokeStyle = rColors[ri]; aCtx.lineWidth = 1.8;
      aCtx.setLineDash(ri === 2 ? [] : ri === 1 ? [6, 3] : [3, 3]);
      aCtx.beginPath(); aCtx.moveTo(legX - 48, ly); aCtx.lineTo(legX - 28, ly); aCtx.stroke();
      aCtx.setLineDash([]);
      aCtx.fillStyle = rColors[ri]; aCtx.font = '9px IBM Plex Mono, monospace'; aCtx.textAlign = 'right';
      aCtx.fillText(rLabels[ri], legX, ly + 3);
    }

    // Title
    aCtx.font = 'bold 10px IBM Plex Mono, monospace';
    aCtx.fillStyle = '#888899';
    aCtx.textAlign = 'center';
    aCtx.fillText('Correlation attenuation (observed r = true r × α)', W / 2, 16);
  }

  // ── Stats update ──────────────────────────────────────────────────────────
  function updateStats(alpha, trueScore, sd) {
    const sem = sd * Math.sqrt(1 - alpha);
    const ci68 = 2 * sem;
    const ci95 = 2 * 1.96 * sem;
    const rMaxSame = alpha; // max observable r if both measures have same alpha

    document.getElementById('ca_sem_val').textContent = sem.toFixed(2);
    document.getElementById('ca_ci68_val').textContent = ci68.toFixed(1);
    document.getElementById('ca_ci95_val').textContent = ci95.toFixed(1);
    document.getElementById('ca_ratt_val').textContent = rMaxSame.toFixed(2);

    const warn = alpha < 0.7;
    const ok   = alpha >= 0.9;

    for (const id of ['ca_sem_card', 'ca_ci68_card', 'ca_ci95_card', 'ca_ratt_card']) {
      const el = document.getElementById(id);
      el.classList.toggle('warn', warn);
      el.classList.toggle('ok', ok && !warn);
    }
    for (const id of ['ca_sem_val', 'ca_ci68_val', 'ca_ci95_val', 'ca_ratt_val']) {
      const el = document.getElementById(id);
      el.classList.toggle('warn', warn);
    }

    const interpEl = document.getElementById('ca_interp');
    const lo95 = Math.max(0, trueScore - 1.96 * sem).toFixed(0);
    const hi95 = Math.min(100, trueScore + 1.96 * sem).toFixed(0);
    let msg = '';
    if (alpha >= 0.90) {
      msg = `<span class="ok">Good reliability (α = ${alpha.toFixed(2)}).</span> A score of ${trueScore} yields a 95% CI of [${lo95}, ${hi95}] — a width of ${ci95.toFixed(1)} points. Suitable for individual high-stakes decisions.`;
    } else if (alpha >= 0.70) {
      msg = `<span style="color:#c2640a;font-weight:600">Acceptable for research (α = ${alpha.toFixed(2)}).</span> A score of ${trueScore} yields a 95% CI of [${lo95}, ${hi95}] — a width of ${ci95.toFixed(1)} points. Use caution for individual decisions.`;
    } else {
      msg = `<span class="hl">Poor reliability (α = ${alpha.toFixed(2)}).</span> A score of ${trueScore} yields a 95% CI of [${lo95}, ${hi95}] — a width of ${ci95.toFixed(1)} points. Do not use for individual-level interpretation.`;
    }
    interpEl.innerHTML = msg;
    interpEl.classList.toggle('warn', alpha < 0.70);
  }

  // ── Resize + render ───────────────────────────────────────────────────────
  function resizeCanvases() {
    dpr = window.devicePixelRatio || 1;
    for (const c of [scoreCanvas, distCanvas, attCanvas]) {
      const rect = c.getBoundingClientRect();
      if (rect.width > 0) {
        c.width = rect.width * dpr;
        // keep explicit height for score and dist; attCanvas self-governs
      }
    }
  }

  function update() {
    const alpha = parseFloat(document.getElementById('ca_alpha').value);
    const trueScore = parseFloat(document.getElementById('ca_true').value);
    const sd = parseFloat(document.getElementById('ca_sd').value);

    document.getElementById('ca_alpha_val').textContent = alpha.toFixed(2);
    document.getElementById('ca_true_val').textContent = trueScore.toFixed(0);
    document.getElementById('ca_sd_val').textContent = sd.toFixed(0);

    updateStats(alpha, trueScore, sd);
    drawScore(alpha, trueScore, sd);
    drawDist(alpha, trueScore, sd);
    drawAttenuation(alpha);
  }

  function resize() {
    resizeCanvases();
    update();
  }

  for (const id of ['ca_alpha', 'ca_true', 'ca_sd']) {
    document.getElementById(id).addEventListener('input', update);
  }

  window.addEventListener('resize', resize);
  requestAnimationFrame(() => requestAnimationFrame(resize));
})();
</script>
