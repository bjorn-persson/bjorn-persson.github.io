---
title: "Multicollinearity in Multiple Regression"
description: "Interactive visualization showing how increasing the correlation between two predictors collapses the data cloud, inflates standard errors, and destabilizes regression coefficients. A 2D projection illustrates the geometric intuition."
summary: "Watch how a rising inter-predictor correlation (r → 1) collapses the data cloud onto a line, makes the regression plane wobble, and inflates VIF and standard errors — the geometric intuition for multicollinearity."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Source+Serif+4:opsz,wght@8..60,400;8..60,600&display=swap');

.mc-wrap { font-family: 'IBM Plex Mono', monospace; }
.mc-subtitle {
  font-size: 0.78rem;
  color: var(--secondary);
  margin-bottom: 18px;
  line-height: 1.6;
}
.mc-layout {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  align-items: start;
}
.mc-canvas-wrap canvas {
  display: block;
  width: 100%;
  aspect-ratio: 1;
  border-radius: 6px;
  background: #f4f4f8;
}
.mc-canvas-label {
  font-size: 0.7rem;
  color: var(--secondary);
  text-transform: uppercase;
  letter-spacing: 0.07em;
  margin-bottom: 6px;
}
.mc-controls {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.mc-control-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 0.72rem;
}
.mc-control-group label { color: var(--secondary); }
.mc-val { color: #0d8a74; font-weight: 600; }
.mc-controls input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: #e0e0ec;
  border-radius: 2px;
  outline: none;
  cursor: pointer;
}
.mc-controls input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
}
.mc-controls input[type="range"]::-moz-range-thumb {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
  border: none;
}
.mc-stats {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  margin-top: 4px;
}
.mc-stat-card {
  background: #f4f4f8;
  border-radius: 5px;
  padding: 8px 10px;
  border-left: 3px solid #e0e0ec;
  transition: border-color 0.3s;
}
.mc-stat-card.warn { border-left-color: #c83c5a; }
.mc-stat-label {
  font-size: 0.64rem;
  color: var(--secondary);
  margin-bottom: 2px;
}
.mc-stat-value {
  font-size: 1.1rem;
  font-weight: 600;
  color: #0d8a74;
  transition: color 0.3s;
}
.mc-stat-value.warn { color: #c83c5a; }
.mc-wobble-label {
  font-size: 0.72rem;
  color: var(--secondary);
  margin-top: 8px;
  min-height: 1.4em;
}
.mc-wobble-label span { color: #c83c5a; font-weight: 600; }
.mc-note {
  margin-top: 14px;
  font-size: 0.68rem;
  color: var(--secondary);
  line-height: 1.6;
  grid-column: 1 / -1;
}
@media (max-width: 580px) {
  .mc-layout { grid-template-columns: 1fr; }
  .mc-note { grid-column: 1; }
}
</style>

<div class="mc-wrap">
  <p class="mc-subtitle">
    Multicollinearity arises when two predictors (X₁, X₂) are highly correlated. Geometrically, the data cloud collapses onto a line — the regression plane loses its support and can "wobble" wildly while still fitting Y well. This inflates standard errors and makes coefficients unreliable.
  </p>
  <div class="mc-layout">
    <div>
      <div class="mc-canvas-label">X₁–X₂ Predictor Space (projection)</div>
      <div class="mc-canvas-wrap"><canvas id="mc_scatter"></canvas></div>
    </div>
    <div>
      <div class="mc-canvas-label">Regression Plane Cross-section (Y on X₁)</div>
      <div class="mc-canvas-wrap"><canvas id="mc_plane"></canvas></div>
    </div>
    <div class="mc-controls" style="grid-column:1/-1">
      <div class="mc-control-group">
        <label>Correlation between X₁ and X₂ (r): <span class="mc-val" id="mc_r_val">0.00</span></label>
        <input type="range" id="mc_r" min="0" max="0.999" step="0.001" value="0">
      </div>
      <div class="mc-control-group">
        <label>True β₁ (effect of X₁): <span class="mc-val" id="mc_b1_val">0.60</span></label>
        <input type="range" id="mc_b1" min="-1" max="1" step="0.01" value="0.60">
      </div>
      <div class="mc-control-group">
        <label>True β₂ (effect of X₂): <span class="mc-val" id="mc_b2_val">0.40</span></label>
        <input type="range" id="mc_b2" min="-1" max="1" step="0.01" value="0.40">
      </div>
    </div>
    <div class="mc-stats" style="grid-column:1/-1">
      <div class="mc-stat-card" id="mc_vif_card">
        <div class="mc-stat-label">VIF</div>
        <div class="mc-stat-value" id="mc_vif">1.00</div>
      </div>
      <div class="mc-stat-card" id="mc_se_card">
        <div class="mc-stat-label">SE inflation factor</div>
        <div class="mc-stat-value" id="mc_se_inf">1.00×</div>
      </div>
      <div class="mc-stat-card" id="mc_b1est_card">
        <div class="mc-stat-label">β̂₁ OLS 95% CI</div>
        <div class="mc-stat-value" id="mc_b1est">—</div>
      </div>
      <div class="mc-stat-card" id="mc_b2est_card">
        <div class="mc-stat-label">β̂₂ OLS 95% CI</div>
        <div class="mc-stat-value" id="mc_b2est">—</div>
      </div>
    </div>
    <div class="mc-wobble-label" id="mc_wobble_text" style="grid-column:1/-1">
      The regression plane is well-supported. Coefficient estimates are stable.
    </div>
    <p class="mc-note">
      VIF (Variance Inflation Factor) = 1/(1−r²). At r = 0.9, VIF = 5.3; at r = 0.99, VIF = 50.
      The SE of each coefficient is inflated by √VIF. Rules of thumb: VIF > 5 is concerning, VIF > 10 is severe.<br>
      Note: multicollinearity does <em>not</em> bias the regression coefficients — it only inflates their uncertainty.
      The model still predicts Y well; it just cannot tell X₁ and X₂ apart.
    </p>
  </div>
</div>

<script>
(function () {
  let dpr = window.devicePixelRatio || 1;
  const scatterCanvas = document.getElementById('mc_scatter');
  const planeCanvas = document.getElementById('mc_plane');
  const sCtx = scatterCanvas.getContext('2d');
  const pCtx = planeCanvas.getContext('2d');

  const N = 60;
  const SEED = 17;

  function makeRng(seed) {
    let s = seed >>> 0;
    return () => {
      s += 0x6D2B79F5;
      let t = s;
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

  // Base independent normals
  const rng0 = makeRng(SEED);
  const baseX1 = Array.from({ length: N }, () => randn(rng0));
  const baseX2 = Array.from({ length: N }, () => randn(rng0));
  const baseNoise = Array.from({ length: N }, () => randn(rng0));

  function getPoints(r, b1, b2) {
    const pts = [];
    for (let i = 0; i < N; i++) {
      const x1 = baseX1[i];
      const x2 = r * baseX1[i] + Math.sqrt(Math.max(0, 1 - r*r)) * baseX2[i];
      const y = b1*x1 + b2*x2 + 0.3 * baseNoise[i];
      pts.push({ x1, x2, y });
    }
    return pts;
  }

  // Rescale to [pad, 1-pad]
  function normalize(arr) {
    const mn = Math.min(...arr), mx = Math.max(...arr);
    const range = mx - mn || 1;
    return arr.map(v => (v - mn) / range);
  }

  const PAD = 36;

  function drawScatter(pts, r) {
    const W = scatterCanvas.width / dpr;
    const H = scatterCanvas.height / dpr;
    sCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    sCtx.clearRect(0, 0, W, H);

    const pw = W - PAD * 2, ph = H - PAD * 2;

    // Normalize
    const x1n = normalize(pts.map(p => p.x1));
    const x2n = normalize(pts.map(p => p.x2));

    function sx(v) { return PAD + v * pw; }
    function sy(v) { return PAD + (1 - v) * ph; }

    // Grid
    sCtx.strokeStyle = '#e4e4f0'; sCtx.lineWidth = 0.5;
    for (let i = 0; i <= 4; i++) {
      const v = i / 4;
      sCtx.beginPath(); sCtx.moveTo(sx(v), PAD); sCtx.lineTo(sx(v), PAD + ph); sCtx.stroke();
      sCtx.beginPath(); sCtx.moveTo(PAD, sy(v)); sCtx.lineTo(PAD + pw, sy(v)); sCtx.stroke();
    }

    // Axes
    sCtx.strokeStyle = '#c0c0d8'; sCtx.lineWidth = 1;
    sCtx.beginPath(); sCtx.moveTo(PAD, PAD + ph); sCtx.lineTo(PAD + pw, PAD + ph); sCtx.stroke();
    sCtx.beginPath(); sCtx.moveTo(PAD, PAD); sCtx.lineTo(PAD, PAD + ph); sCtx.stroke();

    // Color points by Y value
    const yn = normalize(pts.map(p => p.y));
    for (let i = 0; i < pts.length; i++) {
      const px = sx(x1n[i]), py = sy(x2n[i]);
      // color: purple (low Y) → teal (high Y)
      const yv = yn[i];
      const r_c = Math.round(13 + (109-13)*yv);
      const g_c = Math.round(138 + (40-138)*yv);
      const b_c = Math.round(116 + (217-116)*yv);
      sCtx.beginPath();
      sCtx.arc(px, py, 4, 0, Math.PI * 2);
      sCtx.fillStyle = `rgba(${r_c},${g_c},${b_c},0.75)`;
      sCtx.fill();
    }

    // Correlation annotation
    const rColor = r > 0.9 ? '#c83c5a' : r > 0.7 ? '#c2640a' : '#888899';
    sCtx.font = 'bold 13px IBM Plex Mono, monospace';
    sCtx.fillStyle = rColor;
    sCtx.textAlign = 'center';
    sCtx.fillText(`r(X₁,X₂) = ${r.toFixed(3)}`, W/2, PAD - 8);

    // Axis labels
    sCtx.font = '11px IBM Plex Mono, monospace';
    sCtx.fillStyle = '#888899';
    sCtx.textAlign = 'center';
    sCtx.fillText('X₁', W/2, PAD + ph + 24);
    sCtx.save();
    sCtx.translate(12, PAD + ph/2);
    sCtx.rotate(-Math.PI/2);
    sCtx.fillText('X₂', 0, 0);
    sCtx.restore();

    // Color legend
    sCtx.font = '9px IBM Plex Mono, monospace';
    sCtx.textAlign = 'left';
    sCtx.fillStyle = 'rgba(13,138,116,0.8)';
    sCtx.fillText('high Y', PAD + pw - 36, PAD + ph - 6);
    sCtx.fillStyle = 'rgba(109,40,217,0.8)';
    sCtx.fillText('low Y', PAD, PAD + ph - 6);
  }

  function drawPlane(pts, r, b1, b2) {
    const W = planeCanvas.width / dpr;
    const H = planeCanvas.height / dpr;
    pCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    pCtx.clearRect(0, 0, W, H);

    const PAD_L = 44, PAD_R = 14, PAD_T = 26, PAD_B = 32;
    const pw = W - PAD_L - PAD_R, ph = H - PAD_T - PAD_B;

    const x1n = normalize(pts.map(p => p.x1));
    const yn = normalize(pts.map(p => p.y));

    function sx(v) { return PAD_L + v * pw; }
    function sy_fn(v) { return PAD_T + (1 - v) * ph; }

    // Grid
    pCtx.strokeStyle = '#e4e4f0'; pCtx.lineWidth = 0.5;
    for (let i = 0; i <= 4; i++) {
      const v = i/4;
      pCtx.beginPath(); pCtx.moveTo(sx(v), PAD_T); pCtx.lineTo(sx(v), PAD_T+ph); pCtx.stroke();
      pCtx.beginPath(); pCtx.moveTo(PAD_L, sy_fn(v)); pCtx.lineTo(PAD_L+pw, sy_fn(v)); pCtx.stroke();
    }

    // Axes
    pCtx.strokeStyle = '#c0c0d8'; pCtx.lineWidth = 1;
    pCtx.beginPath(); pCtx.moveTo(PAD_L, PAD_T+ph); pCtx.lineTo(PAD_L+pw, PAD_T+ph); pCtx.stroke();
    pCtx.beginPath(); pCtx.moveTo(PAD_L, PAD_T); pCtx.lineTo(PAD_L, PAD_T+ph); pCtx.stroke();

    // Points
    for (let i = 0; i < pts.length; i++) {
      pCtx.beginPath();
      pCtx.arc(sx(x1n[i]), sy_fn(yn[i]), 3.5, 0, Math.PI*2);
      pCtx.fillStyle = 'rgba(109,40,217,0.55)';
      pCtx.fill();
    }

    // OLS line (Y on X1, simple)
    let sx1 = 0, sy1 = 0, sxx1 = 0, sxy1 = 0;
    for (let i = 0; i < pts.length; i++) {
      sx1 += x1n[i]; sy1 += yn[i];
      sxx1 += x1n[i]*x1n[i]; sxy1 += x1n[i]*yn[i];
    }
    const n = pts.length;
    const mx1 = sx1/n, my1 = sy1/n;
    const slope = (sxy1 - n*mx1*my1) / (sxx1 - n*mx1*mx1 + 1e-12);
    const intercept = my1 - slope*mx1;

    pCtx.beginPath();
    pCtx.moveTo(sx(0), sy_fn(intercept));
    pCtx.lineTo(sx(1), sy_fn(intercept + slope));
    pCtx.strokeStyle = '#0d8a74';
    pCtx.lineWidth = 2.5;
    pCtx.stroke();

    // Wobble lines: show alternative fits when r is high
    const vif = 1 / Math.max(1e-6, 1 - r*r);
    const seInflation = Math.sqrt(vif);
    const wobble = Math.min(2, seInflation - 1) * 0.35;

    if (wobble > 0.02) {
      for (const delta of [-wobble, wobble]) {
        pCtx.beginPath();
        pCtx.moveTo(sx(0), sy_fn(intercept + delta * 0));
        pCtx.lineTo(sx(1), sy_fn(intercept + slope + delta));
        pCtx.strokeStyle = 'rgba(200,60,90,0.45)';
        pCtx.lineWidth = 1.5;
        pCtx.setLineDash([5, 4]);
        pCtx.stroke();
        pCtx.setLineDash([]);
      }
    }

    // SE band
    if (wobble > 0.01) {
      pCtx.beginPath();
      pCtx.moveTo(sx(0), sy_fn(intercept + wobble));
      for (let xi = 0; xi <= 100; xi++) {
        const xv = xi/100;
        pCtx.lineTo(sx(xv), sy_fn(intercept + slope * xv + wobble));
      }
      for (let xi = 100; xi >= 0; xi--) {
        const xv = xi/100;
        pCtx.lineTo(sx(xv), sy_fn(intercept + slope * xv - wobble));
      }
      pCtx.closePath();
      pCtx.fillStyle = 'rgba(200,60,90,0.08)';
      pCtx.fill();
    }

    // Axis labels
    pCtx.fillStyle = '#888899';
    pCtx.font = '11px IBM Plex Mono, monospace';
    pCtx.textAlign = 'center';
    pCtx.fillText('X₁', PAD_L + pw/2, PAD_T + ph + 24);
    pCtx.save();
    pCtx.translate(13, PAD_T + ph/2);
    pCtx.rotate(-Math.PI/2);
    pCtx.fillText('Y', 0, 0);
    pCtx.restore();

    // VIF annotation
    const vifColor = vif > 10 ? '#c83c5a' : vif > 5 ? '#c2640a' : '#888899';
    pCtx.font = 'bold 11px IBM Plex Mono, monospace';
    pCtx.fillStyle = vifColor;
    pCtx.textAlign = 'center';
    pCtx.fillText(`VIF = ${vif.toFixed(1)}`, PAD_L + pw/2, PAD_T - 8);

    // Update stat cards
    const seInfStr = seInflation.toFixed(2) + '×';

    // Compute actual OLS SE for β̂₁ and β̂₂ from the two-predictor model
    // SE(β̂₁) = σ̂ / sqrt(SSX1 · (1 − r₁₂²))  where r₁₂ is the sample correlation
    const x1bar = pts.reduce((s, p) => s + p.x1, 0) / n;
    const x2bar = pts.reduce((s, p) => s + p.x2, 0) / n;
    const ybar  = pts.reduce((s, p) => s + p.y,  0) / n;
    let SSX1 = 0, SSX2 = 0, SX1X2 = 0, SX1Y = 0, SX2Y = 0;
    for (const p of pts) {
      const d1 = p.x1 - x1bar, d2 = p.x2 - x2bar, dy = p.y - ybar;
      SSX1 += d1*d1; SSX2 += d2*d2; SX1X2 += d1*d2; SX1Y += d1*dy; SX2Y += d2*dy;
    }
    const denom = SSX1*SSX2 - SX1X2*SX1X2;
    let se1 = NaN, se2 = NaN;
    if (Math.abs(denom) > 1e-10) {
      const b1hat = (SX1Y*SSX2 - SX2Y*SX1X2) / denom;
      const b2hat = (SX2Y*SSX1 - SX1Y*SX1X2) / denom;
      const b0hat = ybar - b1hat*x1bar - b2hat*x2bar;
      let rss = 0;
      for (const p of pts) rss += (p.y - (b0hat + b1hat*p.x1 + b2hat*p.x2))**2;
      const sigma2 = rss / (n - 3);
      se1 = Math.sqrt(sigma2 * SSX2 / denom);
      se2 = Math.sqrt(sigma2 * SSX1 / denom);
    }
    const se1str = isNaN(se1) ? '—' : `[${(b1 - 2*se1).toFixed(2)}, ${(b1 + 2*se1).toFixed(2)}]`;
    const se2str = isNaN(se2) ? '—' : `[${(b2 - 2*se2).toFixed(2)}, ${(b2 + 2*se2).toFixed(2)}]`;

    document.getElementById('mc_vif').textContent = vif.toFixed(2);
    document.getElementById('mc_se_inf').textContent = seInfStr;
    document.getElementById('mc_b1est').textContent = se1str;
    document.getElementById('mc_b2est').textContent = se2str;

    const warn = vif > 5;
    for (const id of ['mc_vif_card', 'mc_se_card', 'mc_b1est_card', 'mc_b2est_card']) {
      document.getElementById(id).classList.toggle('warn', warn);
    }
    for (const id of ['mc_vif', 'mc_se_inf', 'mc_b1est', 'mc_b2est']) {
      document.getElementById(id).classList.toggle('warn', warn);
    }

    const wEl = document.getElementById('mc_wobble_text');
    if (r > 0.95) {
      wEl.innerHTML = `<span>Severe multicollinearity:</span> data collapsed to near-1D. The regression plane has almost no support — β estimates are wildly unstable (SE inflation = ${seInflation.toFixed(1)}×).`;
    } else if (r > 0.8) {
      wEl.innerHTML = `<span>Problematic multicollinearity:</span> the predictor cloud is a narrow ellipse. Coefficient CIs are wide and overlap zero even if the true effects are substantial.`;
    } else if (r > 0.5) {
      wEl.textContent = `Moderate collinearity (r = ${r.toFixed(2)}). Some SE inflation but coefficients are still interpretable.`;
    } else {
      wEl.textContent = `Low collinearity. The regression plane is well-supported. Coefficient estimates are stable.`;
    }
  }

  function update() {
    const r  = parseFloat(document.getElementById('mc_r').value);
    const b1 = parseFloat(document.getElementById('mc_b1').value);
    const b2 = parseFloat(document.getElementById('mc_b2').value);
    document.getElementById('mc_r_val').textContent = r.toFixed(3);
    document.getElementById('mc_b1_val').textContent = b1.toFixed(2);
    document.getElementById('mc_b2_val').textContent = b2.toFixed(2);
    const pts = getPoints(r, b1, b2);
    drawScatter(pts, r);
    drawPlane(pts, r, b1, b2);
  }

  for (const id of ['mc_r','mc_b1','mc_b2']) {
    document.getElementById(id).addEventListener('input', update);
  }

  function resize() {
    dpr = window.devicePixelRatio || 1;
    for (const c of [scatterCanvas, planeCanvas]) {
      const rect = c.getBoundingClientRect();
      c.width = rect.width * dpr;
      c.height = rect.height * dpr;
    }
    update();
  }

  window.addEventListener('resize', resize);
  // Defer initial draw until the browser has completed layout so
  // getBoundingClientRect returns non-zero dimensions for the canvases.
  requestAnimationFrame(() => requestAnimationFrame(resize));
})();
</script>
