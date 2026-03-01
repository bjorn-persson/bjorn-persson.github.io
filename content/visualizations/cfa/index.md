---
title: "Confirmatory Factor Analysis"
description: "Interactive visualization of confirmatory factor analysis: see how factor loadings determine the model-implied covariance matrix, and watch an optimizer converge to the best-fitting parameter values."
summary: "Explore how a two-factor CFA model constrains the covariance structure of observed variables, and watch gradient descent converge to the parameter values that minimize the discrepancy between observed and model-implied covariances."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&display=swap');

#cfa-wrap * { box-sizing: border-box; font-family: 'IBM Plex Mono', monospace; }

#cfa-wrap { color: var(--primary); max-width: 100%; }

.cfa-subtitle {
  font-size: 0.78rem;
  color: var(--secondary);
  margin: 0 0 1.2rem 0;
  line-height: 1.55;
}

.cfa-main {
  display: grid;
  grid-template-columns: 330px 1fr;
  gap: 16px;
  align-items: start;
}

@media (max-width: 820px) {
  .cfa-main { grid-template-columns: 1fr; }
}

.cfa-left { display: flex; flex-direction: column; gap: 12px; }

#path-canvas {
  width: 100%;
  height: 360px;
  background: #f4f4f8;
  border: 1px solid var(--border);
  border-radius: 4px;
  display: block;
}

.cfa-controls { display: flex; flex-direction: column; gap: 10px; }

.ctrl-group {
  background: #f4f4f8;
  border: 1px solid var(--border);
  border-radius: 4px;
  padding: 10px 12px;
}

.ctrl-group-title {
  font-size: 0.62rem;
  font-weight: 600;
  color: #888899;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 8px;
}

.slider-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 5px;
}
.slider-row:last-child { margin-bottom: 0; }

.slider-label {
  font-size: 0.68rem;
  color: var(--secondary);
  width: 26px;
  flex-shrink: 0;
}

.slider-row input[type=range] {
  flex: 1;
  -webkit-appearance: none;
  appearance: none;
  height: 4px;
  background: #e0e0ec;
  border-radius: 2px;
  outline: none;
}
.slider-row input[type=range]::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
}
.slider-row input[type=range]::-moz-range-thumb {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  border: none;
  cursor: pointer;
}

.slider-val {
  font-size: 0.68rem;
  color: var(--primary);
  width: 36px;
  text-align: right;
  flex-shrink: 0;
}

