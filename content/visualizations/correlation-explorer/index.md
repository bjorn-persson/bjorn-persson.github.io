---
title: "Correlation Explorer"
description: "Interactive visualization comparing Pearson r, Spearman ρ, Kendall τ, mutual information, and distance correlation. Click to place points, drag to reposition, and watch all five association measures update in real time."
summary: "Compare Pearson r, Spearman ρ, Kendall τ, mutual information, and distance correlation interactively. Place and drag points to see all five association measures update in real time."
---

<style>
  @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');
  .ce-subtitle {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.78rem;
    color: var(--secondary);
    margin-bottom: 16px;
    line-height: 1.5;
  }
  .ce-controls {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(175px, 1fr));
    gap: 10px 16px;
    margin-bottom: 14px;
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.78rem;
  }
  .ce-control-group {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }
  .ce-control-group label {
    color: var(--secondary);
    font-size: 0.72rem;
  }
  .ce-control-group .val {
    color: #0d8a74;
    font-weight: 600;
  }
  .ce-controls input[type="range"] {
    -webkit-appearance: none;
    appearance: none;
    width: 100%;
    height: 4px;
    background: #e0e0ec;
    border-radius: 2px;
    outline: none;
  }
  .ce-controls input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    appearance: none;
    width: 14px;
    height: 14px;
    border-radius: 50%;
    background: #0d8a74;
    cursor: pointer;
  }
  .ce-controls input[type="range"]::-moz-range-thumb {
    width: 14px;
    height: 14px;
    border-radius: 50%;
    background: #0d8a74;
    cursor: pointer;
    border: none;
  }
  .ce-button-row {
    display: flex;
    gap: 8px;
    margin-bottom: 14px;
    flex-wrap: wrap;
    align-items: center;
  }
  .ce-btn {
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
  .ce-btn:hover {
    border-color: #0d8a74;
    color: #0d8a74;
  }
  .ce-btn.action {
    border-color: var(--border);
    color: var(--secondary);
  }
  .ce-btn.action:hover {
    border-color: #c2640a;
    color: #c2640a;
  }
  .ce-btn.destructive:hover {
    border-color: #c83c5a;
    color: #c83c5a;
  }
  .ce-info-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 16px;
    height: 16px;
    padding: 0;
    border-radius: 50%;
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.58rem;
    font-weight: 600;
    background: none;
    border: 1px solid var(--border);
    color: var(--secondary);
    cursor: pointer;
    flex-shrink: 0;
    line-height: 1;
    transition: border-color 0.2s, color 0.2s;
  }
  .ce-info-btn:hover {
    border-color: #0d8a74;
    color: #0d8a74;
  }
  .ce-main-area {
    position: relative;
  }
  .ce-canvas-wrap {
    width: 100%;
  }
  .ce-canvas-wrap canvas {
    display: block;
    width: 100%;
    aspect-ratio: 1 / 1;
    background: #f4f4f8;
    border-radius: 6px;
    cursor: crosshair;
  }
  .ce-canvas-hint {
    margin-top: 6px;
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.68rem;
    color: var(--secondary);
    line-height: 1.5;
  }
  .ce-side-panel {
    position: absolute;
    top: 0;
    left: calc(100% + 18px);
    width: 220px;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  .ce-stat-card {
    background: #f4f4f8;
    border-radius: 6px;
    padding: 12px 14px;
    border-left: 3px solid #e0e0ec;
    transition: border-color 0.3s;
  }
  .ce-stat-card.active {
    border-left-color: #0d8a74;
  }
  .ce-stat-label {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.7rem;
    color: var(--secondary);
    margin-bottom: 2px;
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .ce-stat-label .badge {
    font-size: 0.58rem;
    padding: 1px 5px;
    border-radius: 3px;
    background: rgba(13, 138, 116, 0.1);
    color: #0d8a74;
  }
  .ce-stat-value {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 1.4rem;
    font-weight: 600;
    color: #0d8a74;
    margin: 4px 0;
    letter-spacing: -0.02em;
  }
  .ce-stat-value.na {
    color: #c0c0d8;
    font-size: 1.1rem;
  }
  .ce-stat-desc {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.62rem;
    color: var(--secondary);
    line-height: 1.45;
  }
  .ce-stat-bar-wrap {
    height: 3px;
    background: #e0e0ec;
    border-radius: 2px;
    margin-top: 6px;
    overflow: hidden;
  }
  .ce-stat-bar {
    height: 100%;
    border-radius: 2px;
    transition: width 0.3s ease, background 0.3s;
    width: 0%;
  }
  .ce-n-card {
    background: #f4f4f8;
    border-radius: 6px;
    padding: 10px 14px;
    text-align: center;
  }
  .ce-n-label {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.68rem;
    color: var(--secondary);
  }
  .ce-n-value {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 1.6rem;
    font-weight: 600;
    color: var(--primary);
  }
  .ce-note {
    margin-top: 14px;
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.68rem;
    color: var(--secondary);
    line-height: 1.55;
    max-width: 800px;
  }
  .ce-preset-label {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.68rem;
    color: var(--secondary);
    margin-right: 4px;
  }
  .ce-modal-overlay {
    display: none;
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(60, 60, 80, 0.6);
    z-index: 1000;
    justify-content: center;
    align-items: center;
    padding: 20px;
  }
  .ce-modal-overlay.visible {
    display: flex;
  }
  .ce-modal {
    background: var(--theme);
    border: 1px solid var(--border);
    border-radius: 8px;
    max-width: 540px;
    width: 100%;
    max-height: 80vh;
    overflow-y: auto;
    padding: 24px 28px;
    position: relative;
  }
  .ce-modal h2 {
    font-family: 'Source Serif 4', serif;
    font-size: 1.1rem;
    color: var(--primary);
    margin-bottom: 4px;
    padding-right: 30px;
  }
  .ce-modal .modal-badge {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.62rem;
    padding: 2px 7px;
    border-radius: 3px;
    background: rgba(13, 138, 116, 0.1);
    color: #0d8a74;
    display: inline-block;
    margin-bottom: 14px;
  }
  .ce-modal p {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.74rem;
    color: var(--secondary);
    line-height: 1.65;
    margin-bottom: 8px;
  }
  .ce-modal .formula {
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
  .ce-modal .section-label {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.63rem;
    color: var(--secondary);
    text-transform: uppercase;
    letter-spacing: 0.08em;
    margin-top: 16px;
    margin-bottom: 4px;
  }
  .ce-modal-close {
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
  .ce-modal-close:hover {
    color: var(--primary);
  }
  @media (max-width: 900px) {
    .ce-side-panel {
      position: static;
      width: 100%;
      flex-direction: row;
      flex-wrap: wrap;
      margin-top: 14px;
    }
    .ce-stat-card {
      flex: 1;
      min-width: 140px;
    }
  }
</style>
<div class="ce-controls">
  <div class="ce-control-group">
    <label>Preset N: <span class="val" id="v_n">60</span></label>
    <input type="range" id="s_n" min="10" max="500" step="1" value="60"
      oninput="document.getElementById('v_n').textContent=this.value">
  </div>
  <div class="ce-control-group">
    <label>Signal strength: <span class="val" id="v_str">0.80</span></label>
    <input type="range" id="s_str" min="-1" max="1" step="0.01" value="0.80"
      oninput="document.getElementById('v_str').textContent=parseFloat(this.value).toFixed(2)">
  </div>
</div>
<div class="ce-button-row">
  <span class="ce-preset-label">Presets:</span>
  <button class="ce-btn" onclick="loadPreset('linear')">Linear</button>
  <button class="ce-btn" onclick="loadPreset('quadratic')">Quadratic</button>
  <button class="ce-btn" onclick="loadPreset('heteroscedastic')">Heteroscedastic</button>
  <button class="ce-btn" onclick="loadPreset('circle')">Circle</button>
  <button class="ce-btn" onclick="loadPreset('x-shape')">X-shape</button>
  <button class="ce-btn" onclick="loadPreset('sine')">Sinusoidal</button>
  <button class="ce-btn" onclick="loadPreset('random')">Random</button>
  <button class="ce-btn action destructive" onclick="clearPoints()">Clear</button>
</div>
<div class="ce-main-area">
  <div class="ce-canvas-wrap">
    <canvas id="canvas"></canvas>
    <div class="ce-canvas-hint">
      Click to add · Drag to move · Shift-click to remove
    </div>
  </div>
  <div class="ce-side-panel">
    <div class="ce-n-card">
      <div class="ce-n-label">Points</div>
      <div class="ce-n-value" id="nValue">0</div>
    </div>
    <div class="ce-stat-card" id="card-pearson">
      <div class="ce-stat-label">
        Pearson r <span class="badge">linear</span>
        <button class="ce-info-btn" onclick="showInfo('pearson')" title="About Pearson r">?</button>
      </div>
      <div class="ce-stat-value na" id="val-pearson">—</div>
      <div class="ce-stat-bar-wrap"><div class="ce-stat-bar" id="bar-pearson"></div></div>
      <div class="ce-stat-desc">Linear association. Sensitive to outliers.</div>
    </div>
    <div class="ce-stat-card" id="card-spearman">
      <div class="ce-stat-label">
        Spearman ρ <span class="badge">rank</span>
        <button class="ce-info-btn" onclick="showInfo('spearman')" title="About Spearman ρ">?</button>
      </div>
      <div class="ce-stat-value na" id="val-spearman">—</div>
      <div class="ce-stat-bar-wrap"><div class="ce-stat-bar" id="bar-spearman"></div></div>
      <div class="ce-stat-desc">Monotonic rank-based. Robust to outliers.</div>
    </div>
    <div class="ce-stat-card" id="card-kendall">
      <div class="ce-stat-label">
        Kendall τ <span class="badge">concordance</span>
        <button class="ce-info-btn" onclick="showInfo('kendall')" title="About Kendall τ">?</button>
      </div>
      <div class="ce-stat-value na" id="val-kendall">—</div>
      <div class="ce-stat-bar-wrap"><div class="ce-stat-bar" id="bar-kendall"></div></div>
      <div class="ce-stat-desc">Pairwise concordance. Robust at small N.</div>
    </div>
    <div class="ce-stat-card" id="card-mi">
      <div class="ce-stat-label">
        Mutual Info <span class="badge">nonlinear</span>
        <button class="ce-info-btn" onclick="showInfo('mi')" title="About Mutual Information">?</button>
      </div>
      <div class="ce-stat-value na" id="val-mi">—</div>
      <div class="ce-stat-bar-wrap"><div class="ce-stat-bar" id="bar-mi"></div></div>
      <div class="ce-stat-desc">KNN estimator (k=3). Biased at small N.</div>
    </div>
    <div class="ce-stat-card" id="card-dcor">
      <div class="ce-stat-label">
        dCor <span class="badge">nonlinear</span>
        <button class="ce-info-btn" onclick="showInfo('dcor')" title="About Distance Correlation">?</button>
      </div>
      <div class="ce-stat-value na" id="val-dcor">—</div>
      <div class="ce-stat-bar-wrap"><div class="ce-stat-bar" id="bar-dcor"></div></div>
      <div class="ce-stat-desc">Zero iff independent. Range [0, 1].</div>
    </div>
  </div>
</div>
<p class="ce-note">
  Pearson, Spearman, and Kendall range [−1, 1]. MI ≥ 0 (nats); bar uses heuristic cap.
  dCor ∈ [0, 1]. MI uses Kraskov et al. (2004) KNN with k=3 — noisy and upward-biased at small N.
  Points live in [0, 1]². Click the <strong>?</strong> buttons for detailed descriptions.
</p>
<div class="ce-modal-overlay" id="modalOverlay" onclick="if(event.target===this)closeInfo()">
  <div class="ce-modal">
    <button class="ce-modal-close" onclick="closeInfo()">×</button>
    <h2 id="modalTitle"></h2>
    <span class="modal-badge" id="modalBadge"></span>
    <div id="modalBody"></div>
  </div>
</div>

<script>
// ══════════════════════════════════
// STATE
// ══════════════════════════════════
let points = [];
let dragging = null;
let dragStarted = false;

const GRAB_RADIUS = 12;
const POINT_RADIUS = 5;
const MIN_N_CORR = 3;
const MIN_N_MI = 5;
const MIN_N_DCOR = 4;

// ══════════════════════════════════
// INFO CONTENT
// ══════════════════════════════════
const infoContent = {
  pearson: {
    title: 'Pearson Product-Moment Correlation (r)',
    badge: 'linear association',
    body: `
      <p>The Pearson correlation measures the strength and direction of the <em>linear</em> relationship between two continuous variables. It is the ratio of their covariance to the product of their standard deviations.</p>

      <div class="formula">r = Σ(xᵢ − x̄)(yᵢ − ȳ) / √[Σ(xᵢ − x̄)² · Σ(yᵢ − ȳ)²]</div>

      <div class="section-label">Range</div>
      <p>[−1, +1]. Values of ±1 indicate a perfect linear relationship. Zero indicates no linear association — but the variables may still be strongly dependent nonlinearly (try the Circle or Quadratic presets).</p>

      <div class="section-label">Assumptions</div>
      <p>Pearson r is a descriptive statistic computable on any paired data. However, inferential tests (p-values, CIs) assume bivariate normality or at least homoscedasticity and absence of extreme outliers. It is not robust: a single outlier can dramatically shift r.</p>

      <div class="section-label">When it fails</div>
      <p>Any nonlinear but dependent relationship (quadratic, circular, sinusoidal) can produce r ≈ 0. Heteroscedastic data violate assumptions underlying inferential use. Also sensitive to range restriction.</p>

      <div class="section-label">Try it</div>
      <p>Load the Circle preset — Pearson r will be near zero despite obvious dependence. Then compare with MI and dCor.</p>
    `
  },
  spearman: {
    title: 'Spearman Rank Correlation (ρ)',
    badge: 'monotonic association',
    body: `
      <p>Spearman ρ is the Pearson correlation computed on the <em>ranks</em> of the data rather than raw values. It measures monotonic (not necessarily linear) association.</p>

      <div class="formula">ρ = Pearson(rank(X), rank(Y))</div>

      <div class="section-label">Range</div>
      <p>[−1, +1]. Values of ±1 indicate a perfectly monotonic relationship — every increase in X is matched by a consistent increase (or decrease) in Y, regardless of functional form.</p>

      <div class="section-label">Properties</div>
      <p>Because it operates on ranks, Spearman ρ is robust to outliers and invariant under any monotone transformation of the data (log, square root, etc.). Suitable for ordinal data or monotonic-but-nonlinear relationships.</p>

      <div class="section-label">Compared to Pearson</div>
      <p>Spearman equals Pearson when the relationship is perfectly linear. It diverges when the relationship is monotonic but curved (e.g., exponential growth). It still fails for non-monotonic dependencies (circle, sine).</p>

      <div class="section-label">Compared to Kendall</div>
      <p>Both are rank-based. Spearman is more sensitive to errors in extreme ranks; Kendall has better small-sample properties. In practice they usually agree in sign and significance.</p>
    `
  },
  kendall: {
    title: 'Kendall Rank Correlation (τ-b)',
    badge: 'pairwise concordance',
    body: `
      <p>Kendall τ examines every pair of observations and classifies it as concordant (both variables move in the same direction), discordant (opposite directions), or tied. The τ-b variant corrects for ties.</p>

      <div class="formula">τ = (C − D) / √[(n₀ − tiedX)(n₀ − tiedY)]</div>
      <p>where C = concordant pairs, D = discordant pairs, n₀ = n(n−1)/2.</p>

      <div class="section-label">Range</div>
      <p>[−1, +1]. The interpretation is direct: it approximates the difference in probability that a random pair is concordant vs. discordant.</p>

      <div class="section-label">When to prefer over Spearman</div>
      <p>Kendall τ has better statistical properties at small N — its variance is more tractable and its sampling distribution converges faster. It handles ties more gracefully. However, the naive implementation is O(n²) vs O(n log n) for Spearman.</p>

      <div class="section-label">Magnitude vs. Spearman</div>
      <p>In practice |τ| &lt; |ρ| for the same data. This is not a deficiency — the two statistics scale differently. A rough conversion: ρ ≈ sin(πτ/2), though this is only approximate.</p>

      <div class="section-label">Limitations</div>
      <p>Same as Spearman: fails for non-monotonic dependence (circle, X-shape, sine).</p>
    `
  },
  mi: {
    title: 'Mutual Information (MI)',
    badge: 'general dependence · information-theoretic',
    body: `
      <p>Mutual information quantifies how much knowing one variable reduces uncertainty about the other. Unlike correlation coefficients, MI detects <em>any</em> kind of statistical dependence — linear, monotonic, or otherwise.</p>

      <div class="formula">I(X;Y) = ∫∫ p(x,y) log[p(x,y) / (p(x)p(y))] dx dy</div>

      <div class="section-label">Range</div>
      <p>[0, ∞) in nats (natural log). MI = 0 iff X and Y are independent. There is no fixed upper bound; it depends on the marginal entropies. This makes raw MI values hard to compare across datasets without normalization.</p>

      <div class="section-label">Estimation method</div>
      <p>This tool uses the Kraskov–Stögbauer–Grassberger (KSG) k-nearest-neighbour estimator (2004), algorithm I(1), with k = 3. It uses Chebyshev (max-norm) distance for joint neighbourhoods and counts marginal neighbours strictly within that radius. This avoids binning, which would require arbitrary bin-width choices and discard information about within-bin structure.</p>

      <div class="section-label">Caveats</div>
      <p>The KSG estimator is upward-biased at small N — even independent data will produce MI &gt; 0. Estimates become reliable around N ≥ 50–100. The estimate here is floored at 0 since negative values are pure estimation artifact. For formal testing, a permutation test against the null of independence is recommended.</p>

      <div class="section-label">Try it</div>
      <p>Load the Circle preset: Pearson ≈ 0, but MI is clearly positive — it captures the circular dependence that linear measures miss entirely.</p>
    `
  },
  dcor: {
    title: 'Distance Correlation (dCor)',
    badge: 'general dependence · metric-based',
    body: `
      <p>Distance correlation, introduced by Székely, Rizzo &amp; Bakirov (2007), measures both linear and nonlinear association. Its defining property: dCor = 0 if and only if X and Y are independent (for finite variance variables).</p>

      <div class="formula">dCor(X,Y) = dCov(X,Y) / √[dVar(X) · dVar(Y)]</div>
      <p>where dCov is computed from doubly-centered pairwise Euclidean distance matrices.</p>

      <div class="section-label">Range</div>
      <p>[0, 1]. Unlike Pearson/Spearman/Kendall, dCor is unsigned — it measures dependence strength without indicating direction.</p>

      <div class="section-label">How it works</div>
      <p>For each variable, compute the matrix of all pairwise distances, then doubly center it (subtract row means, column means, add back grand mean). The distance covariance is the average elementwise product of these centered matrices. This captures dependence that linear methods miss.</p>

      <div class="section-label">Compared to MI</div>
      <p>Both detect arbitrary dependence. dCor advantages: exact zero under independence (no estimation bias issue), no tuning parameters, well-developed asymptotic theory for testing. Disadvantages: O(n²) computation, and for some complex dependency structures MI can have more statistical power.</p>

      <div class="section-label">Try it</div>
      <p>Load the X-shape preset: all three signed correlations collapse to ≈ 0, but dCor and MI both detect the dependence.</p>
    `
  },
};

function showInfo(key) {
  const info = infoContent[key];
  document.getElementById('modalTitle').textContent = info.title;
  document.getElementById('modalBadge').textContent = info.badge;
  document.getElementById('modalBody').innerHTML = info.body;
  document.getElementById('modalOverlay').classList.add('visible');
}

function closeInfo() {
  document.getElementById('modalOverlay').classList.remove('visible');
}

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') closeInfo();
});

// ══════════════════════════════════
// CANVAS SETUP
// ══════════════════════════════════
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');

function getCanvasDims() {
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  return { W: rect.width, H: rect.height };
}

const PAD_L = 42, PAD_R = 14, PAD_T = 14, PAD_B = 34;

function plotW(W) { return W - PAD_L - PAD_R; }
function plotH(H) { return H - PAD_T - PAD_B; }
function toSx(v, W) { return PAD_L + v * plotW(W); }
function toSy(v, H) { return PAD_T + plotH(H) - v * plotH(H); }
function fromSx(sx, W) { return (sx - PAD_L) / plotW(W); }
function fromSy(sy, H) { return 1 - (sy - PAD_T) / plotH(H); }

// ══════════════════════════════════
// RENDERING
// ══════════════════════════════════
function render() {
  const { W, H } = getCanvasDims();
  ctx.clearRect(0, 0, W, H);

  const pw = plotW(W), ph = plotH(H);

  // Grid
  ctx.strokeStyle = '#e4e4f0';
  ctx.lineWidth = 0.5;
  for (let t = 0; t <= 1.001; t += 0.2) {
    const sx = toSx(t, W), sy = toSy(t, H);
    ctx.beginPath(); ctx.moveTo(sx, PAD_T); ctx.lineTo(sx, PAD_T + ph); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(PAD_L, sy); ctx.lineTo(PAD_L + pw, sy); ctx.stroke();
  }

  // Axes
  ctx.strokeStyle = '#c0c0d8';
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(PAD_L, PAD_T + ph); ctx.lineTo(PAD_L + pw, PAD_T + ph); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(PAD_L, PAD_T); ctx.lineTo(PAD_L, PAD_T + ph); ctx.stroke();

  // Tick labels
  ctx.font = '11px IBM Plex Mono, monospace';
  ctx.fillStyle = '#888899';
  ctx.textAlign = 'center';
  for (let t = 0; t <= 1.001; t += 0.2) {
    ctx.fillText(t.toFixed(1), toSx(t, W), PAD_T + ph + 16);
  }
  ctx.textAlign = 'right';
  for (let t = 0; t <= 1.001; t += 0.2) {
    ctx.fillText(t.toFixed(1), PAD_L - 6, toSy(t, H) + 4);
  }

  // Axis labels
  ctx.fillStyle = '#888899';
  ctx.font = '12px IBM Plex Mono, monospace';
  ctx.textAlign = 'center';
  ctx.fillText('X', PAD_L + pw / 2, PAD_T + ph + 30);
  ctx.save();
  ctx.translate(13, PAD_T + ph / 2);
  ctx.rotate(-Math.PI / 2);
  ctx.fillText('Y', 0, 0);
  ctx.restore();

  // Points
  for (let i = 0; i < points.length; i++) {
    const p = points[i];
    const sx = toSx(p.x, W), sy = toSy(p.y, H);
    ctx.beginPath();
    ctx.arc(sx, sy, POINT_RADIUS, 0, Math.PI * 2);
    ctx.fillStyle = (i === dragging)
      ? 'rgba(194, 100, 10, 0.9)'
      : 'rgba(109, 40, 217, 0.65)';
    ctx.fill();
  }

  // Empty state
  if (points.length === 0) {
    ctx.fillStyle = '#c0c0d8';
    ctx.font = '14px IBM Plex Mono, monospace';
    ctx.textAlign = 'center';
    ctx.fillText('Click anywhere to add points', PAD_L + pw / 2, PAD_T + ph / 2);
  }
}

// ══════════════════════════════════
// INTERACTION
// ══════════════════════════════════
function getMousePos(e) {
  const rect = canvas.getBoundingClientRect();
  return { mx: e.clientX - rect.left, my: e.clientY - rect.top };
}

function findNearest(mx, my) {
  const rect = canvas.getBoundingClientRect();
  const W = rect.width, H = rect.height;
  let best = -1, bestDist = Infinity;
  for (let i = 0; i < points.length; i++) {
    const sx = toSx(points[i].x, W), sy = toSy(points[i].y, H);
    const d = Math.hypot(mx - sx, my - sy);
    if (d < bestDist) { bestDist = d; best = i; }
  }
  return bestDist <= GRAB_RADIUS ? best : -1;
}

canvas.addEventListener('mousedown', (e) => {
  e.preventDefault();
  const { mx, my } = getMousePos(e);
  const rect = canvas.getBoundingClientRect();
  const W = rect.width, H = rect.height;

  if (e.shiftKey) {
    const idx = findNearest(mx, my);
    if (idx >= 0) { points.splice(idx, 1); update(); }
    return;
  }

  const idx = findNearest(mx, my);
  if (idx >= 0) {
    dragging = idx;
    dragStarted = false;
    render();
    return;
  }

  const x = Math.max(0, Math.min(1, fromSx(mx, W)));
  const y = Math.max(0, Math.min(1, fromSy(my, H)));
  points.push({ x, y });
  update();
});

canvas.addEventListener('mousemove', (e) => {
  if (dragging === null) return;
  dragStarted = true;
  const { mx, my } = getMousePos(e);
  const rect = canvas.getBoundingClientRect();
  points[dragging].x = Math.max(0, Math.min(1, fromSx(mx, rect.width)));
  points[dragging].y = Math.max(0, Math.min(1, fromSy(my, rect.height)));
  update();
});

canvas.addEventListener('mouseup', () => { dragging = null; render(); });
canvas.addEventListener('mouseleave', () => { dragging = null; render(); });

// Touch
canvas.addEventListener('touchstart', (e) => {
  e.preventDefault();
  const touch = e.touches[0];
  const rect = canvas.getBoundingClientRect();
  const mx = touch.clientX - rect.left, my = touch.clientY - rect.top;

  const idx = findNearest(mx, my);
  if (idx >= 0) { dragging = idx; dragStarted = false; render(); return; }

  const x = Math.max(0, Math.min(1, fromSx(mx, rect.width)));
  const y = Math.max(0, Math.min(1, fromSy(my, rect.height)));
  points.push({ x, y });
  update();
}, { passive: false });

canvas.addEventListener('touchmove', (e) => {
  if (dragging === null) return;
  e.preventDefault();
  dragStarted = true;
  const touch = e.touches[0];
  const rect = canvas.getBoundingClientRect();
  points[dragging].x = Math.max(0, Math.min(1, fromSx(touch.clientX - rect.left, rect.width)));
  points[dragging].y = Math.max(0, Math.min(1, fromSy(touch.clientY - rect.top, rect.height)));
  update();
}, { passive: false });

canvas.addEventListener('touchend', () => { dragging = null; render(); });

// ══════════════════════════════════
// STATISTICS
// ══════════════════════════════════
function pearson(pts) {
  const n = pts.length;
  if (n < MIN_N_CORR) return null;
  let sx = 0, sy = 0, sxx = 0, syy = 0, sxy = 0;
  for (const p of pts) {
    sx += p.x; sy += p.y;
    sxx += p.x * p.x; syy += p.y * p.y;
    sxy += p.x * p.y;
  }
  const num = n * sxy - sx * sy;
  const den = Math.sqrt((n * sxx - sx * sx) * (n * syy - sy * sy));
  return den < 1e-15 ? 0 : num / den;
}

function rank(arr) {
  const n = arr.length;
  const indexed = arr.map((v, i) => ({ v, i }));
  indexed.sort((a, b) => a.v - b.v);
  const ranks = new Array(n);
  let i = 0;
  while (i < n) {
    let j = i;
    while (j < n - 1 && indexed[j + 1].v === indexed[j].v) j++;
    const avgRank = (i + j) / 2 + 1;
    for (let k = i; k <= j; k++) ranks[indexed[k].i] = avgRank;
    i = j + 1;
  }
  return ranks;
}

function spearman(pts) {
  const n = pts.length;
  if (n < MIN_N_CORR) return null;
  const rx = rank(pts.map(p => p.x));
  const ry = rank(pts.map(p => p.y));
  const ranked = pts.map((_, i) => ({ x: rx[i], y: ry[i] }));
  return pearson(ranked);
}

function kendall(pts) {
  const n = pts.length;
  if (n < MIN_N_CORR) return null;
  let concordant = 0, discordant = 0, tiedX = 0, tiedY = 0;
  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      const dx = pts[i].x - pts[j].x;
      const dy = pts[i].y - pts[j].y;
      if (Math.abs(dx) < 1e-15 && Math.abs(dy) < 1e-15) { tiedX++; tiedY++; }
      else if (Math.abs(dx) < 1e-15) { tiedX++; }
      else if (Math.abs(dy) < 1e-15) { tiedY++; }
      else if (dx * dy > 0) { concordant++; }
      else { discordant++; }
    }
  }
  const n0 = n * (n - 1) / 2;
  const den = Math.sqrt((n0 - tiedX) * (n0 - tiedY));
  return den < 1e-15 ? 0 : (concordant - discordant) / den;
}

