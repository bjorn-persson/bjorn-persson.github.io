# CLAUDE.md — Project Instructions for Claude Code

## Project Overview

Personal academic website for **Björn N. Persson, PhD**, postdoctoral researcher at Karolinska Institutet. Built with Hugo + PaperMod theme, deployed to GitHub Pages at `https://bjorn-persson.github.io` (note: the old URL `bnpersson.github.io` redirects here).

## Quick Reference

| What | Where |
|---|---|
| Hugo config | `config.yml` |
| Papers | `content/papers/[slug]/index.md` |
| Paper PDFs | `static/papers/[slug].pdf` → served at `/papers/[slug].pdf` |
| Visualizations | `content/visualizations/[slug]/index.md` or `index.html` |
| CV | `static/bnp_cv.pdf` |
| Profile picture | `static/picture.jpeg` |
| Custom CSS | `assets/css/extended/*.css` |
| Layout overrides | `layouts/` (overrides PaperMod theme) |
| CI/CD | `.github/workflows/hugo.yml` (Hugo 0.147.2 extended) |

## Architecture

### Hugo + PaperMod
- Theme lives in `themes/PaperMod` (git submodule)
- Layout overrides in `layouts/` take precedence over theme
- Extended CSS in `assets/css/extended/` is automatically loaded by PaperMod's head partial
- Config is YAML (`config.yml`), not TOML

### Theme & Styling
- **Dark theme only** (`defaultTheme: dark`, toggle disabled)
- **Accent color:** teal `#2dd4bf` (links, hover states, active nav, buttons)
- **Fonts:** Source Serif 4 (body/content), IBM Plex Mono (nav, footer, code) — loaded via Google Fonts in `layouts/partials/head.html`
- **Background:** `#0f1117` (page), `#181a24` (cards/entries)
- **Text:** `#c9cdd8` (primary), `#6b7084` (secondary)
- Custom CSS files:
  - `dark-theme.css` — colors, fonts, accent styling
  - `paper-layout.css` — paper list entries with sidebar cover images
  - `viz-grid.css` — responsive visualization card grid

### Math
- KaTeX 0.16.10 enabled globally (`math: true` in config)
- Loaded via `layouts/partials/math.html`
- Supports `$...$` inline, `$$...$$` display, and LaTeX environments

### Navigation
- Only **Papers** and **Visualizations** in nav menu
- Hidden sections (books, courses, data) still exist at their URLs but are not linked
- Homepage uses profile mode with bio, photo, and two buttons

## Content Patterns

### Adding a New Paper
1. Create `content/papers/[slug]/index.md` with front matter:
```yaml
title: "Full Paper Title"
date: YYYY-MM-DD
tags: ["tag1", "tag2"]
author: ["First Author", "Second Author"]
description: "Short SEO description."
summary: "1-2 sentence findings summary."
editPost:
    URL: "https://doi.org/..."
    Text: "Journal Name"
cover:
    image: "cover.png"
    alt: "Paper preview"
    relative: true
```
2. Add content sections: `##### Download`, `##### Abstract`, `##### Citation` (APA + BibTeX)
3. Place PDF in `static/papers/[slug].pdf`
4. Optionally add `cover.png` in the paper's content directory

### Adding a New Visualization
- Can be either `index.md` (markdown with embedded HTML/JS) or `index.html` (full HTML)
- Visualizations are self-contained: CSS + JS embedded directly in the page
- The visualization grid (`content/visualizations/`) auto-displays all child pages as cards
- Cards show a cover image if available, otherwise a placeholder SVG icon
- Add `cover.png` or `cover.jpg` to the visualization directory for the grid thumbnail
- Follow the existing dark theme color scheme (teal accent `#2dd4bf`, dark backgrounds)
- The viz list layout uses `.viz-grid` CSS grid with responsive auto-fill columns

### Existing Visualizations (15 total)
CFA, correlation-explorer, correlation-stability, cronbachs-alpha, IRT curve, IRT precision, mediation-moderation, multicollinearity, normal-distribution, regression, regression-to-the-mean, reliability-validity, simpsons-paradox, aggregation-tradeoff

### Existing Papers (14 total)
See `content/papers/` — slugs follow `[topic]-[year]` convention

## Layout Customizations

Key layout overrides from PaperMod defaults:
- `layouts/_default/baseof.html` — adds `viz-page` class when section is "visualizations"
- `layouts/visualizations/single.html` — minimal wrapper (just article + title + content)
- `layouts/visualizations/list.html` — card grid with cover images
- `layouts/partials/head.html` — Google Fonts, extended CSS loading
- `layouts/partials/math.html` — KaTeX CDN with auto-render

## Build & Deploy

- **Local dev:** `hugo server` (requires Hugo extended 0.147.2+)
- **CI/CD:** Push to `main` triggers GitHub Actions → builds → deploys to GitHub Pages
- **Build output:** `public/` (gitignored)
- **Submodules:** Theme is a submodule, CI checks out with `submodules: true`

## Environment Notes

- **Platform:** Windows 11, bash shell in Claude Code
- **Python:** Use `export PATH="$HOME/.local/bin:$PATH" && uv run python` (no standalone python)
- **Temp files:** Use `C:/Users/perss/AppData/Local/Temp/` (no `/tmp`)
- **Hugo markup:** `unsafe: true` in goldmark renderer — raw HTML in markdown is allowed

## User Preferences

- Concise communication, no emojis
- Dark theme only (do not add light theme support)
- Keep hidden pages accessible by direct URL rather than deleting them
- Visualizations are pedagogical tools — accuracy matters but they are not production scientific software
- Cover images use 16:10 aspect ratio in the viz grid
