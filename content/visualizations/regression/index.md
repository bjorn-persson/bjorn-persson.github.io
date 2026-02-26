---
title: "Regression Models"
description: "Interactive visualization for fitting linear, quadratic, cubic, and logistic regression models. Set population parameters, generate synthetic data, and compare the fitted curve to the true population curve."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');

.viz-embed .container {
  width: 100%;
  max-width: 860px;
}

.viz-embed .subtitle {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.78rem;
  color: var(--secondary);
  margin-bottom: 16px;
  line-height: 1.5;
}

.viz-embed .controls {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(175px, 1fr));
  gap: 10px 16px;
  margin-bottom: 14px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.78rem;
}

.viz-embed .control-group {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.viz-embed .control-group label {
  color: var(--secondary);
  font-size: 0.72rem;
}

.viz-embed .control-group .val {
  color: #0d8a74;
  font-weight: 600;
}

.viz-embed input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: #e0e0ec;
  border-radius: 2px;
  outline: none;
}

.viz-embed input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
}

.viz-embed input[type="range"]::-moz-range-thumb {
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
  border: none;
}

.viz-embed .button-row {
  display: flex;
  gap: 8px;
  margin-bottom: 14px;
  flex-wrap: wrap;
}

.viz-embed .btn {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.72rem;
  background: none;
  border: 1px solid var(--border);
  color: var(--secondary);
  padding: 5px 12px;
  border-radius: 4px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
  white-space: nowrap;
}

.viz-embed .btn:hover {
  border-color: #0d8a74;
  color: #0d8a74;
}

.viz-embed .btn.active {
  border-color: #0d8a74;
  color: #0d8a74;
  background: rgba(13, 138, 116, 0.08);
}

.viz-embed .btn.action {
  border-color: var(--tertiary);
  color: var(--secondary);
}

.viz-embed .btn.action:hover {
  border-color: #c2640a;
  color: #c2640a;
}

.viz-embed canvas {
  display: block;
  width: 100%;
  height: max(280px, calc(100vh - 560px));
  background: #f4f4f8;
  border-radius: 6px;
}

.viz-embed .equation {
  margin-top: 10px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.8rem;
  color: var(--primary);
  line-height: 1.6;
}