function mutualInfo(pts) {
  const n = pts.length;
  const k = 3;
  if (n < k + 1) return null;

  function digamma(x) {
    if (x < 1e-6) return -0.5772156649 - 1 / x;
    let result = 0;
    while (x < 6) { result -= 1 / x; x += 1; }
    result += Math.log(x) - 1 / (2 * x);
    const x2 = 1 / (x * x);
    result -= x2 * (1/12 - x2 * (1/120 - x2 / 252));
    return result;
  }

  const eps = new Array(n);
  const nx = new Array(n);
  const ny = new Array(n);

  for (let i = 0; i < n; i++) {
    const dists = [];
    for (let j = 0; j < n; j++) {
      if (j === i) continue;
      dists.push(Math.max(Math.abs(pts[i].x - pts[j].x), Math.abs(pts[i].y - pts[j].y)));
    }
    dists.sort((a, b) => a - b);
    eps[i] = dists[k - 1];

    let cx = 0, cy = 0;
    for (let j = 0; j < n; j++) {
      if (j === i) continue;
      if (Math.abs(pts[i].x - pts[j].x) < eps[i]) cx++;
      if (Math.abs(pts[i].y - pts[j].y) < eps[i]) cy++;
    }
    nx[i] = cx;
    ny[i] = cy;
  }

  let sumDg = 0;
  for (let i = 0; i < n; i++) {
    sumDg += digamma(nx[i] + 1) + digamma(ny[i] + 1);
  }
  return Math.max(0, digamma(k) - sumDg / n + digamma(n));
}

