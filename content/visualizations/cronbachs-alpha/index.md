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
  grid-template-columns: repeat(3, 1fr);
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
  display: flex;
  align-items: center;
  gap: 5px;
}
.ca-info-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 14px;
  height: 14px;
  padding: 0;
  border-radius: 50%;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.54rem;
  font-weight: 600;
  background: none;
  border: 1px solid var(--border);
  color: var(--secondary);
  cursor: pointer;
  flex-shrink: 0;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}
.ca-info-btn:hover {
  border-color: #0d8a74;
  color: #0d8a74;
}
.ca-modal-overlay {
  display: none;
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(60, 60, 80, 0.6);
  z-index: 1000;
  justify-content: center;
  align-items: center;
  padding: 20px;
}
.ca-modal-overlay.visible {
  display: flex;
}
.ca-modal {
  background: var(--theme);
  border: 1px solid var(--border);
  border-radius: 8px;
  max-width: 480px;
  width: 100%;
  max-height: 80vh;
  overflow-y: auto;
  padding: 24px 28px;
  position: relative;
}
.ca-modal h2 {
  font-family: 'Source Serif 4', serif;
  font-size: 1.1rem;
  color: var(--primary);
  margin-bottom: 4px;
  padding-right: 30px;
}
.ca-modal .ca-modal-badge {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.62rem;
  padding: 2px 7px;
  border-radius: 3px;
  background: rgba(13, 138, 116, 0.1);
  color: #0d8a74;
  display: inline-block;
  margin-bottom: 14px;
}
.ca-modal p {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.74rem;
  color: var(--secondary);
  line-height: 1.65;
  margin-bottom: 8px;
}
.ca-modal .formula {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.76rem;
  color: #0d8a74;
  background: rgba(13, 138, 116, 0.06);
  padding: 8px 12px;
  border-radius: 4px;
  margin: 10px 0;
  overflow-x: auto;
  white-space: nowrap;
}
.ca-modal .section-label {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.63rem;
  color: var(--secondary);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin-top: 16px;
  margin-bottom: 4px;
}
.ca-modal-close {
  position: absolute;
  top: 14px;
  right: 14px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 1.1rem;
  background: none;
  border: none;
  color: var(--secondary);
  cursor: pointer;
  padding: 4px 8px;
  line-height: 1;
}
.ca-modal-close:hover {
  color: var(--primary);
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
  display: flex;
  align-items: center;
  gap: 5px;
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
        <label>True score: <span class="ca-val" id="ca_true_val">100</span></label>
        <input type="range" id="ca_true" min="40" max="160" step="1" value="100">
      </div>
      <div class="ca-control-group">
        <label>Test SD (score units): <span class="ca-val" id="ca_sd_val">15</span></label>
        <input type="range" id="ca_sd" min="1" max="30" step="1" value="15">
      </div>
    </div>
    <div class="ca-stat-row">
      <div class="ca-stat" id="ca_sem_card">
        <div class="ca-stat-label">SEM (score units) <button class="ca-info-btn" onclick="caShowInfo('sem')" title="About SEM">?</button></div>
        <div class="ca-stat-value" id="ca_sem_val">—</div>
      </div>
      <div class="ca-stat" id="ca_ci68_card">
        <div class="ca-stat-label">68% true-score CI width <button class="ca-info-btn" onclick="caShowInfo('ci68')" title="About 68% CI">?</button></div>
        <div class="ca-stat-value" id="ca_ci68_val">—</div>
      </div>
      <div class="ca-stat" id="ca_ci95_card">
        <div class="ca-stat-label">95% true-score CI width <button class="ca-info-btn" onclick="caShowInfo('ci95')" title="About 95% CI">?</button></div>
        <div class="ca-stat-value" id="ca_ci95_val">—</div>
      </div>
    </div>
    <div class="ca-interp" id="ca_interp">—</div>
    <div class="ca-panels">
      <div class="ca-panel">
        <div class="ca-panel-label">Observed score → true-score CI <button class="ca-info-btn" onclick="caShowInfo('scorePanel')" title="About this panel">?</button></div>
        <canvas id="ca_score" height="290"></canvas>
      </div>
      <div class="ca-panel">
        <div class="ca-panel-label">Repeated testing distribution <button class="ca-info-btn" onclick="caShowInfo('distPanel')" title="About this panel">?</button></div>
        <canvas id="ca_dist" height="290"></canvas>
      </div>
    </div>
  </div>
  <p class="ca-note">
    <strong>SEM = SD × √(1 − α).</strong>
    The 95% true-score CI for an observed score X is [X − 1.96·SEM, X + 1.96·SEM].<br>
    Rules of thumb: α ≥ 0.90 for high-stakes individual decisions; α ≥ 0.70 for research/group comparisons.
  </p>
</div>

<div class="ca-modal-overlay" id="caModalOverlay" onclick="if(event.target===this)caCloseInfo()">
  <div class="ca-modal">
    <button class="ca-modal-close" onclick="caCloseInfo()">&times;</button>
    <h2 id="caModalTitle"></h2>
    <span class="ca-modal-badge" id="caModalBadge"></span>
    <div id="caModalBody"></div>
  </div>
</div>

<script>
(function () {
  let dpr = window.devicePixelRatio || 1;

  const scoreCanvas = document.getElementById('ca_score');
  const distCanvas  = document.getElementById('ca_dist');
  const sCtx = scoreCanvas.getContext('2d');
  const dCtx = distCanvas.getContext('2d');

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

    const xMin = 40, xMax = 160;
    function toX(v) { return PAD_L + (v - xMin) / (xMax - xMin) * pw; }

    // Axis
    sCtx.beginPath(); sCtx.moveTo(toX(xMin), midY); sCtx.lineTo(toX(xMax), midY);
    sCtx.strokeStyle = '#c0c0d8'; sCtx.lineWidth = 1; sCtx.stroke();

    // Tick marks
    sCtx.font = '9px IBM Plex Mono, monospace';
    sCtx.fillStyle = '#888899';
    sCtx.textAlign = 'center';
    for (let t = xMin; t <= xMax; t += 20) {
      const tx = toX(t);
      sCtx.beginPath(); sCtx.moveTo(tx, midY - 4); sCtx.lineTo(tx, midY + 4);
      sCtx.strokeStyle = '#c0c0d8'; sCtx.lineWidth = 1; sCtx.stroke();
      sCtx.fillText(t, tx, midY + 15);
    }

    // 95% CI band
    const lo95 = Math.max(xMin, trueScore - 1.96 * sem);
    const hi95 = Math.min(xMax, trueScore + 1.96 * sem);
    const lo68 = Math.max(xMin, trueScore - sem);
    const hi68 = Math.min(xMax, trueScore + sem);

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

    const xMin = trueScore - 4 * Math.max(sem, sd * 0.3);
    const xMax = trueScore + 4 * Math.max(sem, sd * 0.3);
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

  // ── Stats update ──────────────────────────────────────────────────────────
  function updateStats(alpha, trueScore, sd) {
    const sem = sd * Math.sqrt(1 - alpha);
    const ci68 = 2 * sem;
    const ci95 = 2 * 1.96 * sem;
    document.getElementById('ca_sem_val').textContent = sem.toFixed(2);
    document.getElementById('ca_ci68_val').textContent = ci68.toFixed(1);
    document.getElementById('ca_ci95_val').textContent = ci95.toFixed(1);

    const warn = alpha < 0.7;
    const ok   = alpha >= 0.9;

    for (const id of ['ca_sem_card', 'ca_ci68_card', 'ca_ci95_card']) {
      const el = document.getElementById(id);
      el.classList.toggle('warn', warn);
      el.classList.toggle('ok', ok && !warn);
    }
    for (const id of ['ca_sem_val', 'ca_ci68_val', 'ca_ci95_val']) {
      const el = document.getElementById(id);
      el.classList.toggle('warn', warn);
    }

    const interpEl = document.getElementById('ca_interp');
    const lo95 = (trueScore - 1.96 * sem).toFixed(0);
    const hi95 = (trueScore + 1.96 * sem).toFixed(0);
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
    for (const c of [scoreCanvas, distCanvas]) {
      const rect = c.getBoundingClientRect();
      if (rect.width > 0) {
        c.width = rect.width * dpr;
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

const caInfoContent = {
  sem: {
    title: 'Standard Error of Measurement',
    badge: 'SEM',
    body: `
      <p>The SEM quantifies how much an observed score is expected to differ from a person's true score due to measurement error alone. It is the standard deviation of the distribution of observed scores you would get if you tested the same person infinitely many times.</p>
      <div class="formula">SEM = SD &times; &radic;(1 &minus; &alpha;)</div>
      <p>where SD is the standard deviation of the test in the population and &alpha; is the reliability coefficient.</p>
      <div class="section-label">Interpretation</div>
      <p>A smaller SEM means higher measurement precision. At &alpha; = 1.00, SEM = 0 (no error). At &alpha; = 0.00, SEM equals the full test SD (observed scores are pure noise). The SEM is expressed in the same units as the test scores.</p>
      <div class="section-label">Why it matters</div>
      <p>The SEM is the building block for confidence intervals. Any single observed score is just one draw from a distribution centered on the true score, with spread equal to the SEM. Lower reliability widens this distribution, making individual scores less informative.</p>
    `
  },
  ci68: {
    title: '68% True-Score Confidence Interval',
    badge: '68% CI',
    body: `
      <p>The 68% CI gives the range within which a person's true score is expected to fall with roughly 68% probability, given their observed score. Its width equals two SEMs (one SEM above and below the observed score).</p>
      <div class="formula">68% CI width = 2 &times; SEM</div>
      <div class="section-label">Why 68%?</div>
      <p>In a normal distribution, approximately 68% of values fall within &plusmn;1 standard deviation of the mean. Since the SEM is the standard deviation of measurement error, &plusmn;1 SEM around an observed score captures about 68% of the true-score distribution.</p>
      <div class="section-label">Interpretation</div>
      <p>On an IQ-scale test (SD = 15) with &alpha; = 0.90, the SEM is about 4.7 points, so the 68% CI width is roughly 9.5 points. This means there is about a 1-in-3 chance the person's true score lies outside this range. For individual decisions, the wider 95% CI is usually preferred.</p>
    `
  },
  ci95: {
    title: '95% True-Score Confidence Interval',
    badge: '95% CI',
    body: `
      <p>The 95% CI gives the range within which a person's true score is expected to fall with approximately 95% probability. It extends &plusmn;1.96 SEMs around the observed score.</p>
      <div class="formula">95% CI width = 2 &times; 1.96 &times; SEM &asymp; 3.92 &times; SEM</div>
      <div class="section-label">Interpretation</div>
      <p>This is the interval most commonly reported in clinical and educational assessment. If the 95% CI is wide relative to meaningful score differences, individual scores cannot be interpreted with confidence.</p>
      <div class="section-label">Example</div>
      <p>On an IQ-scale test (SD = 15) with &alpha; = 0.90, the 95% CI width is about 18.6 points. A person scoring 110 has a 95% CI of roughly [101, 119]. With &alpha; = 0.70, that width balloons to about 32.3 points — nearly the entire range between "average" and "superior" classifications.</p>
      <div class="section-label">Clinical guideline</div>
      <p>&alpha; &ge; 0.90 is generally recommended for high-stakes individual decisions (diagnosis, placement). &alpha; &ge; 0.70 may suffice for group-level research comparisons where individual precision is less critical.</p>
    `
  },
  scorePanel: {
    title: 'Observed Score → True-Score CI',
    badge: 'Score scale',
    body: `
      <p>This panel shows a number line with the observed score marked as a point, surrounded by shaded bands representing the confidence intervals around it.</p>
      <div class="section-label">What the bands mean</div>
      <p>The darker inner band is the 68% CI (&plusmn;1 SEM). The lighter outer band is the 95% CI (&plusmn;1.96 SEM). These intervals represent the range of true scores that are plausible given the observed score and the test's reliability.</p>
      <div class="section-label">How to read it</div>
      <p>A narrow band means the test is precise — the observed score is a good estimate of the true score. A wide band means there is substantial measurement error, and the person's true ability could be meaningfully different from what was observed.</p>
      <div class="section-label">Clinical use</div>
      <p>When two people's CIs overlap substantially, their observed score difference may not reflect a real difference in ability. This is why reporting scores as intervals rather than points is standard practice in psychological assessment.</p>
    `
  },
  distPanel: {
    title: 'Repeated Testing Distribution',
    badge: 'Error distribution',
    body: `
      <p>This panel shows the distribution of observed scores you would expect if you tested the same person many times with parallel forms of the test. The curve is a normal distribution centered on the true score, with a standard deviation equal to the SEM.</p>
      <div class="section-label">What the curve shows</div>
      <p>The peak of the curve is at the true score. The spread is determined entirely by the SEM: lower reliability means a wider, flatter curve (more variable observed scores), while higher reliability produces a tall, narrow curve (observed scores cluster tightly around the truth).</p>
      <div class="section-label">The shaded regions</div>
      <p>The darker shading covers the central 68% of the distribution — the range within which most observed scores would fall. The lighter shading extends to 95%. Scores outside the 95% region would occur fewer than 1 in 20 times.</p>
      <div class="section-label">Intuition</div>
      <p>Think of this as the "noise" in the measurement process. Even if a person's true ability never changes, their observed scores will vary from one testing to the next. This panel makes that variability visible.</p>
    `
  }
};

function caShowInfo(key) {
  const info = caInfoContent[key];
  document.getElementById('caModalTitle').textContent = info.title;
  document.getElementById('caModalBadge').textContent = info.badge;
  document.getElementById('caModalBody').innerHTML = info.body;
  document.getElementById('caModalOverlay').classList.add('visible');
}

function caCloseInfo() {
  document.getElementById('caModalOverlay').classList.remove('visible');
}

document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape') caCloseInfo();
});
</script>