.viz-embed .equation .coef { color: #0d8a74; font-weight: 600; }
.viz-embed .equation .fit-coef { color: #c2640a; font-weight: 600; }

.viz-embed .stats {
  margin-top: 4px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.75rem;
  color: var(--secondary);
}

.viz-embed .note {
  margin-top: 14px;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.7rem;
  color: var(--secondary);
  line-height: 1.5;
}

.viz-embed .hidden { display: none !important; }
</style>

<div class="viz-embed">
<div class="container">
  <p class="subtitle">
    Choose a model type, set population coefficients, generate data, and fit via OLS or MLE.
  </p>

  <div class="button-row">
    <button class="btn active" id="btnLinear" onclick="setType('linear')">Linear</button>
    <button class="btn" id="btnQuad" onclick="setType('quadratic')">Quadratic</button>
    <button class="btn" id="btnCubic" onclick="setType('cubic')">Cubic</button>
    <button class="btn" id="btnLogistic" onclick="setType('logistic')">Logistic</button>
    <button class="btn action" onclick="generateData()">Generate</button>
    <button class="btn action" onclick="fitModel()">Fit</button>
  </div>

  <div class="controls" id="paramControls"></div>

  <canvas id="canvas"></canvas>

  <div class="equation" id="eqPopulation"></div>
  <div class="equation" id="eqFitted"></div>
  <div class="stats" id="statsText"></div>

  <p class="note" id="noteText"></p>
</div>
</div>

<script>
// ── State ──
let modelType = 'linear';
let data = [];
let fitResult = null;

// ── RNG ──
function randn() {
  let u, v, s;
  do { u = Math.random()*2-1; v = Math.random()*2-1; s = u*u+v*v; } while (s >= 1 || s === 0);
  return u * Math.sqrt(-2 * Math.log(s) / s);
}

function sigmoid(x) { return 1 / (1 + Math.exp(-x)); }

// ── Model definitions ──
const models = {
  linear: {
    params: [
      { id: 'b0', label: 'β₀ (intercept)', min: -5, max: 5, step: 0.1, def: 0 },
      { id: 'b1', label: 'β₁', min: -3, max: 3, step: 0.1, def: 1 },
      { id: 'sigma', label: 'σ (error SD)', min: 0, max: 5, step: 0.1, def: 1 },
      { id: 'n', label: 'N', min: 10, max: 500, step: 1, def: 80 },
    ],
    dgp(p) {
      const x = randn();
      return { x, y: p.b0 + p.b1*x + randn()*p.sigma };
    },
    popFn(x, p) { return p.b0 + p.b1*x; },
    popEq(p) { return `Y = <span class="coef">${f(p.b0)}</span> + <span class="coef">${f(p.b1)}</span>X + ε`; },
    fitEq(r) { return `Ŷ = <span class="fit-coef">${f3(r.b[0])}</span> + <span class="fit-coef">${f3(r.b[1])}</span>X`; },
    designRow(x) { return [1, x]; },
    fitFn(x, r) { return r.b[0] + r.b[1]*x; },
    note: 'DGP: Y = β₀ + β₁X + ε, X ~ N(0,1), ε ~ N(0,σ²). OLS via normal equations.',
  },
  quadratic: {
    params: [
      { id: 'b0', label: 'β₀ (intercept)', min: -5, max: 5, step: 0.1, def: 0 },
      { id: 'b1', label: 'β₁ (linear)', min: -3, max: 3, step: 0.1, def: 0.5 },
      { id: 'b2', label: 'β₂ (quadratic)', min: -2, max: 2, step: 0.05, def: 0.5 },
      { id: 'sigma', label: 'σ (error SD)', min: 0, max: 5, step: 0.1, def: 1 },
      { id: 'n', label: 'N', min: 10, max: 500, step: 1, def: 80 },
    ],
    dgp(p) {
      const x = randn();
      return { x, y: p.b0 + p.b1*x + p.b2*x*x + randn()*p.sigma };
    },
    popFn(x, p) { return p.b0 + p.b1*x + p.b2*x*x; },
    popEq(p) { return `Y = <span class="coef">${f(p.b0)}</span> + <span class="coef">${f(p.b1)}</span>X + <span class="coef">${f(p.b2)}</span>X² + ε`; },
    fitEq(r) { return `Ŷ = <span class="fit-coef">${f3(r.b[0])}</span> + <span class="fit-coef">${f3(r.b[1])}</span>X + <span class="fit-coef">${f3(r.b[2])}</span>X²`; },
    designRow(x) { return [1, x, x*x]; },
    fitFn(x, r) { return r.b[0] + r.b[1]*x + r.b[2]*x*x; },
    note: 'DGP: Y = β₀ + β₁X + β₂X² + ε, X ~ N(0,1), ε ~ N(0,σ²). OLS on design matrix [1, X, X²].',
  },
  cubic: {
    params: [
      { id: 'b0', label: 'β₀ (intercept)', min: -5, max: 5, step: 0.1, def: 0 },
      { id: 'b1', label: 'β₁ (linear)', min: -3, max: 3, step: 0.1, def: 0 },
      { id: 'b2', label: 'β₂ (quadratic)', min: -2, max: 2, step: 0.05, def: 0 },
      { id: 'b3', label: 'β₃ (cubic)', min: -1, max: 1, step: 0.05, def: 0.3 },
      { id: 'sigma', label: 'σ (error SD)', min: 0, max: 5, step: 0.1, def: 1 },
      { id: 'n', label: 'N', min: 10, max: 500, step: 1, def: 100 },
    ],
    dgp(p) {
      const x = randn();
      return { x, y: p.b0 + p.b1*x + p.b2*x*x + p.b3*x*x*x + randn()*p.sigma };
    },
    popFn(x, p) { return p.b0 + p.b1*x + p.b2*x*x + p.b3*x*x*x; },
    popEq(p) { return `Y = <span class="coef">${f(p.b0)}</span> + <span class="coef">${f(p.b1)}</span>X + <span class="coef">${f(p.b2)}</span>X² + <span class="coef">${f(p.b3)}</span>X³ + ε`; },
    fitEq(r) { return `Ŷ = <span class="fit-coef">${f3(r.b[0])}</span> + <span class="fit-coef">${f3(r.b[1])}</span>X + <span class="fit-coef">${f3(r.b[2])}</span>X² + <span class="fit-coef">${f3(r.b[3])}</span>X³`; },
    designRow(x) { return [1, x, x*x, x*x*x]; },
    fitFn(x, r) { return r.b[0] + r.b[1]*x + r.b[2]*x*x + r.b[3]*x*x*x; },
    note: 'DGP: Y = β₀ + β₁X + β₂X² + β₃X³ + ε, X ~ N(0,1), ε ~ N(0,σ²). OLS on design matrix [1, X, X², X³].',
  },
  logistic: {
    params: [
      { id: 'b0', label: 'β₀ (intercept)', min: -5, max: 5, step: 0.1, def: 0 },
      { id: 'b1', label: 'β₁', min: -5, max: 5, step: 0.1, def: 2 },
      { id: 'n', label: 'N', min: 20, max: 500, step: 1, def: 120 },
    ],
    dgp(p) {
      const x = randn();
      const prob = sigmoid(p.b0 + p.b1 * x);
      const y = Math.random() < prob ? 1 : 0;
      return { x, y };
    },
    popFn(x, p) { return sigmoid(p.b0 + p.b1*x); },
    popEq(p) { return `P(Y=1|X) = σ(<span class="coef">${f(p.b0)}</span> + <span class="coef">${f(p.b1)}</span>X)`; },
    fitEq(r) { return `P̂(Y=1|X) = σ(<span class="fit-coef">${f3(r.b[0])}</span> + <span class="fit-coef">${f3(r.b[1])}</span>X)`; },
    designRow(x) { return [1, x]; },
    fitFn(x, r) { return sigmoid(r.b[0] + r.b[1]*x); },
    note: 'DGP: Y ~ Bernoulli(σ(β₀ + β₁X)), X ~ N(0,1). Fit via IRLS. McFadden R² = 1 − LL/LL₀. Nagelkerke R² = (1 − exp(2(LL₀−LL)/N)) / (1 − exp(2·LL₀/N)). LL₀ is the null model (intercept-only) log-likelihood.',
  },
};

function f(v) { return v.toFixed(1); }
function f3(v) { return v.toFixed(3); }

// ── Build parameter controls ──
function buildControls() {
  const m = models[modelType];
  const container = document.getElementById('paramControls');
  container.innerHTML = '';
  for (const p of m.params) {
    const div = document.createElement('div');
    div.className = 'control-group';
    div.innerHTML = `
      <label>${p.label}: <span class="val" id="v_${p.id}">${p.id === 'n' ? p.def : p.def.toFixed(1)}</span></label>
      <input type="range" id="s_${p.id}" min="${p.min}" max="${p.max}" step="${p.step}" value="${p.def}" oninput="onSlider()">
    `;
    container.appendChild(div);
  }
}

function getParams() {
  const m = models[modelType];
  const p = {};
  for (const def of m.params) {
    p[def.id] = def.id === 'n'
      ? parseInt(document.getElementById('s_' + def.id).value)
      : parseFloat(document.getElementById('s_' + def.id).value);
  }
  return p;
}

function onSlider() {
  const m = models[modelType];
  const p = getParams();
  for (const def of m.params) {
    document.getElementById('v_' + def.id).textContent =
      def.id === 'n' ? p[def.id] : p[def.id].toFixed(def.step < 0.1 ? 2 : 1);
  }
  updateEquation();
  render();
}

// ── Type switching ──
function setType(t) {
  modelType = t;
  data = [];
  fitResult = null;
  for (const k of ['Linear','Quad','Cubic','Logistic']) {
    document.getElementById('btn'+k).classList.remove('active');
  }
  const btnMap = { linear: 'Linear', quadratic: 'Quad', cubic: 'Cubic', logistic: 'Logistic' };
  document.getElementById('btn' + btnMap[t]).classList.add('active');
  buildControls();
  updateEquation();
  render();
}

// ── Equations ──
function updateEquation() {
  const m = models[modelType];
  const p = getParams();
  const popEl = document.getElementById('eqPopulation');
  const fitEl = document.getElementById('eqFitted');
  const statsEl = document.getElementById('statsText');
  const noteEl = document.getElementById('noteText');

  const sigmaStr = p.sigma !== undefined ? `,  ε ~ N(0, ${f(p.sigma)}²)` : '';
  popEl.innerHTML = 'Population: ' + m.popEq(p) + sigmaStr;
  noteEl.textContent = m.note;

  if (fitResult) {
    fitEl.innerHTML = 'Fitted: ' + m.fitEq(fitResult);
    if (fitResult.r2 !== undefined) {
      statsEl.textContent = `R² = ${fitResult.r2.toFixed(4)},  N = ${data.length}`;
    } else if (fitResult.ll !== undefined) {
      statsEl.textContent = `Log-lik = ${fitResult.ll.toFixed(2)},  null log-lik = ${fitResult.ll0.toFixed(2)},  McFadden R² = ${fitResult.mcfadden.toFixed(4)},  Nagelkerke R² = ${fitResult.nagelkerke.toFixed(4)},  N = ${data.length},  iter = ${fitResult.iter}`;
    }
  } else {
    fitEl.innerHTML = '';
    statsEl.textContent = data.length > 0 ? `N = ${data.length} (not yet fitted)` : '';
  }
}

// ── Data generation ──
function generateData() {
  const m = models[modelType];
  const p = getParams();
  data = [];
  fitResult = null;
  for (let i = 0; i < p.n; i++) {
    data.push(m.dgp(p));
  }
  updateEquation();
  render();
}

// ── OLS for polynomial models ──
function olsFit(designRowFn, k) {
  const n = data.length;
  if (n < k) return null;

  const XtX = Array.from({length: k}, () => Array(k).fill(0));
  const XtY = Array(k).fill(0);
  for (const d of data) {
    const row = designRowFn(d.x);
    for (let a = 0; a < k; a++) {
      XtY[a] += row[a] * d.y;
      for (let b = 0; b < k; b++) {
        XtX[a][b] += row[a] * row[b];
      }
    }
  }

  const aug = XtX.map((row, i) => [...row, XtY[i]]);
  for (let col = 0; col < k; col++) {
    let maxRow = col, maxVal = Math.abs(aug[col][col]);
    for (let r = col + 1; r < k; r++) {
      if (Math.abs(aug[r][col]) > maxVal) { maxVal = Math.abs(aug[r][col]); maxRow = r; }
    }
    [aug[col], aug[maxRow]] = [aug[maxRow], aug[col]];
    const pivot = aug[col][col];
    if (Math.abs(pivot) < 1e-12) return null;
    for (let j = col; j <= k; j++) aug[col][j] /= pivot;
    for (let r = 0; r < k; r++) {
      if (r === col) continue;
      const factor = aug[r][col];
      for (let j = col; j <= k; j++) aug[r][j] -= factor * aug[col][j];
    }
  }

  const b = aug.map(row => row[k]);

  const ybar = data.reduce((s, d) => s + d.y, 0) / n;
  let sstot = 0, ssres = 0;
  for (const d of data) {
    const row = designRowFn(d.x);
    let yhat = 0;
    for (let j = 0; j < k; j++) yhat += b[j] * row[j];
    ssres += (d.y - yhat) ** 2;
    sstot += (d.y - ybar) ** 2;
  }

  return { b, r2: sstot > 0 ? 1 - ssres / sstot : 0 };
}

// ── Logistic regression via IRLS ──
function logisticFit() {
  const n = data.length;
  const k = 2;
  let b = [0, 0];
  let prevLL = -Infinity;

  for (let iter = 0; iter < 50; iter++) {
    const XtWX = Array.from({length: k}, () => Array(k).fill(0));
    const XtR = Array(k).fill(0);
    let ll = 0;

    for (const d of data) {
      const row = [1, d.x];
      const eta = b[0] * row[0] + b[1] * row[1];
      const mu = sigmoid(eta);
      const w = mu * (1 - mu);
      const r = d.y - mu;

      ll += d.y * Math.log(mu + 1e-15) + (1 - d.y) * Math.log(1 - mu + 1e-15);

      for (let a = 0; a < k; a++) {
        XtR[a] += row[a] * r;
        for (let j = 0; j < k; j++) {
          XtWX[a][j] += row[a] * w * row[j];
        }
      }
    }

    const det = XtWX[0][0]*XtWX[1][1] - XtWX[0][1]*XtWX[1][0];
    if (Math.abs(det) < 1e-15) break;
    const d0 = (XtWX[1][1]*XtR[0] - XtWX[0][1]*XtR[1]) / det;
    const d1 = (XtWX[0][0]*XtR[1] - XtWX[1][0]*XtR[0]) / det;
    b[0] += d0;
    b[1] += d1;

    if (Math.abs(ll - prevLL) < 1e-8) {
      const pr2 = pseudoR2(data, b, ll);
      return { b: [...b], ll, iter: iter + 1, ...pr2 };
    }
    prevLL = ll;
  }
  const pr2 = pseudoR2(data, b, prevLL);
  return { b: [...b], ll: prevLL, iter: 50, ...pr2 };
}

function pseudoR2(data, b, ll) {
  const n = data.length;
  const p1 = data.reduce((s, d) => s + d.y, 0) / n;
  const ll0 = n * (p1 * Math.log(p1 + 1e-15) + (1 - p1) * Math.log(1 - p1 + 1e-15));
  const mcfadden = 1 - ll / ll0;
  const nagelkerke_max = 1 - Math.exp(2 * ll0 / n);
  const nagelkerke = (1 - Math.exp(2 * (ll0 - ll) / n)) / nagelkerke_max;
  return { mcfadden, nagelkerke, ll0 };
}

// ── Fit dispatcher ──
function fitModel() {
  if (data.length === 0) return;
  const m = models[modelType];

  if (modelType === 'logistic') {
    fitResult = logisticFit();
  } else {
    const k = m.designRow(0).length;
    fitResult = olsFit(m.designRow, k);
  }
  updateEquation();
  render();
}

// ── Rendering ──
function render() {
  const canvas = document.getElementById('canvas');
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  const ctx = canvas.getContext('2d');
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

  const W = rect.width, H = rect.height;
  const PAD_L = 55, PAD_R = 20, PAD_T = 20, PAD_B = 40;
  const pw = W - PAD_L - PAD_R, ph = H - PAD_T - PAD_B;

  ctx.clearRect(0, 0, W, H);

  const m = models[modelType];
  const p = getParams();
  const isLogistic = modelType === 'logistic';

  // ── Axis ranges ──
  let xmin = -4, xmax = 4;
  let ymin, ymax;

  if (isLogistic) {
    ymin = -0.08; ymax = 1.08;
  } else {
    ymin = -8; ymax = 8;
  }

  if (data.length > 0) {
    const xs = data.map(d => d.x);
    const ys = data.map(d => d.y);
    const xlo = Math.min(...xs), xhi = Math.max(...xs);
    const xpad = (xhi - xlo) * 0.15 || 1;
    xmin = Math.min(xmin, xlo - xpad);
    xmax = Math.max(xmax, xhi + xpad);
    if (!isLogistic) {
      const ylo = Math.min(...ys), yhi = Math.max(...ys);
      const ypad = (yhi - ylo) * 0.15 || 1;
      ymin = Math.min(ymin, ylo - ypad);
      ymax = Math.max(ymax, yhi + ypad);
    }
  }

  if (!isLogistic) {
    const curveSteps = 200;
    for (let i = 0; i <= curveSteps; i++) {
      const xv = xmin + (xmax - xmin) * i / curveSteps;
      const yv = m.popFn(xv, p);
      if (isFinite(yv)) {
        ymin = Math.min(ymin, yv - 1);
        ymax = Math.max(ymax, yv + 1);
      }
    }
  }

  function toSx(v) { return PAD_L + (v - xmin) / (xmax - xmin) * pw; }
  function toSy(v) { return PAD_T + ph - (v - ymin) / (ymax - ymin) * ph; }

  // ── Grid ──
  ctx.strokeStyle = '#e4e4f0';
  ctx.lineWidth = 0.5;
  const xStep = niceStep(xmax - xmin, 8);
  const yStep = niceStep(ymax - ymin, 8);
  for (let t = Math.ceil(xmin / xStep) * xStep; t <= xmax; t += xStep) {
    ctx.beginPath(); ctx.moveTo(toSx(t), PAD_T); ctx.lineTo(toSx(t), PAD_T + ph); ctx.stroke();
  }
  for (let t = Math.ceil(ymin / yStep) * yStep; t <= ymax; t += yStep) {
    ctx.beginPath(); ctx.moveTo(PAD_L, toSy(t)); ctx.lineTo(PAD_L + pw, toSy(t)); ctx.stroke();
  }

  // ── Axes ──
  ctx.strokeStyle = '#c0c0d8';
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(PAD_L, PAD_T + ph); ctx.lineTo(PAD_L + pw, PAD_T + ph); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(PAD_L, PAD_T); ctx.lineTo(PAD_L, PAD_T + ph); ctx.stroke();

  // ── Tick labels ──
  ctx.font = '11px IBM Plex Mono, monospace';
  ctx.fillStyle = '#888899';
  ctx.textAlign = 'center';
  for (let t = Math.ceil(xmin / xStep) * xStep; t <= xmax; t += xStep) {
    ctx.fillText(fmtTick(t, xStep), toSx(t), PAD_T + ph + 16);
  }
  ctx.textAlign = 'right';
  for (let t = Math.ceil(ymin / yStep) * yStep; t <= ymax; t += yStep) {
    ctx.fillText(fmtTick(t, yStep), PAD_L - 6, toSy(t) + 4);
  }

  // ── Axis labels ──
  ctx.fillStyle = '#888899';
  ctx.font = '12px IBM Plex Mono, monospace';
  ctx.textAlign = 'center';
  ctx.fillText('X', PAD_L + pw / 2, PAD_T + ph + 34);
  ctx.save();
  ctx.translate(14, PAD_T + ph / 2);
  ctx.rotate(-Math.PI / 2);
  ctx.fillText(isLogistic ? 'P(Y=1)' : 'Y', 0, 0);
  ctx.restore();

  // ── Population curve ──
  const curveSteps = 500;
  ctx.beginPath();
  let started = false;
  for (let i = 0; i <= curveSteps; i++) {
    const xv = xmin + (xmax - xmin) * i / curveSteps;
    const yv = m.popFn(xv, p);
    if (!isFinite(yv)) continue;
    const sx = toSx(xv), sy = toSy(yv);
    if (!started) { ctx.moveTo(sx, sy); started = true; } else ctx.lineTo(sx, sy);
  }
  ctx.strokeStyle = 'rgba(13, 138, 116, 0.65)';
  ctx.lineWidth = 2.5;
  ctx.setLineDash([7, 5]);
  ctx.stroke();
  ctx.setLineDash([]);

  // ── Fitted curve ──
  if (fitResult) {
    ctx.beginPath();
    started = false;
    for (let i = 0; i <= curveSteps; i++) {
      const xv = xmin + (xmax - xmin) * i / curveSteps;
      const yv = m.fitFn(xv, fitResult);
      if (!isFinite(yv)) continue;
      const sx = toSx(xv), sy = toSy(yv);
      if (!started) { ctx.moveTo(sx, sy); started = true; } else ctx.lineTo(sx, sy);
    }
    ctx.strokeStyle = '#c2640a';
    ctx.lineWidth = 2;
    ctx.stroke();
  }

  // ── Data points ──
  if (isLogistic) {
    for (const d of data) {
      const sx = toSx(d.x);
      const jitter = (Math.random() - 0.5) * 0.04;
      const sy = toSy(d.y + jitter);
      if (sx < PAD_L || sx > PAD_L + pw || sy < PAD_T || sy > PAD_T + ph) continue;
      ctx.beginPath();
      ctx.arc(sx, sy, 3, 0, Math.PI * 2);
      ctx.fillStyle = d.y === 1 ? 'rgba(109, 40, 217, 0.65)' : 'rgba(200, 60, 90, 0.65)';
      ctx.fill();
    }
  } else {
    for (const d of data) {
      const sx = toSx(d.x), sy = toSy(d.y);
      if (sx < PAD_L || sx > PAD_L + pw || sy < PAD_T || sy > PAD_T + ph) continue;
      ctx.beginPath();
      ctx.arc(sx, sy, 3.5, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(109, 40, 217, 0.65)';
      ctx.fill();
    }
  }

  // ── Legend ──
  const lx = PAD_L + 12, ly = PAD_T + 14;
  ctx.font = '11px IBM Plex Mono, monospace';

  ctx.strokeStyle = 'rgba(13, 138, 116, 0.65)';
  ctx.lineWidth = 2.5;
  ctx.setLineDash([7, 5]);
  ctx.beginPath(); ctx.moveTo(lx, ly); ctx.lineTo(lx + 22, ly); ctx.stroke();
  ctx.setLineDash([]);
  ctx.fillStyle = '#888899';
  ctx.textAlign = 'left';
  ctx.fillText('Population', lx + 28, ly + 4);

  if (fitResult) {
    ctx.strokeStyle = '#c2640a';
    ctx.lineWidth = 2;
    ctx.beginPath(); ctx.moveTo(lx, ly + 16); ctx.lineTo(lx + 22, ly + 16); ctx.stroke();
    ctx.fillStyle = '#888899';
    ctx.fillText('Fitted', lx + 28, ly + 20);
  }

  if (isLogistic && data.length > 0) {
    ctx.beginPath(); ctx.arc(lx + 6, ly + 32, 3, 0, Math.PI*2);
    ctx.fillStyle = 'rgba(109, 40, 217, 0.65)'; ctx.fill();
    ctx.fillStyle = '#888899';
    ctx.fillText('Y = 1', lx + 28, ly + 36);

    ctx.beginPath(); ctx.arc(lx + 6, ly + 48, 3, 0, Math.PI*2);
    ctx.fillStyle = 'rgba(200, 60, 90, 0.65)'; ctx.fill();
    ctx.fillStyle = '#888899';
    ctx.fillText('Y = 0', lx + 28, ly + 52);
  }
}

// ── Utility: nice tick steps ──
function niceStep(range, maxTicks) {
  const rough = range / maxTicks;
  const mag = Math.pow(10, Math.floor(Math.log10(rough)));
  const norm = rough / mag;
  let nice;
  if (norm < 1.5) nice = 1;
  else if (norm < 3.5) nice = 2;
  else if (norm < 7.5) nice = 5;
  else nice = 10;
  return nice * mag;
}

function fmtTick(v, step) {
  const decimals = step < 0.01 ? 2 : step < 0.1 ? 1 : step < 1 ? 1 : 0;
  return v.toFixed(decimals);
}

// ── Init ──
window.addEventListener('resize', render);
buildControls();
updateEquation();
render();
</script>