function distanceCorrelation(pts) {
  const n = pts.length;
  if (n < MIN_N_DCOR) return null;

  const ax = Array.from({ length: n }, (_, i) =>
    Array.from({ length: n }, (_, j) => Math.abs(pts[i].x - pts[j].x))
  );
  const ay = Array.from({ length: n }, (_, i) =>
    Array.from({ length: n }, (_, j) => Math.abs(pts[i].y - pts[j].y))
  );

  function doubleCenter(a) {
    const rowMean = a.map(row => row.reduce((s, v) => s + v, 0) / n);
    const colMean = new Array(n);
    for (let j = 0; j < n; j++) {
      let s = 0; for (let i = 0; i < n; i++) s += a[i][j]; colMean[j] = s / n;
    }
    let grandMean = 0;
    for (let i = 0; i < n; i++) grandMean += rowMean[i];
    grandMean /= n;

    const A = Array.from({ length: n }, () => new Array(n));
    for (let i = 0; i < n; i++)
      for (let j = 0; j < n; j++)
        A[i][j] = a[i][j] - rowMean[i] - colMean[j] + grandMean;
    return A;
  }

  const Ax = doubleCenter(ax), Ay = doubleCenter(ay);
  let dCovXY = 0, dVarX = 0, dVarY = 0;
  for (let i = 0; i < n; i++)
    for (let j = 0; j < n; j++) {
      dCovXY += Ax[i][j] * Ay[i][j];
      dVarX += Ax[i][j] * Ax[i][j];
      dVarY += Ay[i][j] * Ay[i][j];
    }
  dCovXY /= (n * n); dVarX /= (n * n); dVarY /= (n * n);
  const den = Math.sqrt(dVarX * dVarY);
  return den < 1e-15 ? 0 : Math.sqrt(dCovXY / den);
}

