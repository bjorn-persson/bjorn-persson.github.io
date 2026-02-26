---
title: "Normal Distribution"
description: "Interactive visualization of the standard normal cumulative distribution function. Click the curve to compute probabilities; a second click shows the probability between two z-values."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');

.viz-embed .container {
  width: 100%;
  max-width: 780px;
}

.viz-embed .subtitle {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.78rem;
  color: var(--secondary);
  margin-bottom: 18px;
  line-height: 1.5;
}

.viz-embed canvas {
  display: block;
  width: 100%;
  height: max(280px, calc(100vh - 460px));
  background: #f4f4f8;
  border-radius: 6px;
  cursor: crosshair;
}

.viz-embed .readout {
  display: flex;
  flex-wrap: wrap;
  gap: 12px 28px;
  margin-top: 14px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.85rem;
}

.viz-embed .readout .label { color: var(--secondary); }
.viz-embed .readout .value { color: var(--primary); font-weight: 600; }
.viz-embed .readout .prob-val { color: #0d8a74; }
.viz-embed .readout .accent2 { color: #6d28d9; }
.viz-embed .readout .hidden { display: none; }

.viz-embed .mode-indicator {
  margin-top: 12px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.75rem;
  color: #0d8a74;
  opacity: 0.8;
}

.viz-embed .note {
  margin-top: 14px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.7rem;
  color: var(--secondary);
  line-height: 1.5;
}

.viz-embed .reset-btn {
  margin-top: 10px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.72rem;
  background: none;
  border: 1px solid var(--border);
  color: var(--secondary);
  padding: 4px 12px;
  border-radius: 4px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}
.viz-embed .reset-btn:hover {
  border-color: #0d8a74;
  color: #0d8a74;
}
</style>

<div class="viz-embed">
<div class="container">
  <p class="subtitle">
    One click: cumulative P(Z &le; z) from &minus;&infin;.<br>
    Two clicks: proportion between two z-values. Hover to preview.
  </p>
  <canvas id="c" height="400"></canvas>
  <div class="readout">
    <div id="r_z1"><span class="label">z = </span><span class="value" id="z1Val">&mdash;</span></div>
    <div id="r_z2" class="hidden"><span class="label">z&#x2082; = </span><span class="value" id="z2Val">&mdash;</span></div>
    <div id="r_p"><span class="label" id="pLabel">P(Z &le; z) = </span><span class="value prob-val" id="pVal">&mdash;</span></div>
    <div><span class="label">hover z = </span><span class="value accent2" id="hVal">&mdash;</span></div>
  </div>
  <div class="mode-indicator" id="modeText">Click to place a marker</div>
  <button class="reset-btn" id="resetBtn">Reset</button>
  <p class="note">
    CDF via Abramowitz &amp; Stegun 26.2.17 (max error ~1.5&times;10&#x207B;&#x2077;).<br>
    One marker: &Phi;(z). Two markers: &Phi;(z&#x2082;) &minus; &Phi;(z&#x2081;).
  </p>
</div>
</div>

<script>
const canvas = document.getElementById('c');
const ctx = canvas.getContext('2d');
const z1El = document.getElementById('z1Val');
const z2El = document.getElementById('z2Val');
const pEl  = document.getElementById('pVal');
const pLabel = document.getElementById('pLabel');
const hEl  = document.getElementById('hVal');
const modeEl = document.getElementById('modeText');
const resetBtn = document.getElementById('resetBtn');
const rZ1 = document.getElementById('r_z1');
const rZ2 = document.getElementById('r_z2');

const Z_MIN = -4, Z_MAX = 4;
const PAD_L = 52, PAD_R = 20, PAD_T = 20, PAD_B = 40;

let dpr = 1;

// State: 0 = nothing, 1 = one marker (cumulative), 2 = two markers (range)
let state = 0;
let z1 = null, z2 = null;
let hoverZ = null;

function phi(z) {
  return Math.exp(-0.5 * z * z) / Math.sqrt(2 * Math.PI);
}

function Phi(z) {
  if (z < -8) return 0;
  if (z > 8) return 1;
  const neg = z < 0;
  const x = neg ? -z : z;
  const t = 1 / (1 + 0.2316419 * x);
  const d = phi(x);
  const p = d * t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))));
  return neg ? p : 1 - p;
}

