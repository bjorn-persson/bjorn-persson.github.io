---
title: "Reliability, Validity & Measurement Error"
description: "Interactive archery-target metaphor for Classical Test Theory. Two sliders control random error (reliability) and systematic error (validity), updating both the target cluster and the observed-score distribution."
summary: "Explore Classical Test Theory's distinction between random error (reliability) and systematic error (validity) via an interactive archery target linked to an observed-score distribution curve."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');

.rv-wrap {
  font-family: 'IBM Plex Mono', monospace;
}
.rv-subtitle {
  font-size: 0.78rem;
  color: var(--secondary);
  margin-bottom: 18px;
  line-height: 1.6;
}
.rv-controls {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px 24px;
  margin-bottom: 18px;
  font-size: 0.78rem;
}
.rv-control-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.rv-control-group label {
  color: var(--secondary);
  font-size: 0.72rem;
}
.rv-control-group .rv-val {
  color: #0d8a74;
  font-weight: 600;
}
.rv-controls input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: #e0e0ec;
  border-radius: 2px;
  outline: none;
  cursor: pointer;
}
.rv-controls input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
}
.rv-controls input[type="range"]::-moz-range-thumb {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
  border: none;
}
.rv-canvases {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin-bottom: 10px;
}
.rv-canvas-block {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.rv-canvas-label {
  font-size: 0.7rem;
  color: var(--secondary);
  text-transform: uppercase;
  letter-spacing: 0.07em;
}
.rv-canvas-block canvas {
  display: block;
  width: 100%;
  border-radius: 6px;
  background: #f4f4f8;
}
.rv-badges {
  display: flex;
  gap: 16px;
  margin-bottom: 14px;
  flex-wrap: wrap;
}
.rv-badge {
  font-size: 0.72rem;
  padding: 3px 10px;
  border-radius: 4px;
  background: #f0f0f8;
  border: 1px solid #e0e0ec;
  color: var(--secondary);
}
.rv-badge .rv-badge-val {
  color: #0d8a74;
  font-weight: 600;
}
.rv-note {
  font-size: 0.68rem;
  color: var(--secondary);
  line-height: 1.6;
  margin-top: 10px;
}
@media (max-width: 600px) {
  .rv-controls { grid-template-columns: 1fr; }
  .rv-canvases { grid-template-columns: 1fr; }
}
</style>

<div class="rv-wrap">
  <p class="rv-subtitle">
    Classical Test Theory: Observed Score = True Score + Error.<br>
    <strong>Reliability</strong> concerns <em>random</em> error — how consistently a measure performs.<br>
    <strong>Validity</strong> concerns <em>systematic</em> error — whether a measure hits its intended target.
  </p>
  <div class="rv-controls">
    <div class="rv-control-group">
      <label>Random Error (low reliability): <span class="rv-val" id="rv_rand_val">0.30</span></label>
      <input type="range" id="rv_rand" min="0" max="1" step="0.01" value="0.30">
    </div>
    <div class="rv-control-group">
      <label>Systematic Bias (±): <span class="rv-val" id="rv_sys_val">0.00</span></label>
      <input type="range" id="rv_sys" min="-0.85" max="0.85" step="0.01" value="0.00">
    </div>
  </div>
  <div class="rv-badges">
    <div class="rv-badge">Reliability (ρ): <span class="rv-badge-val" id="rv_rho">—</span></div>
    <div class="rv-badge">Validity: <span class="rv-badge-val" id="rv_val_badge">—</span></div>
    <div class="rv-badge" style="width:100%">Diagnosis: <span class="rv-badge-val" id="rv_diagnosis">—</span></div>
  </div>
  <div class="rv-canvases">
    <div class="rv-canvas-block">
      <div class="rv-canvas-label">Target (N = 40 arrows)</div>
      <canvas id="rv_target" height="300"></canvas>
    </div>
    <div class="rv-canvas-block">
      <div class="rv-canvas-label">Observed Score Distribution</div>
      <canvas id="rv_dist" height="300"></canvas>
    </div>
  </div>
  <p class="rv-note">
    Each "arrow" represents one measurement attempt. The bullseye is the true score.<br>
    Random error scatters arrows around the cluster center (flattens and widens the distribution).<br>
    Systematic bias shifts the entire cluster away from the bullseye (displaces the mean without changing spread); use negative values to shift in the opposite direction.<br>
    High reliability + high validity = tight cluster on the bullseye. High reliability + low validity = tight cluster, wrong place.<br>
    <strong>Note:</strong> maximum validity = √reliability (CTT upper bound). A measure cannot correlate with any criterion more than the square root of its own reliability, so validity is bounded here accordingly.
  </p>
</div>

<script>
(function () {
  const N_ARROWS = 40;
  const SEED = 42;

  // Seeded PRNG (Mulberry32)
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

  // Box-Muller using our PRNG
  function randn(rng) {
    let u, v, s;
    do { u = rng() * 2 - 1; v = rng() * 2 - 1; s = u * u + v * v; } while (s >= 1 || s === 0);
    return u * Math.sqrt(-2 * Math.log(s) / s);
  }

  // Normal PDF
  function normalPdf(x, mu, sigma) {
    const z = (x - mu) / sigma;
    return Math.exp(-0.5 * z * z) / (sigma * Math.sqrt(2 * Math.PI));
  }

  const targetCanvas = document.getElementById('rv_target');
  const distCanvas = document.getElementById('rv_dist');
  const tCtx = targetCanvas.getContext('2d');
  const dCtx = distCanvas.getContext('2d');

  const randSlider = document.getElementById('rv_rand');
  const sysSlider = document.getElementById('rv_sys');
  const randVal = document.getElementById('rv_rand_val');
  const sysVal = document.getElementById('rv_sys_val');

  let dpr = window.devicePixelRatio || 1;

  function resizeCanvases() {
    dpr = window.devicePixelRatio || 1;
    for (const c of [targetCanvas, distCanvas]) {
      const rect = c.getBoundingClientRect();
      c.width = rect.width * dpr;
      c.height = rect.height * dpr;
    }
  }

  function generateArrows(randomError, sysOffset) {
    const rng = makeRng(SEED);
    const sigma = randomError * 0.42;
    const arrows = [];
    for (let i = 0; i < N_ARROWS; i++) {
      const angle = rng() * Math.PI * 2;
      const dx = randn(rng) * sigma + Math.cos(angle * 0.5) * sysOffset * 0.7;
      const dy = randn(rng) * sigma + Math.sin(angle * 0.5 + 0.9) * sysOffset * 0.7;
      arrows.push({ x: sysOffset * 0.7 + dx, y: sysOffset * 0.4 + dy });
    }
    // Recenter systematic offset to a consistent direction (right + up)
    const arrows2 = [];
    for (let i = 0; i < N_ARROWS; i++) {
      const nx = randn(rng) * sigma + sysOffset * 0.65;
      const ny = randn(rng) * sigma + sysOffset * 0.38;
      arrows2.push({ x: nx, y: ny });
    }
    return arrows2;
  }

  function drawTarget(randomError, sysOffset) {
    const W = targetCanvas.width / dpr;
    const H = targetCanvas.height / dpr;
    tCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    tCtx.clearRect(0, 0, W, H);

    const cx = W / 2, cy = H / 2;
    const maxR = Math.min(W, H) * 0.44;

    // Rings
    const ringColors = ['#c83c5a', '#e8a020', '#e8d820', '#4caf50', '#2196f3', '#2196f3', '#ffffff', '#ffffff', '#ffffff', '#ffffff'];
    for (let i = 10; i >= 1; i--) {
      const r = maxR * i / 10;
      tCtx.beginPath();
      tCtx.arc(cx, cy, r, 0, Math.PI * 2);
      tCtx.fillStyle = ringColors[i - 1] || '#f0f0f0';
      tCtx.fill();
      tCtx.strokeStyle = 'rgba(0,0,0,0.12)';
      tCtx.lineWidth = 0.5;
      tCtx.stroke();
    }

    // Crosshairs
    tCtx.strokeStyle = 'rgba(0,0,0,0.15)';
    tCtx.lineWidth = 0.8;
    tCtx.setLineDash([3, 3]);
    tCtx.beginPath(); tCtx.moveTo(cx - maxR, cy); tCtx.lineTo(cx + maxR, cy); tCtx.stroke();
    tCtx.beginPath(); tCtx.moveTo(cx, cy - maxR); tCtx.lineTo(cx, cy + maxR); tCtx.stroke();
    tCtx.setLineDash([]);

    // Arrows
    const arrows = generateArrows(randomError, sysOffset);
    for (const a of arrows) {
      const sx = cx + a.x * maxR;
      const sy = cy - a.y * maxR;
      tCtx.beginPath();
      tCtx.arc(sx, sy, 4, 0, Math.PI * 2);
      tCtx.fillStyle = 'rgba(40, 20, 80, 0.72)';
      tCtx.fill();
      tCtx.beginPath();
      tCtx.arc(sx, sy, 4, 0, Math.PI * 2);
      tCtx.strokeStyle = 'rgba(255,255,255,0.6)';
      tCtx.lineWidth = 1;
      tCtx.stroke();
    }

    // Cluster center marker
    const meanX = arrows.reduce((s, a) => s + a.x, 0) / N_ARROWS;
    const meanY = arrows.reduce((s, a) => s + a.y, 0) / N_ARROWS;
    const smx = cx + meanX * maxR;
    const smy = cy - meanY * maxR;
    tCtx.beginPath();
    tCtx.arc(smx, smy, 5, 0, Math.PI * 2);
    tCtx.fillStyle = 'rgba(194, 100, 10, 0.9)';
    tCtx.fill();

    // Label
    tCtx.font = `${11 * dpr / dpr}px IBM Plex Mono, monospace`;
    tCtx.fillStyle = '#888899';
    tCtx.textAlign = 'center';
    tCtx.fillText('● = cluster mean', cx, H - 8);
  }

  function drawDist(randomError, sysOffset) {
    const W = distCanvas.width / dpr;
    const H = distCanvas.height / dpr;
    dCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    dCtx.clearRect(0, 0, W, H);

    const PAD_L = 46, PAD_R = 16, PAD_T = 18, PAD_B = 32;
    const pw = W - PAD_L - PAD_R;
    const ph = H - PAD_T - PAD_B;

    const TRUE_SCORE = 0.5; // normalized to [0,1] scale
    const sigma = 0.05 + randomError * 0.18;
    const mu = TRUE_SCORE + sysOffset * 0.35;

    const xMin = 0, xMax = 1;
    function toSx(v) { return PAD_L + (v - xMin) / (xMax - xMin) * pw; }

    // True score curve (narrow, positioned at 0.5)
    const trueSD = 0.025;
    const maxTruePdf = normalPdf(TRUE_SCORE, TRUE_SCORE, trueSD);
    const maxObsPdf = normalPdf(mu, mu, sigma);
    const globalMax = Math.max(maxTruePdf, maxObsPdf) * 1.15;
    function toSy(density) { return PAD_T + ph - (density / globalMax) * ph; }

    // Background grid
    dCtx.strokeStyle = '#e4e4f0';
    dCtx.lineWidth = 0.5;
    for (let t = 0; t <= 1.001; t += 0.25) {
      const sx = toSx(t);
      dCtx.beginPath(); dCtx.moveTo(sx, PAD_T); dCtx.lineTo(sx, PAD_T + ph); dCtx.stroke();
    }

    // Shade under observed curve
    dCtx.beginPath();
    dCtx.moveTo(toSx(xMin), toSy(0));
    for (let i = 0; i <= 300; i++) {
      const x = xMin + (xMax - xMin) * i / 300;
      dCtx.lineTo(toSx(x), toSy(normalPdf(x, mu, sigma)));
    }
    dCtx.lineTo(toSx(xMax), toSy(0));
    dCtx.closePath();
    const grad = dCtx.createLinearGradient(0, PAD_T, 0, PAD_T + ph);
    grad.addColorStop(0, 'rgba(13,138,116,0.22)');
    grad.addColorStop(1, 'rgba(13,138,116,0.04)');
    dCtx.fillStyle = grad;
    dCtx.fill();

    // Observed curve
    dCtx.beginPath();
    for (let i = 0; i <= 300; i++) {
      const x = xMin + (xMax - xMin) * i / 300;
      const y = toSy(normalPdf(x, mu, sigma));
      i === 0 ? dCtx.moveTo(toSx(x), y) : dCtx.lineTo(toSx(x), y);
    }
    dCtx.strokeStyle = '#0d8a74';
    dCtx.lineWidth = 2;
    dCtx.stroke();

    // True score curve (dashed thin)
    dCtx.beginPath();
    for (let i = 0; i <= 300; i++) {
      const x = xMin + (xMax - xMin) * i / 300;
      const y = toSy(normalPdf(x, TRUE_SCORE, trueSD));
      i === 0 ? dCtx.moveTo(toSx(x), y) : dCtx.lineTo(toSx(x), y);
    }
    dCtx.strokeStyle = '#c83c5a';
    dCtx.lineWidth = 1.5;
    dCtx.setLineDash([5, 4]);
    dCtx.stroke();
    dCtx.setLineDash([]);

    // Bullseye line
    const bx = toSx(TRUE_SCORE);
    dCtx.beginPath(); dCtx.moveTo(bx, PAD_T); dCtx.lineTo(bx, PAD_T + ph);
    dCtx.strokeStyle = 'rgba(200,60,90,0.35)';
    dCtx.lineWidth = 1;
    dCtx.setLineDash([3, 3]);
    dCtx.stroke();
    dCtx.setLineDash([]);

    // Observed mean line
    const omx = toSx(mu);
    dCtx.beginPath(); dCtx.moveTo(omx, PAD_T); dCtx.lineTo(omx, PAD_T + ph);
    dCtx.strokeStyle = 'rgba(13,138,116,0.5)';
    dCtx.lineWidth = 1;
    dCtx.setLineDash([3, 3]);
    dCtx.stroke();
    dCtx.setLineDash([]);

    // Axes
    dCtx.strokeStyle = '#c0c0d8';
    dCtx.lineWidth = 1;
    dCtx.beginPath(); dCtx.moveTo(PAD_L, PAD_T + ph); dCtx.lineTo(PAD_L + pw, PAD_T + ph); dCtx.stroke();
    dCtx.beginPath(); dCtx.moveTo(PAD_L, PAD_T); dCtx.lineTo(PAD_L, PAD_T + ph); dCtx.stroke();

    // X ticks
    dCtx.font = '10px IBM Plex Mono, monospace';
    dCtx.fillStyle = '#888899';
    dCtx.textAlign = 'center';
    for (let t = 0; t <= 1.001; t += 0.25) {
      const sx = toSx(t);
      dCtx.beginPath(); dCtx.moveTo(sx, PAD_T + ph); dCtx.lineTo(sx, PAD_T + ph + 4);
      dCtx.strokeStyle = '#c0c0d8'; dCtx.lineWidth = 1; dCtx.stroke();
      dCtx.fillText(t.toFixed(2), sx, PAD_T + ph + 16);
    }

    // Y axis label
    dCtx.save();
    dCtx.translate(13, PAD_T + ph / 2);
    dCtx.rotate(-Math.PI / 2);
    dCtx.textAlign = 'center';
    dCtx.fillStyle = '#888899';
    dCtx.font = '10px IBM Plex Mono, monospace';
    dCtx.fillText('density', 0, 0);
    dCtx.restore();

    // Legend
    const legX = PAD_L + pw - 4;
    dCtx.textAlign = 'right';
    dCtx.font = '10px IBM Plex Mono, monospace';

    dCtx.strokeStyle = '#0d8a74'; dCtx.lineWidth = 2; dCtx.setLineDash([]);
    dCtx.beginPath(); dCtx.moveTo(legX - 52, PAD_T + 10); dCtx.lineTo(legX - 32, PAD_T + 10); dCtx.stroke();
    dCtx.fillStyle = '#0d8a74';
    dCtx.fillText('observed', legX, PAD_T + 14);

    dCtx.strokeStyle = '#c83c5a'; dCtx.lineWidth = 1.5; dCtx.setLineDash([5, 4]);
    dCtx.beginPath(); dCtx.moveTo(legX - 52, PAD_T + 26); dCtx.lineTo(legX - 32, PAD_T + 26); dCtx.stroke();
    dCtx.setLineDash([]);
    dCtx.fillStyle = '#c83c5a';
    dCtx.fillText('true score', legX, PAD_T + 30);

    dCtx.textAlign = 'left';
  }

  function getBadges(randomError, sysOffset) {
    const rho = Math.max(0, 1 - randomError * randomError);
    const maxValidity = Math.sqrt(rho);
    const validity = Math.max(0, (1 - Math.abs(sysOffset) * 1.18) * maxValidity);
    let diag;
    if (rho >= 0.8 && validity >= 0.8) diag = 'High reliability, high validity';
    else if (rho >= 0.8 && validity < 0.8) diag = 'High reliability, low validity';
    else if (rho < 0.8 && validity >= 0.8 * maxValidity) diag = 'Low reliability, unbiased (but limited validity)';
    else diag = 'Low reliability, low validity';
    return { rho: rho.toFixed(2), validity: validity.toFixed(2), diag };
  }

  function update() {
    const randomError = parseFloat(randSlider.value);
    const sysOffset = parseFloat(sysSlider.value);
    randVal.textContent = randomError.toFixed(2);
    sysVal.textContent = sysOffset.toFixed(2);
    const { rho, validity, diag } = getBadges(randomError, sysOffset);
    document.getElementById('rv_rho').textContent = rho;
    document.getElementById('rv_val_badge').textContent = validity;
    document.getElementById('rv_diagnosis').textContent = diag;
    drawTarget(randomError, sysOffset);
    drawDist(randomError, sysOffset);
  }

  randSlider.addEventListener('input', update);
  sysSlider.addEventListener('input', update);

  function resize() {
    resizeCanvases();
    update();
  }

  window.addEventListener('resize', resize);
  resize();
})();
</script>