// ══════════════════════════════════
// UPDATE DISPLAY
// ══════════════════════════════════
function update() {
  render();
  computeAndDisplay();
}

function computeAndDisplay() {
  const n = points.length;
  document.getElementById('nValue').textContent = n;

  const measures = [
    { id: 'pearson', fn: pearson, signed: true },
    { id: 'spearman', fn: spearman, signed: true },
    { id: 'kendall', fn: kendall, signed: true },
    { id: 'mi', fn: mutualInfo, signed: false },
    { id: 'dcor', fn: distanceCorrelation, signed: false },
  ];

  let miMax = 1;

  for (const m of measures) {
    const val = m.fn(points);
    const valEl = document.getElementById('val-' + m.id);
    const barEl = document.getElementById('bar-' + m.id);
    const cardEl = document.getElementById('card-' + m.id);

    if (val === null) {
      valEl.textContent = '—';
      valEl.className = 'ce-stat-value na';
      barEl.style.width = '0%';
      barEl.style.background = '#e0e0ec';
      cardEl.classList.remove('active');
      continue;
    }

    cardEl.classList.add('active');
    valEl.textContent = val.toFixed(4);
    valEl.className = 'ce-stat-value';

    if (m.signed) {
      valEl.style.color = val > 0.05 ? '#0d8a74' : val < -0.05 ? '#c2640a' : '#888899';
    } else {
      valEl.style.color = '#0d8a74';
    }

    let barPct;
    if (m.signed) {
      barPct = Math.abs(val) * 100;
    } else if (m.id === 'mi') {
      miMax = Math.max(miMax, val * 1.2, 1);
      barPct = (val / miMax) * 100;
    } else {
      barPct = val * 100;
    }
    barEl.style.width = Math.min(100, barPct) + '%';
    barEl.style.background = (m.signed && val < 0) ? '#c2640a' : '#0d8a74';
  }
}