function zToX(z) {
  const w = canvas.width / dpr - PAD_L - PAD_R;
  return PAD_L + (z - Z_MIN) / (Z_MAX - Z_MIN) * w;
}

function yFromPhi(v) {
  const h = canvas.height / dpr - PAD_T - PAD_B;
  const maxPhi = phi(0);
  return PAD_T + h - (v / maxPhi) * h;
}

function xToZ(px) {
  const w = canvas.width / dpr - PAD_L - PAD_R;
  return Z_MIN + (px - PAD_L) / w * (Z_MAX - Z_MIN);
}

function clampZ(z) {
  return Math.max(Z_MIN, Math.min(Z_MAX, z));
}

function drawShade(lo, hi, color1, color2) {
  const steps = 300;
  ctx.beginPath();
  const plotH = canvas.height / dpr - PAD_T - PAD_B;
  ctx.moveTo(zToX(lo), yFromPhi(0));
  for (let i = 0; i <= steps; i++) {
    const zi = lo + (hi - lo) * i / steps;
    ctx.lineTo(zToX(zi), yFromPhi(phi(zi)));
  }
  ctx.lineTo(zToX(hi), yFromPhi(0));
  ctx.closePath();
  const grad = ctx.createLinearGradient(0, PAD_T, 0, PAD_T + plotH);
  grad.addColorStop(0, color1);
  grad.addColorStop(1, color2);
  ctx.fillStyle = grad;
  ctx.fill();
}

function drawVertical(z, color) {
  const xz = zToX(z);
  ctx.beginPath();
  ctx.moveTo(xz, yFromPhi(phi(z)));
  ctx.lineTo(xz, yFromPhi(0));
  ctx.strokeStyle = color;
  ctx.lineWidth = 1.5;
  ctx.setLineDash([4, 3]);
  ctx.stroke();
  ctx.setLineDash([]);

  ctx.beginPath();
  ctx.arc(xz, yFromPhi(phi(z)), 5, 0, Math.PI * 2);
  ctx.fillStyle = color;
  ctx.fill();
}

function draw() {
  const W = canvas.width / dpr;
  const H = canvas.height / dpr;
  const plotW = W - PAD_L - PAD_R;
  const plotH = H - PAD_T - PAD_B;
  const steps = 400;

  ctx.clearRect(0, 0, W, H);

  // Shading
  if (state === 1 && z1 !== null) {
    drawShade(Z_MIN, z1, 'rgba(13,138,116,0.22)', 'rgba(13,138,116,0.04)');
    if (hoverZ !== null) {
      const lo = Math.min(z1, hoverZ), hi = Math.max(z1, hoverZ);
      drawShade(lo, hi, 'rgba(109,40,217,0.12)', 'rgba(109,40,217,0.03)');
    }
  } else if (state === 2 && z1 !== null && z2 !== null) {
    const lo = Math.min(z1, z2), hi = Math.max(z1, z2);
    drawShade(lo, hi, 'rgba(13,138,116,0.22)', 'rgba(13,138,116,0.04)');
  } else if (state === 0 && hoverZ !== null) {
    drawShade(Z_MIN, hoverZ, 'rgba(109,40,217,0.12)', 'rgba(109,40,217,0.03)');
  }

  // Full curve
  ctx.beginPath();
  for (let i = 0; i <= steps; i++) {
    const zi = Z_MIN + (Z_MAX - Z_MIN) * i / steps;
    const x = zToX(zi);
    const y = yFromPhi(phi(zi));
    i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
  }
  ctx.strokeStyle = '#5555aa';
  ctx.lineWidth = 2;
  ctx.stroke();

  // Vertical markers
  if (z1 !== null) drawVertical(z1, '#0d8a74');
  if (state === 2 && z2 !== null) drawVertical(z2, '#0d8a74');
  // Hover line
  if (hoverZ !== null && state !== 2) drawVertical(hoverZ, 'rgba(109,40,217,0.5)');

  // X axis
  ctx.beginPath();
  ctx.moveTo(PAD_L, PAD_T + plotH);
  ctx.lineTo(PAD_L + plotW, PAD_T + plotH);
  ctx.strokeStyle = '#c0c0d8';
  ctx.lineWidth = 1;
  ctx.stroke();

  // Ticks
  ctx.font = '11px IBM Plex Mono, monospace';
  ctx.fillStyle = '#888899';
  ctx.textAlign = 'center';
  for (let t = Z_MIN; t <= Z_MAX; t++) {
    const tx = zToX(t);
    ctx.beginPath();
    ctx.moveTo(tx, PAD_T + plotH);
    ctx.lineTo(tx, PAD_T + plotH + 5);
    ctx.strokeStyle = '#c0c0d8';
    ctx.stroke();
    ctx.fillText(t.toString(), tx, PAD_T + plotH + 18);
  }

  // Y axis label
  ctx.save();
  ctx.translate(14, PAD_T + plotH / 2);
  ctx.rotate(-Math.PI / 2);
  ctx.textAlign = 'center';
  ctx.fillStyle = '#888899';
  ctx.font = '11px IBM Plex Mono, monospace';
  ctx.fillText('\u03C6(z)', 0, 0);
  ctx.restore();

  // Update readouts
  updateReadouts();
}