.btn-row {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.cfa-btn {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.7rem;
  padding: 5px 10px;
  background: transparent;
  border: 1px solid var(--border);
  color: var(--primary);
  border-radius: 3px;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s, background 0.15s;
}
.cfa-btn:hover  { border-color: #0d8a74; color: #0d8a74; }
.cfa-btn:active { background: rgba(13,138,116,0.08); }
.cfa-btn.active { border-color: #0d8a74; color: #0d8a74; }
.cfa-btn:disabled { opacity: 0.4; cursor: default; }

/* Right panel */
.cfa-right { display: flex; flex-direction: column; gap: 14px; }

.matrices-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.matrix-wrap { display: flex; flex-direction: column; gap: 4px; }

.matrix-title {
  font-size: 0.62rem;
  color: #888899;
  font-weight: 500;
  text-align: center;
}

.matrix-canvas-wrap { position: relative; }
.matrix-canvas-wrap canvas {
  display: block;
  width: 100%;
  background: #f4f4f8;
  border: 1px solid var(--border);
  border-radius: 3px;
}

.matrix-tooltip {
  position: absolute;
  background: rgba(30,30,50,0.88);
  color: #fff;
  font-size: 0.62rem;
  padding: 3px 7px;
  border-radius: 3px;
  pointer-events: none;
  display: none;
  white-space: nowrap;
  z-index: 10;
}

.fit-section { display: flex; flex-direction: column; gap: 8px; }

.fit-stats-row {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: center;
}

.fit-badge {
  background: #f4f4f8;
  border: 1px solid var(--border);
  border-left: 3px solid #0d8a74;
  border-radius: 3px;
  padding: 6px 12px;
  display: flex;
  flex-direction: column;
  gap: 1px;
}
.fit-badge-label {
  font-size: 0.6rem;
  color: #888899;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.fit-badge-val {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--primary);
}
.fit-badge-val.good { color: #0d8a74; }
.fit-badge-val.poor { color: #c83c5a; }

.status-badge {
  font-size: 0.68rem;
  color: #888899;
  padding: 4px 0;
}

#fit-curve-canvas {
  width: 100%;
  height: 110px;
  background: #f4f4f8;
  border: 1px solid var(--border);
  border-radius: 3px;
  display: block;
}
</style>

<div id="cfa-wrap">
<p class="cfa-subtitle">A CFA model specifies that latent <strong>factors</strong> cause observed <strong>indicators</strong>. The factor loadings (&lambda;) and factor correlation (&phi;) completely determine the model-implied covariance matrix &Sigma;(&theta;). Fitting the model means finding the parameters that minimize the difference between the <em>observed</em> covariance matrix S and the <em>model-implied</em> &Sigma;(&theta;). Adjust the sliders to explore how parameters shape &Sigma;(&theta;), then click <strong>Randomize &rarr; Run</strong> to watch gradient descent converge.</p>
<div class="cfa-main">
<div class="cfa-left">
<canvas id="path-canvas"></canvas>
<div class="cfa-controls">
<div class="ctrl-group">
<div class="ctrl-group-title">Factor 1 loadings (x&#x2081; &ndash; x&#x2083;)</div>
<div class="slider-row">
<span class="slider-label">&lambda;&#x2081;</span>
<input type="range" id="sl-l1" min="0.01" max="0.99" step="0.01" value="0.70">
<span class="slider-val" id="vl-l1">0.70</span>
</div>
<div class="slider-row">
<span class="slider-label">&lambda;&#x2082;</span>
<input type="range" id="sl-l2" min="0.01" max="0.99" step="0.01" value="0.70">
<span class="slider-val" id="vl-l2">0.70</span>
</div>
<div class="slider-row">
<span class="slider-label">&lambda;&#x2083;</span>
<input type="range" id="sl-l3" min="0.01" max="0.99" step="0.01" value="0.70">
<span class="slider-val" id="vl-l3">0.70</span>
</div>
</div>
<div class="ctrl-group">
<div class="ctrl-group-title">Factor 2 loadings (x&#x2084; &ndash; x&#x2086;)</div>
<div class="slider-row">
<span class="slider-label">&lambda;&#x2084;</span>
<input type="range" id="sl-l4" min="0.01" max="0.99" step="0.01" value="0.70">
<span class="slider-val" id="vl-l4">0.70</span>
</div>
<div class="slider-row">
<span class="slider-label">&lambda;&#x2085;</span>
<input type="range" id="sl-l5" min="0.01" max="0.99" step="0.01" value="0.70">
<span class="slider-val" id="vl-l5">0.70</span>
</div>
<div class="slider-row">
<span class="slider-label">&lambda;&#x2086;</span>
<input type="range" id="sl-l6" min="0.01" max="0.99" step="0.01" value="0.70">
<span class="slider-val" id="vl-l6">0.70</span>
</div>
</div>
<div class="ctrl-group">
<div class="ctrl-group-title">Factor correlation</div>
<div class="slider-row">
<span class="slider-label">&phi;&#x2081;&#x2082;</span>
<input type="range" id="sl-phi" min="-0.95" max="0.95" step="0.01" value="0.40">
<span class="slider-val" id="vl-phi">0.40</span>
</div>
</div>
</div>
</div>
<div class="cfa-right">
<div class="btn-row">
<button class="cfa-btn" id="btn-randomize">Randomize</button>
<button class="cfa-btn" id="btn-step">Step</button>
<button class="cfa-btn" id="btn-run">Run</button>
<button class="cfa-btn" id="btn-reset">Reset</button>
</div>
<div class="matrices-row">
<div class="matrix-wrap">
<div class="matrix-title">Observed S</div>
<div class="matrix-canvas-wrap">
<canvas id="mat-s"></canvas>
<div class="matrix-tooltip" id="tt-s"></div>
</div>
</div>
<div class="matrix-wrap">
<div class="matrix-title">Model-implied &Sigma;(&theta;)</div>
<div class="matrix-canvas-wrap">
<canvas id="mat-sigma"></canvas>
<div class="matrix-tooltip" id="tt-sigma"></div>
</div>
</div>
<div class="matrix-wrap">
<div class="matrix-title">Residuals S &minus; &Sigma;(&theta;)</div>
<div class="matrix-canvas-wrap">
<canvas id="mat-resid"></canvas>
<div class="matrix-tooltip" id="tt-resid"></div>
</div>
</div>
</div>
<div class="fit-section">
<div class="fit-stats-row">
<div class="fit-badge">
<span class="fit-badge-label">SRMR</span>
<span class="fit-badge-val" id="srmr-val">&mdash;</span>
</div>
<div class="fit-badge">
<span class="fit-badge-label">Iteration</span>
<span class="fit-badge-val" id="iter-val">&mdash;</span>
</div>
<span class="status-badge" id="status-badge">Adjust sliders or click Randomize &rarr; Run</span>
</div>
<canvas id="fit-curve-canvas"></canvas>
</div>
</div>
</div>
</div>

<script>
(function () {

  // ── True parameters (S is generated from these) ──────────────────────
  var TRUE_LAM = [0.7, 0.7, 0.7, 0.7, 0.7, 0.7];
  var TRUE_PHI = 0.4;

  // ── State ─────────────────────────────────────────────────────────────
  var lambda = TRUE_LAM.slice();
  var phi    = TRUE_PHI;
  var S      = computeSigma(TRUE_LAM, TRUE_PHI);

  var optRunning  = false;
  var optIter     = 0;
  var optHistory  = [];
  var animFrameId = null;
  var stepAlpha   = 0.05;

  // ── CFA math ──────────────────────────────────────────────────────────

  function computeSigma(lam, p) {
    var i, j, fi, fj, v;
    var m = [];
    for (i = 0; i < 6; i++) {
      m[i] = [];
      for (j = 0; j < 6; j++) m[i][j] = 0;
    }
    for (i = 0; i < 6; i++) {
      m[i][i] = 1.0;
      for (j = i + 1; j < 6; j++) {
        fi = i < 3 ? 0 : 1;
        fj = j < 3 ? 0 : 1;
        v  = fi === fj ? lam[i] * lam[j] : lam[i] * lam[j] * p;
        m[i][j] = v;
        m[j][i] = v;
      }
    }
    return m;
  }

  function matResidual(A, B) {
    var i, j, r = [];
    for (i = 0; i < 6; i++) {
      r[i] = [];
      for (j = 0; j < 6; j++) r[i][j] = A[i][j] - B[i][j];
    }
    return r;
  }

  function computeSRMR(A, B) {
    var ss = 0, i, j, d;
    for (i = 0; i < 6; i++)
      for (j = i; j < 6; j++) { d = A[i][j] - B[i][j]; ss += d * d; }
    return Math.sqrt(ss * 2 / (6 * 7));
  }

  function fitVal(lam, p) {
    var sig = computeSigma(lam, p);
    var ss = 0, i, j, d;
    for (i = 0; i < 6; i++)
      for (j = i; j < 6; j++) { d = S[i][j] - sig[i][j]; ss += d * d; }
    return ss;
  }

  // ── Gradient descent ──────────────────────────────────────────────────

  function gradient(lam, p) {
    var EPS = 1e-5, i;
    var f0  = fitVal(lam, p);
    var gL  = [];
    for (i = 0; i < 6; i++) {
      var lp = lam.slice(); lp[i] += EPS;
      var lm = lam.slice(); lm[i] -= EPS;
      gL[i] = (fitVal(lp, p) - fitVal(lm, p)) / (2 * EPS);
    }
    var gP = (fitVal(lam, p + EPS) - fitVal(lam, p - EPS)) / (2 * EPS);
    return { gL: gL, gP: gP, f0: f0 };
  }

  function clampL(v) { return Math.max(0.01, Math.min(0.99,  v)); }
  function clampP(v) { return Math.max(-0.95, Math.min(0.95, v)); }

  function doStep() {
    var g = gradient(lambda, phi);
    var a = stepAlpha, t, nL, nP, nF, i;
    for (t = 0; t < 14; t++) {
      nL = [];
      for (i = 0; i < 6; i++) nL[i] = clampL(lambda[i] - a * g.gL[i]);
      nP = clampP(phi - a * g.gP);
      nF = fitVal(nL, nP);
      if (nF < g.f0) break;
      a *= 0.5;
    }
    lambda = nL; phi = nP; optIter++;
    stepAlpha = nF < g.f0 * 0.96
      ? Math.min(0.15, stepAlpha * 1.06)
      : Math.max(0.001, stepAlpha * 0.75);

    var srmr = computeSRMR(S, computeSigma(lambda, phi));
    optHistory.push(srmr);
    syncSliders();
    renderAll();
    var gnorm = 0;
    for (i = 0; i < 6; i++) gnorm += g.gL[i] * g.gL[i];
    gnorm = Math.sqrt(gnorm + g.gP * g.gP);
    return gnorm < 1e-6 || srmr < 0.0005;
  }

  // ── Slider / state sync ───────────────────────────────────────────────

  var SLIDER_IDS = ['sl-l1','sl-l2','sl-l3','sl-l4','sl-l5','sl-l6','sl-phi'];
  var VALUE_IDS  = ['vl-l1','vl-l2','vl-l3','vl-l4','vl-l5','vl-l6','vl-phi'];

  function syncSliders() {
    for (var i = 0; i < 6; i++) {
      document.getElementById(SLIDER_IDS[i]).value = lambda[i].toFixed(2);
      document.getElementById(VALUE_IDS[i]).textContent = lambda[i].toFixed(2);
    }
    document.getElementById('sl-phi').value = phi.toFixed(2);
    document.getElementById('vl-phi').textContent = phi.toFixed(2);
  }

  function readSliders() {
    for (var i = 0; i < 6; i++) {
      lambda[i] = parseFloat(document.getElementById(SLIDER_IDS[i]).value);
      document.getElementById(VALUE_IDS[i]).textContent = lambda[i].toFixed(2);
    }
    phi = parseFloat(document.getElementById('sl-phi').value);
    document.getElementById('vl-phi').textContent = phi.toFixed(2);
  }

  // ── Canvas helpers ────────────────────────────────────────────────────

  function setupCanvas(el) {
    var rect = el.getBoundingClientRect();
    var dpr  = window.devicePixelRatio || 1;
    var w    = Math.max(4, Math.round(rect.width));
    var h    = Math.max(4, Math.round(rect.height));
    el.width   = w * dpr;
    el.height  = h * dpr;
    var ctx  = el.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    return { ctx: ctx, w: w, h: h };
  }

  function lerp3(t, c1, c2) {
    return [
      Math.round(c1[0] + t * (c2[0] - c1[0])),
      Math.round(c1[1] + t * (c2[1] - c1[1])),
      Math.round(c1[2] + t * (c2[2] - c1[2]))
    ];
  }

  function cellColor(v, mode) {
    var white = [255, 255, 255];
    var teal  = [13, 138, 116];
    var red   = [200, 60, 90];
    var c, tt;
    if (mode === 'pos') {
      c = lerp3(Math.max(0, Math.min(1, v)), white, teal);
      return 'rgb(' + c[0] + ',' + c[1] + ',' + c[2] + ')';
    }
    var scale = 0.25;
    if (v >= 0) {
      tt = Math.min(1, v / scale);
      c = lerp3(tt, white, teal);
    } else {
      tt = Math.min(1, -v / scale);
      c = lerp3(tt, white, red);
    }
    return 'rgb(' + c[0] + ',' + c[1] + ',' + c[2] + ')';
  }

  function roundedRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }

  // ── Matrix heatmap ────────────────────────────────────────────────────

  var MAT_LABELS = ['x\u2081','x\u2082','x\u2083','x\u2084','x\u2085','x\u2086'];

  function drawMatrix(canvasId, M, mode) {
    var el = document.getElementById(canvasId);
    if (!el) return;
    var s = setupCanvas(el);
    var ctx = s.ctx, w = s.w, h = s.h;
    var n   = 6;
    var pad = { l: 18, t: 4, r: 4, b: 18 };
    var cw  = (w - pad.l - pad.r) / n;
    var ch  = (h - pad.t - pad.b) / n;
    var i, j, x, y;

    ctx.font = '9px "IBM Plex Mono", monospace';

    for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++) {
        x = pad.l + j * cw;
        y = pad.t + i * ch;
        ctx.fillStyle = cellColor(M[i][j], mode);
        ctx.fillRect(x, y, cw, ch);
        ctx.strokeStyle = 'rgba(244,244,248,0.8)';
        ctx.lineWidth = 0.5;
        ctx.strokeRect(x, y, cw, ch);
      }
      ctx.fillStyle = '#888899';
      ctx.textAlign = 'right';
      ctx.fillText(MAT_LABELS[i], pad.l - 2, pad.t + (i + 0.67) * ch);
      ctx.textAlign = 'center';
      ctx.fillText(MAT_LABELS[i], pad.l + (i + 0.5) * cw, pad.t + n * ch + 13);
    }

    el._meta = { pad: pad, cw: cw, ch: ch, n: n, M: M };
  }

  function attachHover(canvasId, ttId) {
    var el = document.getElementById(canvasId);
    var tt = document.getElementById(ttId);
    el.addEventListener('mousemove', function (e) {
      if (!el._meta) return;
      var rect = el.getBoundingClientRect();
      var pad = el._meta.pad, cw = el._meta.cw, ch = el._meta.ch;
      var n = el._meta.n, M = el._meta.M;
      var mx = e.clientX - rect.left;
      var my = e.clientY - rect.top;
      var ci = Math.floor((mx - pad.l) / cw);
      var ri = Math.floor((my - pad.t) / ch);
      if (ci >= 0 && ci < n && ri >= 0 && ri < n) {
        tt.style.display = 'block';
        tt.style.left = (mx + 8) + 'px';
        tt.style.top  = Math.max(0, my - 24) + 'px';
        tt.textContent = MAT_LABELS[ri] + ', ' + MAT_LABELS[ci] + ': ' + M[ri][ci].toFixed(3);
      } else {
        tt.style.display = 'none';
      }
    });
    el.addEventListener('mouseleave', function () { tt.style.display = 'none'; });
  }

  // ── Path diagram ──────────────────────────────────────────────────────

  function arrow(ctx, x1, y1, x2, y2, color, lbl, lblRight, lblT) {
    ctx.save();
    ctx.strokeStyle = color; ctx.lineWidth = 1.5;
    ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke();
    var ang = Math.atan2(y2 - y1, x2 - x1), aL = 7;
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(x2, y2);
    ctx.lineTo(x2 - aL * Math.cos(ang - 0.4), y2 - aL * Math.sin(ang - 0.4));
    ctx.lineTo(x2 - aL * Math.cos(ang + 0.4), y2 - aL * Math.sin(ang + 0.4));
    ctx.closePath(); ctx.fill();
    if (lbl) {
      var t = (lblT !== undefined) ? lblT : 0.5;
      var mx = x1 + t * (x2 - x1), my = y1 + t * (y2 - y1);
      ctx.font = '9px "IBM Plex Mono", monospace';
      ctx.fillStyle = color;
      ctx.textAlign = lblRight ? 'left' : 'right';
      ctx.fillText(lbl, mx + (lblRight ? 5 : -5), my + 4);
    }
    ctx.restore();
  }

  function curvedDoubleArrow(ctx, x1, y1, x2, y2, lift, color, lbl) {
    var mx = (x1 + x2) / 2, my = (y1 + y2) / 2 - lift;
    ctx.save();
    ctx.strokeStyle = color; ctx.lineWidth = 1.5;
    ctx.beginPath(); ctx.moveTo(x1, y1); ctx.quadraticCurveTo(mx, my, x2, y2); ctx.stroke();
    var aL = 7, a2, a1;
    ctx.fillStyle = color;
    a2 = Math.atan2(y2 - my, x2 - mx);
    ctx.beginPath();
    ctx.moveTo(x2, y2);
    ctx.lineTo(x2 - aL * Math.cos(a2 - 0.4), y2 - aL * Math.sin(a2 - 0.4));
    ctx.lineTo(x2 - aL * Math.cos(a2 + 0.4), y2 - aL * Math.sin(a2 + 0.4));
    ctx.closePath(); ctx.fill();
    a1 = Math.atan2(y1 - my, x1 - mx);
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x1 - aL * Math.cos(a1 - 0.4), y1 - aL * Math.sin(a1 - 0.4));
    ctx.lineTo(x1 - aL * Math.cos(a1 + 0.4), y1 - aL * Math.sin(a1 + 0.4));
    ctx.closePath(); ctx.fill();
    if (lbl) {
      ctx.font = '10px "IBM Plex Mono", monospace';
      ctx.fillStyle = color;
      ctx.textAlign = 'center';
      ctx.fillText(lbl, mx, my - 5);
    }
    ctx.restore();
  }

  function drawPathDiagram() {
    var el = document.getElementById('path-canvas');
    if (!el) return;
    var s = setupCanvas(el);
    var ctx = s.ctx, w = s.w, h = s.h;
    ctx.clearRect(0, 0, w, h);

    var TEAL   = '#0d8a74';
    var PURPLE = '#6d28d9';
    var GRAY   = '#888899';

    var fR  = 32;
    var iW  = 50, iH = 24, iRad = 3;
    var fY  = 90;
    var iY  = h - 62;
    var f1X = w * 0.27, f2X = w * 0.73;
    var iXs = [], i;
    for (i = 0; i < 6; i++) iXs[i] = w * (0.09 + i * 0.165);

    // Factor correlation arc
    curvedDoubleArrow(ctx, f1X, fY - fR, f2X, fY - fR, 28, PURPLE,
      '\u03c6\u2081\u2082 = ' + phi.toFixed(2));

    // Factor -> indicator arrows
    var lblTs = [0.30, 0.42, 0.54, 0.54, 0.42, 0.30];
    for (i = 0; i < 6; i++) {
      var fX    = i < 3 ? f1X : f2X;
      var color = i < 3 ? TEAL : PURPLE;
      var right = i < 3;
      var lbl   = '\u03bb' + (i + 1) + '=' + lambda[i].toFixed(2);
      arrow(ctx, fX, fY + fR, iXs[i], iY - iH / 2, color, lbl, right, lblTs[i]);
    }

    // Factor circles
    var factors = [[f1X, 'F1', TEAL, 'rgba(13,138,116,0.12)'],
                   [f2X, 'F2', PURPLE, 'rgba(109,40,217,0.12)']];
    for (i = 0; i < factors.length; i++) {
      var f = factors[i];
      ctx.beginPath(); ctx.arc(f[0], fY, fR, 0, Math.PI * 2);
      ctx.fillStyle = f[3]; ctx.fill();
      ctx.strokeStyle = f[2]; ctx.lineWidth = 1.5; ctx.stroke();
      ctx.font = '13px "IBM Plex Mono", monospace';
      ctx.fillStyle = f[2]; ctx.textAlign = 'center';
      ctx.fillText(f[1], f[0], fY + 5);
    }

    // Indicators
    for (i = 0; i < 6; i++) {
      var x     = iXs[i];
      color = i < 3 ? TEAL : PURPLE;
      var fill  = i < 3 ? 'rgba(13,138,116,0.09)' : 'rgba(109,40,217,0.09)';
      roundedRect(ctx, x - iW/2, iY - iH/2, iW, iH, iRad);
      ctx.fillStyle = fill; ctx.fill();
      ctx.strokeStyle = color; ctx.lineWidth = 1.5; ctx.stroke();
      ctx.font = '11px "IBM Plex Mono", monospace';
      ctx.fillStyle = color; ctx.textAlign = 'center';
      ctx.fillText('x' + (i + 1), x, iY + 4);

      // Unique variance arrow (dashed, downward)
      var delta = 1 - lambda[i] * lambda[i];
      ctx.save();
      ctx.strokeStyle = GRAY; ctx.lineWidth = 1;
      ctx.setLineDash([3, 2]);
      ctx.beginPath();
      ctx.moveTo(x, iY + iH / 2);
      ctx.lineTo(x, iY + iH / 2 + 20);
      ctx.stroke();
      ctx.setLineDash([]);
      ctx.fillStyle = GRAY;
      ctx.beginPath();
      ctx.moveTo(x, iY + iH / 2 + 20);
      ctx.lineTo(x - 4, iY + iH / 2 + 13);
      ctx.lineTo(x + 4, iY + iH / 2 + 13);
      ctx.closePath(); ctx.fill();
      ctx.font = '8px "IBM Plex Mono", monospace';
      ctx.fillStyle = GRAY; ctx.textAlign = 'center';
      ctx.fillText('\u03b4=' + delta.toFixed(2), x, iY + iH / 2 + 31);
      ctx.restore();
    }

    // Footer note
    ctx.font = '8px "IBM Plex Mono", monospace';
    ctx.fillStyle = GRAY; ctx.textAlign = 'left';
    ctx.fillText('x\u2081\u2013x\u2083 \u2192 F1   x\u2084\u2013x\u2086 \u2192 F2   \u03b4 = 1\u2212\u03bb\u00b2', 4, h - 4);
  }

  // ── Fit curve ─────────────────────────────────────────────────────────

  function drawFitCurve() {
    var el = document.getElementById('fit-curve-canvas');
    if (!el) return;
    var s = setupCanvas(el);
    var ctx = s.ctx, w = s.w, h = s.h;
    var pad = { l: 44, t: 8, r: 10, b: 22 };
    var pw = w - pad.l - pad.r;
    var ph = h - pad.t - pad.b;

    ctx.strokeStyle = '#c0c0d8'; ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(pad.l, pad.t); ctx.lineTo(pad.l, pad.t + ph);
    ctx.lineTo(pad.l + pw, pad.t + ph);
    ctx.stroke();

    if (optHistory.length < 2) {
      ctx.font = '10px "IBM Plex Mono", monospace';
      ctx.fillStyle = '#aaaacc'; ctx.textAlign = 'center';
      ctx.fillText('Run the optimizer to see convergence', pad.l + pw / 2, pad.t + ph / 2 + 4);
      return;
    }

    var maxY = Math.max(0.02, optHistory[0] * 1.1);
    var n    = optHistory.length;
    var tick, frac, y, x, i;
    ctx.font = '9px "IBM Plex Mono", monospace';

    for (tick = 0; tick <= 4; tick++) {
      frac = tick / 4;
      y    = pad.t + ph - frac * ph;
      ctx.strokeStyle = '#e4e4f0'; ctx.lineWidth = 0.5;
      ctx.beginPath(); ctx.moveTo(pad.l, y); ctx.lineTo(pad.l + pw, y); ctx.stroke();
      ctx.fillStyle = '#888899'; ctx.textAlign = 'right';
      ctx.fillText((maxY * frac).toFixed(2), pad.l - 3, y + 3);
    }

    ctx.fillStyle = '#888899'; ctx.textAlign = 'center';
    ctx.fillText('iteration  (n = ' + n + ')', pad.l + pw / 2, h - 3);

    ctx.save(); ctx.translate(11, pad.t + ph / 2); ctx.rotate(-Math.PI / 2);
    ctx.fillText('SRMR', 0, 0); ctx.restore();

    ctx.beginPath(); ctx.strokeStyle = '#0d8a74'; ctx.lineWidth = 1.8; ctx.lineJoin = 'round';
    for (i = 0; i < n; i++) {
      x = pad.l + (i / Math.max(1, n - 1)) * pw;
      y = pad.t + ph - Math.min(1, optHistory[i] / maxY) * ph;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.stroke();

    var lx = pad.l + pw;
    var ly = pad.t + ph - Math.min(1, optHistory[n - 1] / maxY) * ph;
    ctx.beginPath(); ctx.arc(lx, ly, 3.5, 0, Math.PI * 2);
    ctx.fillStyle = '#0d8a74'; ctx.fill();
  }

  // ── Stats readout ─────────────────────────────────────────────────────

  function updateStats() {
    var srmr = computeSRMR(S, computeSigma(lambda, phi));
    var el = document.getElementById('srmr-val');
    el.textContent = srmr.toFixed(4);
    el.className = 'fit-badge-val' + (srmr < 0.05 ? ' good' : srmr > 0.1 ? ' poor' : '');
    document.getElementById('iter-val').textContent = optIter > 0 ? String(optIter) : '\u2014';
  }

  function setStatus(txt) { document.getElementById('status-badge').textContent = txt; }

  // ── Render ────────────────────────────────────────────────────────────

  function setMatrixHeights() {
    var ids = ['mat-s', 'mat-sigma', 'mat-resid'];
    for (var i = 0; i < ids.length; i++) {
      var el = document.getElementById(ids[i]);
      if (!el) continue;
      var pw = el.parentElement.getBoundingClientRect().width;
      el.style.height = Math.max(80, Math.round(pw)) + 'px';
    }
  }

  function renderAll() {
    var sigma = computeSigma(lambda, phi);
    var resid = matResidual(S, sigma);
    drawPathDiagram();
    drawMatrix('mat-s',     S,     'pos');
    drawMatrix('mat-sigma', sigma, 'pos');
    drawMatrix('mat-resid', resid, 'div');
    drawFitCurve();
    updateStats();
  }

  // ── Optimizer loop ────────────────────────────────────────────────────

  function stopOpt() {
    optRunning = false;
    if (animFrameId) { cancelAnimationFrame(animFrameId); animFrameId = null; }
    var btn = document.getElementById('btn-run');
    btn.textContent = 'Run'; btn.classList.remove('active');
  }

  function animLoop() {
    if (!optRunning) return;
    var done = doStep();
    if (done || optIter >= 600) {
      stopOpt();
      var srmr = computeSRMR(S, computeSigma(lambda, phi));
      setStatus('Converged after ' + optIter + ' iterations \u2014 SRMR = ' + srmr.toFixed(4));
      renderAll();
    } else {
      animFrameId = requestAnimationFrame(animLoop);
    }
  }

  // ── Buttons ───────────────────────────────────────────────────────────

  document.getElementById('btn-randomize').addEventListener('click', function () {
    stopOpt();
    for (var i = 0; i < 6; i++) lambda[i] = 0.15 + Math.random() * 0.7;
    phi = clampP(-0.7 + Math.random() * 1.4);
    optIter = 0; optHistory = []; stepAlpha = 0.05;
    syncSliders();
    setStatus('Randomized \u2014 click Run to optimize');
    renderAll();
  });

  document.getElementById('btn-step').addEventListener('click', function () {
    if (optRunning) stopOpt();
    var done = doStep();
    var srmr = computeSRMR(S, computeSigma(lambda, phi));
    setStatus(done
      ? 'Converged \u2014 SRMR = ' + srmr.toFixed(4)
      : 'Iteration ' + optIter + ' \u2014 SRMR = ' + srmr.toFixed(4));
    renderAll();
  });

  document.getElementById('btn-run').addEventListener('click', function () {
    if (optRunning) {
      stopOpt();
      setStatus('Paused at iteration ' + optIter);
      return;
    }
    optRunning = true;
    this.textContent = 'Pause'; this.classList.add('active');
    stepAlpha = 0.05;
    setStatus('Optimizing\u2026');
    animFrameId = requestAnimationFrame(animLoop);
  });

  document.getElementById('btn-reset').addEventListener('click', function () {
    stopOpt();
    lambda = TRUE_LAM.slice(); phi = TRUE_PHI;
    optIter = 0; optHistory = []; stepAlpha = 0.05;
    syncSliders();
    setStatus('Reset to true parameters \u2014 SRMR = 0');
    renderAll();
  });

  // ── Sliders ───────────────────────────────────────────────────────────

  function onSliderInput() {
    if (optRunning) stopOpt();
    readSliders();
    optHistory = []; optIter = 0;
    setStatus('Manual mode');
    renderAll();
  }

  for (var si = 0; si < SLIDER_IDS.length; si++) {
    document.getElementById(SLIDER_IDS[si]).addEventListener('input', onSliderInput);
  }

  // ── Hover tooltips ────────────────────────────────────────────────────

  attachHover('mat-s',     'tt-s');
  attachHover('mat-sigma', 'tt-sigma');
  attachHover('mat-resid', 'tt-resid');

  // ── Resize ────────────────────────────────────────────────────────────

  var resizeTimer;
  window.addEventListener('resize', function () {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(function () { setMatrixHeights(); renderAll(); }, 80);
  });

  // ── Init ──────────────────────────────────────────────────────────────

  setMatrixHeights();
  renderAll();

})();
</script>
