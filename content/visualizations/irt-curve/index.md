---
title: "IRT Curve (3PL Model)"
description: "Interactive visualization of the three-parameter logistic IRT model. Adjust discrimination, difficulty, and guessing parameters to see how they shape the item characteristic curve."
summary: "Explore how discrimination (a), difficulty (b), and pseudo-guessing (c) parameters shape the item characteristic curve in the 3PL IRT model."
---

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&display=swap');

.viz-embed .irt-subtitle {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.78rem;
  color: var(--secondary);
  margin-bottom: 16px;
  line-height: 1.5;
}

.viz-embed .irt-chart-container {
  position: relative;
  height: max(280px, calc(100vh - 520px));
  width: 100%;
  margin-bottom: 20px;
  background: #f4f4f8;
  border-radius: 6px;
  overflow: hidden;
}

.viz-embed .irt-controls {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.viz-embed .irt-control-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-family: 'IBM Plex Mono', monospace;
}

.viz-embed .irt-control-label {
  display: flex;
  justify-content: space-between;
  font-size: 0.76rem;
  color: var(--secondary);
}

.viz-embed .irt-value-display {
  font-weight: 600;
  color: #0d8a74;
}

.viz-embed .irt-controls input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: #e0e0ec;
  border-radius: 2px;
  outline: none;
  cursor: pointer;
}

.viz-embed .irt-controls input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
}

.viz-embed .irt-controls input[type="range"]::-moz-range-thumb {
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #0d8a74;
  cursor: pointer;
  border: none;
}
</style>

<div class="viz-embed">
<div class="container">

<p class="irt-subtitle">Adjust the parameters below to see how they influence the probability of endorsing an item across different levels of a latent trait (θ).</p>

<div class="irt-chart-container">
  <canvas id="irtChart"></canvas>
</div>

<div class="irt-controls">
  <div class="irt-control-group">
    <div class="irt-control-label">
      <span>Discrimination (a): How well the item differentiates individuals.</span>
      <span class="irt-value-display" id="aVal">1.00</span>
    </div>
    <input type="range" id="aSlider" min="0.1" max="3.0" step="0.1" value="1.0">
  </div>
  <div class="irt-control-group">
    <div class="irt-control-label">
      <span>Difficulty (b): The trait level where probability of endorsement is midway.</span>
      <span class="irt-value-display" id="bVal">0.00</span>
    </div>
    <input type="range" id="bSlider" min="-3.0" max="3.0" step="0.1" value="0.0">
  </div>
  <div class="irt-control-group">
    <div class="irt-control-label">
      <span>Guessing/Pseudo-guessing (c): The lower asymptote.</span>
      <span class="irt-value-display" id="cVal">0.00</span>
    </div>
    <input type="range" id="cSlider" min="0.0" max="0.5" step="0.01" value="0.0">
  </div>
</div>

</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    function calculateProbability(theta, a, b, c) {
        const exponent = -a * (theta - b);
        return c + ((1 - c) / (1 + Math.exp(exponent)));
    }

    function generateData(a, b, c) {
        const data = [];
        for (let theta = -4; theta <= 4; theta += 0.1) {
            data.push({
                x: parseFloat(theta.toFixed(1)),
                y: calculateProbability(theta, a, b, c)
            });
        }
        return data;
    }

    const irtCtx = document.getElementById('irtChart').getContext('2d');
    const irtChart = new Chart(irtCtx, {
        type: 'line',
        data: {
            datasets: [{
                label: 'Probability of Endorsement / Correct Response',
                data: generateData(1.0, 0.0, 0.0),
                borderColor: '#0d8a74',
                backgroundColor: 'rgba(13, 138, 116, 0.08)',
                borderWidth: 2.5,
                fill: true,
                pointRadius: 0,
                pointHitRadius: 10
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    type: 'linear',
                    title: {
                        display: true,
                        text: 'Latent Trait Level (θ)',
                        font: { size: 12, family: 'IBM Plex Mono, monospace' },
                        color: '#888899'
                    },
                    min: -4,
                    max: 4,
                    ticks: {
                        stepSize: 1,
                        font: { size: 11, family: 'IBM Plex Mono, monospace' },
                        color: '#888899'
                    },
                    grid: { color: '#e4e4f0' },
                    border: { color: '#c0c0d8' }
                },
                y: {
                    title: {
                        display: true,
                        text: 'Probability P(θ)',
                        font: { size: 12, family: 'IBM Plex Mono, monospace' },
                        color: '#888899'
                    },
                    min: 0,
                    max: 1,
                    ticks: {
                        stepSize: 0.2,
                        font: { size: 11, family: 'IBM Plex Mono, monospace' },
                        color: '#888899'
                    },
                    grid: { color: '#e4e4f0' },
                    border: { color: '#c0c0d8' }
                }
            },
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: (context) => `Probability: ${context.parsed.y.toFixed(2)}`
                    }
                }
            }
        }
    });

    const sliders = ['a', 'b', 'c'];
    sliders.forEach(param => {
        const slider = document.getElementById(`${param}Slider`);
        const display = document.getElementById(`${param}Val`);
        slider.addEventListener('input', (e) => {
            display.textContent = parseFloat(e.target.value).toFixed(2);
            const a = parseFloat(document.getElementById('aSlider').value);
            const b = parseFloat(document.getElementById('bSlider').value);
            const c = parseFloat(document.getElementById('cSlider').value);
            irtChart.data.datasets[0].data = generateData(a, b, c);
            irtChart.update('none');
        });
    });
</script>