function updateReadouts() {
  hEl.textContent = hoverZ !== null ? hoverZ.toFixed(2) : '\u2014';

  if (state === 0) {
    rZ2.classList.add('hidden');
    rZ1.querySelector('.label').innerHTML = 'z = ';
    z1El.textContent = '\u2014';
    pLabel.innerHTML = 'P(Z &le; z) = ';
    if (hoverZ !== null) {
      pEl.textContent = '~' + (Phi(hoverZ) * 100).toFixed(2) + '%';
    } else {
      pEl.textContent = '\u2014';
    }
  } else if (state === 1) {
    rZ2.classList.add('hidden');
    rZ1.querySelector('.label').innerHTML = 'z = ';
    z1El.textContent = z1.toFixed(2);
    if (hoverZ !== null) {
      const lo = Math.min(z1, hoverZ), hi = Math.max(z1, hoverZ);
      pLabel.innerHTML = 'P(z\u2081 < Z \u2264 z\u2082) = ';
      pEl.textContent = '~' + ((Phi(hi) - Phi(lo)) * 100).toFixed(2) + '%';
    } else {
      pLabel.innerHTML = 'P(Z &le; z) = ';
      pEl.textContent = (Phi(z1) * 100).toFixed(2) + '%';
    }
  } else if (state === 2) {
    rZ2.classList.remove('hidden');
    rZ1.querySelector('.label').innerHTML = 'z\u2081 = ';
    z1El.textContent = z1.toFixed(2);
    z2El.textContent = z2.toFixed(2);
    const lo = Math.min(z1, z2), hi = Math.max(z1, z2);
    pLabel.innerHTML = 'P(z\u2081 < Z \u2264 z\u2082) = ';
    pEl.textContent = ((Phi(hi) - Phi(lo)) * 100).toFixed(2) + '%';
  }
}

function getZ(e) {
  const rect = canvas.getBoundingClientRect();
  return clampZ(xToZ(e.clientX - rect.left));
}

canvas.addEventListener('click', e => {
  const z = getZ(e);
  if (state === 0) {
    z1 = z; z2 = null; state = 1;
    modeEl.textContent = 'Showing cumulative. Click again to set a second bound.';
  } else if (state === 1) {
    z2 = z; state = 2;
    if (z1 > z2) { const tmp = z1; z1 = z2; z2 = tmp; }
    modeEl.textContent = 'Showing range. Click to start over.';
  } else {
    z1 = z; z2 = null; state = 1;
    modeEl.textContent = 'Showing cumulative. Click again to set a second bound.';
  }
  draw();
});

canvas.addEventListener('mousemove', e => {
  hoverZ = getZ(e);
  draw();
});

canvas.addEventListener('mouseleave', () => {
  hoverZ = null;
  draw();
});

resetBtn.addEventListener('click', () => {
  state = 0; z1 = null; z2 = null; hoverZ = null;
  modeEl.textContent = 'Click to place a marker';
  draw();
});

canvas.addEventListener('touchstart', e => e.preventDefault(), { passive: false });

function resize() {
  dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  draw();
}

window.addEventListener('resize', resize);
resize();
</script>