// ══════════════════════════════════
// PRESETS
// ══════════════════════════════════
function getPresetN() {
  return parseInt(document.getElementById('s_n').value);
}

function getStrength() {
  return parseFloat(document.getElementById('s_str').value);
}

function randn() {
  let u, v, s;
  do { u = Math.random()*2-1; v = Math.random()*2-1; s = u*u+v*v; } while (s >= 1 || s === 0);
  return u * Math.sqrt(-2 * Math.log(s) / s);
}

function loadPreset(name) {
  points = [];
  const N = getPresetN();
  const str = getStrength();
  const absStr = Math.abs(str);

  switch (name) {
    case 'linear': {
      const raw = [];
      for (let i = 0; i < N; i++) {
        const xz = randn();
        const noiseFactor = Math.sqrt(Math.max(0, 1 - str * str));
        const yz = str * xz + noiseFactor * randn();
        raw.push({ x: xz, y: yz });
      }
      rescaleToUnit(raw);
      points = raw;
      break;
    }
    case 'quadratic': {
      const noise = (1 - absStr) * 0.45;
      for (let i = 0; i < N; i++) {
        const x = Math.random();
        points.push({ x, y: clamp(0.1 + 3.2 * (x - 0.5) ** 2 + randn() * noise) });
      }
      break;
    }
    case 'heteroscedastic': {
      const raw = [];
      for (let i = 0; i < N; i++) {
        const xz = randn();
        const noiseFactor = Math.sqrt(Math.max(0, 1 - str * str));
        const yz = str * xz + noiseFactor * Math.abs(xz) * randn();
        raw.push({ x: xz, y: yz });
      }
      rescaleToUnit(raw);
      points = raw;
      break;
    }
    case 'circle': {
      const spread = (1 - absStr) * 0.35;
      for (let i = 0; i < N; i++) {
        const a = Math.random() * Math.PI * 2;
        const r = 0.35 + randn() * Math.max(0.005, spread);
        points.push({ x: clamp(0.5 + r * Math.cos(a)), y: clamp(0.5 + r * Math.sin(a)) });
      }
      break;
    }
    case 'x-shape': {
      const noise = (1 - absStr) * 0.35;
      for (let i = 0; i < N; i++) {
        const x = Math.random();
        const base = Math.random() < 0.5 ? x : 1 - x;
        points.push({ x: clamp(x), y: clamp(base + randn() * noise) });
      }
      break;
    }
    case 'sine': {
      const noise = (1 - absStr) * 0.3;
      for (let i = 0; i < N; i++) {
        const x = Math.random();
        points.push({ x, y: clamp(0.5 + 0.35 * Math.sin(x * Math.PI * 3) + randn() * noise) });
      }
      break;
    }
    case 'random':
      for (let i = 0; i < N; i++)
        points.push({ x: Math.random(), y: Math.random() });
      break;
  }
  update();
}

function rescaleToUnit(pts) {
  if (pts.length < 2) return;
  let xmin = Infinity, xmax = -Infinity, ymin = Infinity, ymax = -Infinity;
  for (const p of pts) {
    if (p.x < xmin) xmin = p.x; if (p.x > xmax) xmax = p.x;
    if (p.y < ymin) ymin = p.y; if (p.y > ymax) ymax = p.y;
  }
  const xr = xmax - xmin || 1;
  const yr = ymax - ymin || 1;
  for (const p of pts) {
    p.x = 0.05 + 0.9 * (p.x - xmin) / xr;
    p.y = 0.05 + 0.9 * (p.y - ymin) / yr;
  }
}

function clamp(v) { return Math.max(0, Math.min(1, v)); }
function clearPoints() { points = []; update(); }

// ══════════════════════════════════
// INIT
// ══════════════════════════════════
window.addEventListener('resize', render);
render();
computeAndDisplay();
</script>
