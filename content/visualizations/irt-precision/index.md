---
title: "IRT Precision: How Test Information Shapes Measurement Error"
description: "Interactive visualization of how Item Response Theory determines measurement precision. Unlike Classical Test Theory, IRT precision varies across the trait continuum — explore how item parameters control where a test is most informative."
summary: "Explore how item discrimination, difficulty, and response categories shape the Test Information Function and local measurement precision in IRT, compared to the flat SEM of Classical Test Theory."
---

<style>
:root { --text: #c9cdd8; }
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');

.irt-wrap {
  font-family: 'IBM Plex Mono', monospace;
  --irt-wide: 1300px;
  width: var(--irt-wide);
  max-width: calc(100vw - 40px);
  margin-left: calc((100% - min(var(--irt-wide), 100vw - 40px)) / 2);
}
.irt-subtitle {
  font-family: 'Source Serif 4', Georgia, serif;
  font-size: 1.0rem;
  color: var(--secondary);
  margin-bottom: 21px;
  line-height: 1.6;
}
.irt-layout {
  display: flex;
  flex-direction: row;
  gap: 28px;
  align-items: stretch;
}
.irt-left {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 22px;
  min-width: 0;
}
.irt-right {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 0;
}
.irt-model-toggle {
  display: inline-flex;
  border-radius: 4px;
  overflow: hidden;
  border: 1px solid #2a2d3a;
}
.irt-toggle-btn {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.92rem;
  font-weight: 500;
  padding: 6px 19px;
  border: none;
  background: #181a24;
  color: var(--secondary);
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}
.irt-toggle-btn.active {
  background: #2dd4bf;
  color: white;
}
.irt-toggle-btn:hover:not(.active) {
  background: #2a2d3a;
}
.irt-controls {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px 23px;
  font-size: 0.92rem;
}
.irt-control-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.irt-control-group label { color: var(--secondary); }
.irt-val { color: #2dd4bf; font-weight: 600; }
.irt-controls input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: #2a2d3a;
  border-radius: 2px;
  outline: none;
  cursor: pointer;
}
.irt-controls input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #2dd4bf;
  cursor: pointer;
}
.irt-controls input[type="range"]::-moz-range-thumb {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #2dd4bf;
  cursor: pointer;
  border: none;
}
.irt-stat-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
}
.irt-stat {
  background: #181a24;
  border-radius: 5px;
  padding: 9px 12px;
  border-left: 3px solid #2a2d3a;
  transition: border-color 0.3s;
}
.irt-stat.warn { border-left-color: #ef4444; }
.irt-stat.ok   { border-left-color: #2dd4bf; }
.irt-stat-label {
  font-size: 0.82rem;
  color: var(--secondary);
  margin-bottom: 2px;
  line-height: 1.3;
  display: flex;
  align-items: center;
  gap: 5px;
}
.irt-info-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 14px;
  height: 14px;
  padding: 0;
  border-radius: 50%;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.72rem;
  font-weight: 600;
  background: none;
  border: 1px solid var(--border);
  color: var(--secondary);
  cursor: pointer;
  flex-shrink: 0;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}
.irt-info-btn:hover {
  border-color: #2dd4bf;
  color: #2dd4bf;
}
.irt-modal-overlay {
  display: none;
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(60, 60, 80, 0.6);
  z-index: 1000;
  justify-content: center;
  align-items: center;
  padding: 20px;
}
.irt-modal-overlay.visible {
  display: flex;
}
.irt-modal {
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
.irt-modal h2 {
  font-family: 'Source Serif 4', serif;
  font-size: 1.3rem;
  color: var(--primary);
  margin-bottom: 4px;
  padding-right: 30px;
}
.irt-modal .irt-modal-badge {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.82rem;
  padding: 2px 8px;
  border-radius: 3px;
  background: rgba(45, 212, 191, 0.1);
  color: #2dd4bf;
  display: inline-block;
  margin-bottom: 14px;
}
.irt-modal p {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.94rem;
  color: var(--secondary);
  line-height: 1.65;
  margin-bottom: 8px;
}
.irt-modal .formula {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.96rem;
  color: #2dd4bf;
  background: rgba(45, 212, 191, 0.06);
  padding: 8px 12px;
  border-radius: 4px;
  margin: 10px 0;
  overflow-x: auto;
  white-space: nowrap;
}
.irt-modal .section-label {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.83rem;
  color: var(--secondary);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin-top: 16px;
  margin-bottom: 4px;
}
.irt-modal-close {
  position: absolute;
  top: 14px;
  right: 14px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 1.3rem;
  background: none;
  border: none;
  color: var(--secondary);
  cursor: pointer;
  padding: 4px 8px;
  line-height: 1;
}
.irt-modal-close:hover {
  color: var(--primary);
}
.irt-stat-value {
  font-size: 1.25rem;
  font-weight: 600;
  color: #2dd4bf;
  transition: color 0.3s;
}
.irt-stat-value.warn { color: #ef4444; }
.irt-right-spacer {
  flex-shrink: 0;
}
/* panels are now direct children of .irt-right */
.irt-panel {
  display: flex;
  flex-direction: column;
  gap: 6px;
  flex: 1;
  min-height: 0;
}
.irt-panel-label {
  font-size: 0.9rem;
  color: var(--secondary);
  text-transform: uppercase;
  letter-spacing: 0.07em;
  display: flex;
  align-items: center;
  gap: 5px;
}
.irt-panel canvas, .irt-score-bar canvas {
  display: block;
  width: 100%;
  border-radius: 6px;
  background: #181a24;
}
.irt-score-bar canvas { height: 180px; }
.irt-panel canvas { flex: 1; min-height: 200px; }
.irt-interp {
  font-size: 0.92rem;
  color: var(--secondary);
  line-height: 1.6;
  padding: 8px 10px;
  background: #181a24;
  border-radius: 5px;
  border-left: 3px solid #2a2d3a;
  transition: border-color 0.3s;
  min-height: 2.8em;
}
.irt-interp.warn { border-left-color: #ef4444; }
.irt-interp span.hl { color: #ef4444; font-weight: 600; }
.irt-interp span.ok { color: #2dd4bf; font-weight: 600; }
.irt-note {
  font-size: 0.88rem;
  color: var(--secondary);
  line-height: 1.6;
  margin-top: 4px;
}
@media (max-width: 900px) {
  .irt-wrap {
    --irt-wide: 100%;
    margin-left: 0;
  }
  .irt-layout { flex-direction: column; }
}
@media (max-width: 600px) {
  .irt-controls { grid-template-columns: 1fr; }
  .irt-stat-row  { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 400px) {
  .irt-stat-row  { grid-template-columns: 1fr; }
}
</style>

<div class="irt-wrap">
  <p class="irt-subtitle">
    In IRT, measurement precision is <strong>not constant</strong> — it depends on where a person falls on the latent trait.
    The <strong>Test Information Function</strong> I(&theta;) determines the local Standard Error: SE(&theta;) = 1/&radic;I(&theta;).
    A test can be highly reliable at one trait level and nearly useless at another.
  </p>
  <div class="irt-layout">
    <div class="irt-left">
      <div class="irt-controls">
        <div class="irt-control-group">
          <label>Number of items: <span class="irt-val" id="irt_nitems_val">10</span></label>
          <input type="range" id="irt_nitems" min="5" max="30" step="1" value="10">
        </div>
        <div class="irt-control-group">
          <label>&theta; (person's trait): <span class="irt-val" id="irt_theta_val">0.0</span></label>
          <input type="range" id="irt_theta" min="-3.0" max="3.0" step="0.1" value="0.0">
        </div>
        <div class="irt-control-group">
          <label>Avg discrimination (a): <span class="irt-val" id="irt_avgdisc_val">1.5</span></label>
          <input type="range" id="irt_avgdisc" min="0.5" max="3.0" step="0.1" value="1.5">
        </div>
        <div class="irt-control-group">
          <label>Avg difficulty (b): <span class="irt-val" id="irt_avgdiff_val">0.0</span></label>
          <input type="range" id="irt_avgdiff" min="-2.0" max="2.0" step="0.1" value="0.0">
        </div>
        <div class="irt-control-group" id="irt_cat_group" style="display:none">
          <label>Response categories: <span class="irt-val" id="irt_ncat_val">5</span></label>
          <input type="range" id="irt_ncat" min="2" max="7" step="1" value="5">
        </div>
      </div>
      <div class="irt-stat-row">
        <div class="irt-stat" id="irt_se_card">
          <div class="irt-stat-label">SE(&theta;) <button class="irt-info-btn" onclick="irtShowInfo('seTheta')" title="About SE(θ)">?</button></div>
          <div class="irt-stat-value" id="irt_se_val">&mdash;</div>
        </div>
        <div class="irt-stat" id="irt_ci68_card">
          <div class="irt-stat-label">68% CI width <button class="irt-info-btn" onclick="irtShowInfo('ci68')" title="About 68% CI">?</button></div>
          <div class="irt-stat-value" id="irt_ci68_val">&mdash;</div>
        </div>
        <div class="irt-stat" id="irt_ci95_card">
          <div class="irt-stat-label">95% CI width <button class="irt-info-btn" onclick="irtShowInfo('ci95')" title="About 95% CI">?</button></div>
          <div class="irt-stat-value" id="irt_ci95_val">&mdash;</div>
        </div>
      </div>
      <div class="irt-score-bar">
        <canvas id="irt_scorebar" height="180"></canvas>
      </div>
      <div class="irt-interp" id="irt_interp">&mdash;</div>
    </div>
    <div class="irt-right">
      <div class="irt-right-spacer" id="irt_right_spacer"></div>
      <div class="irt-panel">
        <div class="irt-panel-label">Test information function <button class="irt-info-btn" onclick="irtShowInfo('tifPanel')" title="About this panel">?</button></div>
        <canvas id="irt_info"></canvas>
      </div>
    </div>
  </div>
  <p class="irt-note">
    <strong>I(&theta;) = &sum; a<sub>i</sub>&sup2; P<sub>i</sub>(&theta;) Q<sub>i</sub>(&theta;)</strong> (2PL). &ensp;
    <strong>SE(&theta;) = 1 / &radic;I(&theta;).</strong> &ensp;
    Local reliability &rho;(&theta;) = 1 &minus; 1/I(&theta;) when &sigma;&sup2; = 1.<br>
    Unlike Cronbach's &alpha;, IRT precision varies across the trait continuum: a test is most precise where information peaks.
  </p>
</div>

<div class="irt-modal-overlay" id="irtModalOverlay" onclick="if(event.target===this)irtCloseInfo()">
  <div class="irt-modal">
    <button class="irt-modal-close" onclick="irtCloseInfo()">&times;</button>
    <h2 id="irtModalTitle"></h2>
    <span class="irt-modal-badge" id="irtModalBadge"></span>
    <div id="irtModalBody"></div>
  </div>
</div>

<script>
(function () {
  let dpr = window.devicePixelRatio || 1;
  let currentModel = '2pl';

  const scoreBarCanvas = document.getElementById('irt_scorebar');
  const infoCanvas = document.getElementById('irt_info');
  const sbCtx = scoreBarCanvas.getContext('2d');
  const iCtx = infoCanvas.getContext('2d');

  // ── IRT math ───────────────────────────────────────────────────────────────

  function generateItems(nItems, avgA, avgB, nCat, model) {
    const items = [];
    for (let i = 0; i < nItems; i++) {
      const t = nItems > 1 ? i / (nItems - 1) : 0.5;
      const a = Math.max(0.3, avgA);
      if (model === '2pl') {
        const b = avgB + 1.5 * (2 * t - 1);
        items.push({ a, bs: [b] });
      } else {
        const nThresh = nCat - 1;
        const itemShift = 1.5 * (2 * t - 1);
        const bs = [];
        for (let k = 0; k < nThresh; k++) {
          bs.push(avgB + itemShift + 1.0 * (k - (nThresh - 1) / 2));
        }
        items.push({ a, bs });
      }
    }
    return items;
  }

  function itemInfo2PL(theta, a, b) {
    const p = 1 / (1 + Math.exp(-a * (theta - b)));
    return a * a * p * (1 - p);
  }

  function itemInfoGRM(theta, a, bs) {
    const nCat = bs.length + 1;
    const pStar = [1];
    const dpStar = [0];
    for (let k = 0; k < bs.length; k++) {
      const pk = 1 / (1 + Math.exp(-a * (theta - bs[k])));
      pStar.push(pk);
      dpStar.push(a * pk * (1 - pk));
    }
    pStar.push(0);
    dpStar.push(0);
    let info = 0;
    for (let k = 0; k < nCat; k++) {
      const Pk = pStar[k] - pStar[k + 1];
      const dPk = dpStar[k] - dpStar[k + 1];
      if (Pk > 1e-10) info += (dPk * dPk) / Pk;
    }
    return info;
  }

  function testInfo(theta, items, model) {
    let I = 0;
    for (const item of items) {
      I += model === '2pl' ? itemInfo2PL(theta, item.a, item.bs[0]) : itemInfoGRM(theta, item.a, item.bs);
    }
    return I;
  }

  function se(theta, items, model) {
    const I = testInfo(theta, items, model);
    return I > 0 ? 1 / Math.sqrt(I) : 10;
  }

  function localRel(theta, items, model) {
    const I = testInfo(theta, items, model);
    return I > 1 ? 1 - 1 / I : 0;
  }

  function thetaToT(theta) { return 50 + 10 * theta; }

  // ── Score bar ──────────────────────────────────────────────────────────────

  function drawScoreBar(theta, seVal, items, model) {
    const W = scoreBarCanvas.width / dpr;
    const H = scoreBarCanvas.height / dpr;
    sbCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    sbCtx.clearRect(0, 0, W, H);

    const PAD_L = 30, PAD_R = 30, PAD_T = 40, PAD_B = 44;
    const pw = W - PAD_L - PAD_R;
    const midY = PAD_T + (H - PAD_T - PAD_B) / 2;

    const xMin = -3, xMax = 3;
    function toX(v) { return PAD_L + (v - xMin) / (xMax - xMin) * pw; }

    // Axis
    sbCtx.beginPath(); sbCtx.moveTo(toX(xMin), midY); sbCtx.lineTo(toX(xMax), midY);
    sbCtx.strokeStyle = '#2a2d3a'; sbCtx.lineWidth = 1; sbCtx.stroke();

    // Theta ticks
    sbCtx.font = '12px IBM Plex Mono, monospace';
    sbCtx.fillStyle = '#6b7084';
    sbCtx.textAlign = 'center';
    for (let t = -3; t <= 3; t += 1) {
      const tx = toX(t);
      sbCtx.beginPath(); sbCtx.moveTo(tx, midY - 5); sbCtx.lineTo(tx, midY + 5);
      sbCtx.strokeStyle = '#2a2d3a'; sbCtx.lineWidth = 1; sbCtx.stroke();
      sbCtx.fillText(t, tx, midY + 20);
    }

    // T-score labels below
    sbCtx.fillStyle = '#aaaabc';
    sbCtx.font = '10px IBM Plex Mono, monospace';
    for (let t = -3; t <= 3; t += 1) {
      sbCtx.fillText('T=' + thetaToT(t), toX(t), midY + 34);
    }

    // CI bands
    const lo95 = Math.max(xMin, theta - 1.96 * seVal);
    const hi95 = Math.min(xMax, theta + 1.96 * seVal);
    const lo68 = Math.max(xMin, theta - seVal);
    const hi68 = Math.min(xMax, theta + seVal);
    const bandH = 20;

    sbCtx.fillStyle = 'rgba(200,60,90,0.10)';
    sbCtx.fillRect(toX(lo95), midY - bandH, toX(hi95) - toX(lo95), bandH * 2);
    sbCtx.fillStyle = 'rgba(200,60,90,0.22)';
    sbCtx.fillRect(toX(lo68), midY - bandH, toX(hi68) - toX(lo68), bandH * 2);

    // 95% bracket
    sbCtx.strokeStyle = 'rgba(200,60,90,0.55)'; sbCtx.lineWidth = 1.5; sbCtx.setLineDash([4,3]);
    sbCtx.beginPath(); sbCtx.moveTo(toX(lo95), midY - bandH - 8); sbCtx.lineTo(toX(hi95), midY - bandH - 8); sbCtx.stroke();
    sbCtx.setLineDash([]);
    sbCtx.beginPath(); sbCtx.moveTo(toX(lo95), midY - bandH - 14); sbCtx.lineTo(toX(lo95), midY - bandH - 2); sbCtx.stroke();
    sbCtx.beginPath(); sbCtx.moveTo(toX(hi95), midY - bandH - 14); sbCtx.lineTo(toX(hi95), midY - bandH - 2); sbCtx.stroke();

    // 95% label
    sbCtx.font = '11px IBM Plex Mono, monospace';
    sbCtx.fillStyle = 'rgba(200,60,90,0.8)';
    sbCtx.textAlign = 'center';
    sbCtx.fillText('95% CI', toX((lo95 + hi95) / 2), midY - bandH - 16);

    // Theta marker
    const tsx = toX(theta);
    sbCtx.beginPath(); sbCtx.moveTo(tsx, midY - bandH - 2); sbCtx.lineTo(tsx, midY + bandH + 2);
    sbCtx.strokeStyle = '#2dd4bf'; sbCtx.lineWidth = 2.5; sbCtx.stroke();
    sbCtx.beginPath(); sbCtx.arc(tsx, midY, 6, 0, Math.PI * 2);
    sbCtx.fillStyle = '#2dd4bf'; sbCtx.fill();

    // Label
    sbCtx.font = '12px IBM Plex Mono, monospace';
    sbCtx.fillStyle = '#6b7084';
    sbCtx.textAlign = 'center';
    sbCtx.fillText(
      '\u03B8 = ' + theta.toFixed(1) + ' (T = ' + thetaToT(theta).toFixed(0) + ')  |  SE = ' + seVal.toFixed(2) + '  |  95% CI: [' + lo95.toFixed(2) + ', ' + hi95.toFixed(2) + ']',
      W / 2, H - 8
    );
  }

  // ── Information function panel ─────────────────────────────────────────────

  function drawInfoPanel(theta, items, model) {
    const W = infoCanvas.width / dpr;
    const H = infoCanvas.height / dpr;
    iCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    iCtx.clearRect(0, 0, W, H);

    const PAD_L = 52, PAD_R = 64, PAD_T = 32, PAD_B = 44;
    const pw = W - PAD_L - PAD_R;
    const ph = H - PAD_T - PAD_B;

    const xMin = -3, xMax = 3;
    const steps = 300;
    function toX(v) { return PAD_L + (v - xMin) / (xMax - xMin) * pw; }

    // Compute info and SE across range
    const infoVals = [];
    const seVals = [];
    let maxInfo = 0;
    for (let i = 0; i <= steps; i++) {
      const t = xMin + (xMax - xMin) * i / steps;
      const inf = testInfo(t, items, model);
      infoVals.push(inf);
      seVals.push(inf > 0 ? 1 / Math.sqrt(inf) : 10);
      if (inf > maxInfo) maxInfo = inf;
    }
    maxInfo = Math.max(maxInfo, 1);
    const maxSE = 2.0;

    function toYInfo(v) { return PAD_T + ph - (v / (maxInfo * 1.15)) * ph; }
    function toYSE(v) { return PAD_T + ph - (Math.min(v, maxSE) / maxSE) * ph; }

    // Grid
    iCtx.strokeStyle = '#1e2030'; iCtx.lineWidth = 0.5;
    for (let i = 0; i <= 6; i++) {
      const xv = xMin + (xMax - xMin) * i / 6;
      iCtx.beginPath(); iCtx.moveTo(toX(xv), PAD_T); iCtx.lineTo(toX(xv), PAD_T + ph); iCtx.stroke();
    }

    // Info curve fill
    iCtx.beginPath();
    iCtx.moveTo(toX(xMin), toYInfo(0));
    for (let i = 0; i <= steps; i++) {
      const t = xMin + (xMax - xMin) * i / steps;
      iCtx.lineTo(toX(t), toYInfo(infoVals[i]));
    }
    iCtx.lineTo(toX(xMax), toYInfo(0));
    iCtx.closePath();
    iCtx.fillStyle = 'rgba(45, 212, 191, 0.12)';
    iCtx.fill();

    // Info curve stroke
    iCtx.beginPath();
    for (let i = 0; i <= steps; i++) {
      const t = xMin + (xMax - xMin) * i / steps;
      const y = toYInfo(infoVals[i]);
      i === 0 ? iCtx.moveTo(toX(t), y) : iCtx.lineTo(toX(t), y);
    }
    iCtx.strokeStyle = '#2dd4bf'; iCtx.lineWidth = 2; iCtx.stroke();

    // SE curve (dashed, red)
    iCtx.beginPath();
    for (let i = 0; i <= steps; i++) {
      const t = xMin + (xMax - xMin) * i / steps;
      const y = toYSE(seVals[i]);
      i === 0 ? iCtx.moveTo(toX(t), y) : iCtx.lineTo(toX(t), y);
    }
    iCtx.strokeStyle = '#ef4444'; iCtx.lineWidth = 1.5; iCtx.setLineDash([5, 3]);
    iCtx.stroke(); iCtx.setLineDash([]);

    // Current theta vertical line
    const tsx = toX(theta);
    iCtx.beginPath(); iCtx.moveTo(tsx, PAD_T); iCtx.lineTo(tsx, PAD_T + ph);
    iCtx.strokeStyle = 'rgba(45, 212, 191, 0.5)'; iCtx.lineWidth = 1.5; iCtx.setLineDash([4, 3]);
    iCtx.stroke(); iCtx.setLineDash([]);

    // Readoff dots
    const curInfo = testInfo(theta, items, model);
    const curSE = curInfo > 0 ? 1 / Math.sqrt(curInfo) : 10;
    iCtx.beginPath(); iCtx.arc(tsx, toYInfo(curInfo), 4, 0, Math.PI * 2);
    iCtx.fillStyle = '#2dd4bf'; iCtx.fill();
    iCtx.beginPath(); iCtx.arc(tsx, toYSE(curSE), 4, 0, Math.PI * 2);
    iCtx.fillStyle = '#ef4444'; iCtx.fill();

    // Horizontal readoff lines
    iCtx.setLineDash([2, 3]);
    iCtx.beginPath(); iCtx.moveTo(tsx, toYInfo(curInfo)); iCtx.lineTo(PAD_L, toYInfo(curInfo));
    iCtx.strokeStyle = 'rgba(45, 212, 191, 0.4)'; iCtx.lineWidth = 1; iCtx.stroke();
    iCtx.beginPath(); iCtx.moveTo(tsx, toYSE(curSE)); iCtx.lineTo(PAD_L + pw, toYSE(curSE));
    iCtx.strokeStyle = 'rgba(200, 60, 90, 0.4)'; iCtx.lineWidth = 1; iCtx.stroke();
    iCtx.setLineDash([]);

    // Axes
    iCtx.strokeStyle = '#2a2d3a'; iCtx.lineWidth = 1;
    iCtx.beginPath(); iCtx.moveTo(PAD_L, PAD_T + ph); iCtx.lineTo(PAD_L + pw, PAD_T + ph); iCtx.stroke();
    iCtx.beginPath(); iCtx.moveTo(PAD_L, PAD_T); iCtx.lineTo(PAD_L, PAD_T + ph); iCtx.stroke();
    iCtx.beginPath(); iCtx.moveTo(PAD_L + pw, PAD_T); iCtx.lineTo(PAD_L + pw, PAD_T + ph); iCtx.stroke();

    // X-axis ticks
    iCtx.font = '13px IBM Plex Mono, monospace';
    iCtx.fillStyle = '#6b7084';
    iCtx.textAlign = 'center';
    for (let t = -3; t <= 3; t += 1) {
      const sx = toX(t);
      iCtx.beginPath(); iCtx.moveTo(sx, PAD_T + ph); iCtx.lineTo(sx, PAD_T + ph + 4);
      iCtx.strokeStyle = '#2a2d3a'; iCtx.lineWidth = 1; iCtx.stroke();
      iCtx.fillText(t, sx, PAD_T + ph + 20);
    }

    // Left Y-axis ticks (Info)
    iCtx.textAlign = 'right';
    iCtx.fillStyle = '#2dd4bf';
    const infoStep = maxInfo > 20 ? Math.ceil(maxInfo / 4) : maxInfo > 5 ? Math.ceil(maxInfo / 4) : Math.ceil(maxInfo * 10 / 4) / 10;
    for (let v = 0; v <= maxInfo * 1.1; v += infoStep) {
      if (v === 0) continue;
      const y = toYInfo(v);
      if (y < PAD_T) break;
      iCtx.fillText(v % 1 === 0 ? v.toFixed(0) : v.toFixed(1), PAD_L - 6, y + 3);
    }

    // Right Y-axis ticks (SE)
    iCtx.textAlign = 'left';
    iCtx.fillStyle = '#ef4444';
    for (let v = 0; v <= maxSE; v += 0.5) {
      if (v === 0) continue;
      const y = toYSE(v);
      iCtx.fillText(v.toFixed(1), PAD_L + pw + 6, y + 3);
    }

    // Axis labels
    iCtx.save();
    iCtx.translate(22, PAD_T + ph / 2);
    iCtx.rotate(-Math.PI / 2);
    iCtx.textAlign = 'center';
    iCtx.fillStyle = '#2dd4bf';
    iCtx.font = '13px IBM Plex Mono, monospace';
    iCtx.fillText('I(\u03B8)', 0, 0);
    iCtx.restore();

    iCtx.save();
    iCtx.translate(W - 18, PAD_T + ph / 2);
    iCtx.rotate(Math.PI / 2);
    iCtx.textAlign = 'center';
    iCtx.fillStyle = '#ef4444';
    iCtx.font = '13px IBM Plex Mono, monospace';
    iCtx.fillText('SE(\u03B8)', 0, 0);
    iCtx.restore();

    // Title
    iCtx.font = 'bold 13px IBM Plex Mono, monospace';
    iCtx.fillStyle = '#6b7084';
    iCtx.textAlign = 'center';
    iCtx.fillText('Test Information (solid) & SE (dashed)', W / 2, 18);

    // X-axis label
    iCtx.font = '13px IBM Plex Mono, monospace';
    iCtx.fillStyle = '#6b7084';
    iCtx.textAlign = 'center';
    iCtx.fillText('\u03B8', PAD_L + pw / 2, H - 4);
  }

  // ── Stats + interpretation ─────────────────────────────────────────────────

  function updateStats(theta, seVal, rho) {
    const ci68 = 2 * seVal;
    const ci95 = 2 * 1.96 * seVal;
    const tSE = (seVal * 10).toFixed(1);

    document.getElementById('irt_se_val').textContent = seVal.toFixed(2) + ' (T: ' + tSE + ')';
    document.getElementById('irt_ci68_val').textContent = ci68.toFixed(2) + ' (T: ' + (ci68 * 10).toFixed(1) + ')';
    document.getElementById('irt_ci95_val').textContent = ci95.toFixed(2) + ' (T: ' + (ci95 * 10).toFixed(1) + ')';

    const warn = rho < 0.7;
    const ok = rho >= 0.9;
    for (const id of ['irt_se_card', 'irt_ci68_card', 'irt_ci95_card']) {
      const el = document.getElementById(id);
      el.classList.toggle('warn', warn);
      el.classList.toggle('ok', ok && !warn);
    }
    for (const id of ['irt_se_val', 'irt_ci68_val', 'irt_ci95_val']) {
      document.getElementById(id).classList.toggle('warn', warn);
    }

    const interpEl = document.getElementById('irt_interp');
    const ci95lo = (theta - 1.96 * seVal).toFixed(2);
    const ci95hi = (theta + 1.96 * seVal).toFixed(2);
    const tScore = thetaToT(theta).toFixed(0);
    let msg = '';
    if (rho >= 0.90) {
      msg = '<span class="ok">High local precision (\u03C1 = ' + rho.toFixed(2) + ', \u03B1-equivalent).</span> At \u03B8 = ' + theta.toFixed(1) + ' (T = ' + tScore + '), SE = ' + seVal.toFixed(2) + '. 95% CI: [' + ci95lo + ', ' + ci95hi + ']. The test is highly informative at this trait level.';
    } else if (rho >= 0.70) {
      msg = '<span style="color:#c2640a;font-weight:600">Moderate local precision (\u03C1 = ' + rho.toFixed(2) + ').</span> At \u03B8 = ' + theta.toFixed(1) + ' (T = ' + tScore + '), SE = ' + seVal.toFixed(2) + '. 95% CI: [' + ci95lo + ', ' + ci95hi + ']. Adequate for group comparisons but use caution for individual decisions at this trait level.';
    } else {
      msg = '<span class="hl">Low local precision (\u03C1 = ' + rho.toFixed(2) + ').</span> At \u03B8 = ' + theta.toFixed(1) + ' (T = ' + tScore + '), SE = ' + seVal.toFixed(2) + '. 95% CI: [' + ci95lo + ', ' + ci95hi + ']. The test provides little information at this trait level \u2014 the information function peaks elsewhere.';
    }
    interpEl.innerHTML = msg;
    interpEl.classList.toggle('warn', rho < 0.70);
  }

  // ── Model toggle ───────────────────────────────────────────────────────────

  window.irtSetModel = function(model) {
    currentModel = model;
    document.getElementById('irt_btn_2pl').classList.toggle('active', model === '2pl');
    document.getElementById('irt_btn_grm').classList.toggle('active', model === 'grm');
    document.getElementById('irt_cat_group').style.display = model === 'grm' ? '' : 'none';
    update();
  };

  // ── Resize + render ────────────────────────────────────────────────────────

  function resizeCanvases() {
    dpr = window.devicePixelRatio || 1;
    for (const c of [scoreBarCanvas, infoCanvas]) {
      const rect = c.getBoundingClientRect();
      if (rect.width > 0) {
        c.width = rect.width * dpr;
        c.height = rect.height * dpr;
      }
    }
  }

  function update() {
    const nItems = parseInt(document.getElementById('irt_nitems').value);
    const avgDisc = parseFloat(document.getElementById('irt_avgdisc').value);
    const avgDiff = parseFloat(document.getElementById('irt_avgdiff').value);
    const nCat = parseInt(document.getElementById('irt_ncat').value);
    const theta = parseFloat(document.getElementById('irt_theta').value);

    document.getElementById('irt_nitems_val').textContent = nItems;
    document.getElementById('irt_avgdisc_val').textContent = avgDisc.toFixed(1);
    document.getElementById('irt_avgdiff_val').textContent = avgDiff.toFixed(1);
    document.getElementById('irt_ncat_val').textContent = nCat;
    document.getElementById('irt_theta_val').textContent = theta.toFixed(1);

    const items = generateItems(nItems, avgDisc, avgDiff, currentModel === '2pl' ? 2 : nCat, currentModel);
    const seVal = se(theta, items, currentModel);
    const rho = localRel(theta, items, currentModel);

    updateStats(theta, seVal, rho);
    drawScoreBar(theta, seVal, items, currentModel);
    drawInfoPanel(theta, items, currentModel);
  }

  function syncSpacer() {
    const controls = document.querySelector('.irt-controls');
    const spacer = document.getElementById('irt_right_spacer');
    const panelLabel = document.querySelector('.irt-panel-label');
    if (controls && spacer && panelLabel) {
      // Subtract the panel label height + panel gap (6px) so the canvas box aligns with the stat cards
      const labelOffset = panelLabel.offsetHeight + 6;
      spacer.style.height = Math.max(0, controls.offsetHeight - labelOffset + 5) + 'px';
    }
  }

  function resize() {
    syncSpacer();
    resizeCanvases();
    update();
  }

  for (const id of ['irt_nitems', 'irt_avgdisc', 'irt_avgdiff', 'irt_ncat', 'irt_theta']) {
    document.getElementById(id).addEventListener('input', update);
  }

  window.addEventListener('resize', resize);
  requestAnimationFrame(function() { requestAnimationFrame(resize); });
})();

// ── Info modals ──────────────────────────────────────────────────────────────

const irtInfoContent = {
  seTheta: {
    title: 'Standard Error SE(\u03B8)',
    badge: 'SE',
    body: '<p>In IRT, the Standard Error at a given trait level \u03B8 is determined by the Test Information Function:</p>' +
      '<div class="formula">SE(\u03B8) = 1 / \u221AI(\u03B8)</div>' +
      '<p>Unlike the SEM in Classical Test Theory, which is a single number for the entire test, SE(\u03B8) <strong>varies across the trait continuum</strong>. The test is most precise (lowest SE) where information is highest, and least precise at the extremes.</p>' +
      '<div class="section-label">Comparison to CTT</div>' +
      '<p>In CTT, SEM = SD \u00D7 \u221A(1 \u2212 \u03B1) is constant for all examinees. IRT reveals that this "average" hides systematic variation: a personality scale might measure average levels well but be imprecise for extreme scorers. This is the fundamental advantage of IRT over CTT.</p>' +
      '<div class="section-label">Interpretation</div>' +
      '<p>An SE of 0.30 means that if you tested the same person many times, their estimated \u03B8 values would have a standard deviation of about 0.30 around the true value. Smaller is better.</p>'
  },
  ci68: {
    title: '68% Confidence Interval',
    badge: '68% CI',
    body: '<p>The 68% CI gives the range within which the true \u03B8 falls with roughly 68% probability, given the estimated \u03B8. Its width equals two SEs (one SE above and below).</p>' +
      '<div class="formula">68% CI width = 2 \u00D7 SE(\u03B8)</div>' +
      '<div class="section-label">Key IRT insight</div>' +
      '<p>Because SE varies with \u03B8, the CI width is <strong>different at different trait levels</strong>. Move the \u03B8 slider and watch the CI expand or contract. In CTT, the CI is the same width everywhere \u2014 a simplification that IRT avoids.</p>'
  },
  ci95: {
    title: '95% Confidence Interval',
    badge: '95% CI',
    body: '<p>The 95% CI extends \u00B11.96 SEs around the estimated \u03B8.</p>' +
      '<div class="formula">95% CI width = 2 \u00D7 1.96 \u00D7 SE(\u03B8) \u2248 3.92 \u00D7 SE(\u03B8)</div>' +
      '<div class="section-label">Interpretation</div>' +
      '<p>This is the interval most commonly reported. If the 95% CI is wide (e.g., > 1.0 \u03B8 units = 10 T-score points), individual scores at this trait level cannot be interpreted with confidence.</p>' +
      '<div class="section-label">When to worry</div>' +
      '<p>Move \u03B8 to the tails (e.g., \u03B8 = \u00B12.5) and notice how the CI balloons. Most psychological scales lose precision at the extremes, which is exactly where clinical decisions are often made.</p>'
  },
  tifPanel: {
    title: 'Test Information Function',
    badge: 'I(\u03B8) & SE(\u03B8)',
    body: '<p>This panel shows two curves plotted against the trait \u03B8:</p>' +
      '<p><strong>Solid teal curve (left axis):</strong> The Test Information Function I(\u03B8), which is the sum of all item information functions. Higher values mean more precision.</p>' +
      '<p><strong>Dashed red curve (right axis):</strong> The Standard Error SE(\u03B8) = 1/\u221AI(\u03B8). This is the inverse \u2014 where information is high, SE is low, and vice versa.</p>' +
      '<div class="section-label">What shapes the curve</div>' +
      '<p><strong>Discrimination (a):</strong> Higher a values produce taller, narrower information peaks. Low-discrimination items contribute little information anywhere.</p>' +
      '<p><strong>Difficulty (b):</strong> Each item contributes most information near its difficulty parameter. Spreading difficulties across the \u03B8 range creates a broader, flatter information function.</p>' +
      '<p><strong>Number of items:</strong> More items = more total information (the curves stack additively).</p>' +
      '<div class="section-label">2PL vs GRM</div>' +
      '<p>In the 2PL model, each item peaks at its difficulty. In the GRM, each item contributes information across its threshold range, often producing a broader information peak per item. More response categories generally increase information.</p>'
  }
};

function irtShowInfo(key) {
  const info = irtInfoContent[key];
  document.getElementById('irtModalTitle').textContent = info.title;
  document.getElementById('irtModalBadge').textContent = info.badge;
  document.getElementById('irtModalBody').innerHTML = info.body;
  document.getElementById('irtModalOverlay').classList.add('visible');
}

function irtCloseInfo() {
  document.getElementById('irtModalOverlay').classList.remove('visible');
}

document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape') irtCloseInfo();
});
</script>

---

##### Citation

Persson, B. N. (2026). *IRT precision: How test information shapes measurement error* [Interactive visualization]. https://bnpersson.github.io/visualizations/irt-precision/

```BibTeX
@misc{Persson2026irtprecision,
  author = {Björn N. Persson},
  year = {2026},
  title = {IRT Precision: How Test Information Shapes Measurement Error},
  note = {Interactive visualization},
  url = {https://bnpersson.github.io/visualizations/irt-precision/}}
```
