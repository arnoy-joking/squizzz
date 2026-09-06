# DU Admission — MCQ Practice (PWA)

A timed MCQ rehearsal room for Dhaka University admission. Single-page app, zero backend,
fully offline-capable Progressive Web App.

## What's in the box

| File | Purpose |
|---|---|
| `index.html` | The entire app (setup → quiz → results → history) |
| `sw.js` | Service worker — precaches the whole app shell for offline use |
| `manifest.webmanifest` | PWA manifest (installable, standalone, themed) |
| `icons/` | App icons (192/512/maskable/apple-touch + SVG favicon) |
| `vendor/` | **Local** copies of Tailwind, KaTeX (+fonts), jsPDF, html2canvas — no CDN needed at runtime |

## Features

- **Timed practice modes** — Average 45s/q, Fast 30s/q, Lightspeed 15s/q, or custom.
- **OMR exam rules (the trap)**
  - Every tap on an option is a **permanent mark** — no deselecting, no "Clear selection",
    a question is effectively answered only once.
  - You *can* tap additional options; marks stack. **Any question with 2+ marks is scored
    incorrect** — exactly like over-filling an OMR bubble sheet.
  - The trap is **silent**: during the quiz nothing warns you; you discover the damage in the results.
- **Scoring** — +1 per correct, −0.25 per incorrect (multi-mark counts as incorrect), skipped = 0.
- **Results with answers** — every question reviewed with correct/incorrect highlighting and
  a "⚠ N options marked — scored as incorrect" note; filters: All / Correct / Incorrect / Skipped.
- **Result archive in IndexedDB** — every submitted test is saved automatically (full question +
  mark snapshot). The *Past results* screen lists them; each entry can be **viewed** (full review
  with the same filters), exported to **PDF**, or **deleted**; "Delete all" wipes the archive.
  Nothing ever leaves the browser.
- **PDF export** — a clean, print-friendly A4 report (score header + every question with marks and
  the correct answer, KaTeX math included) generated 100% locally with jsPDF + html2canvas.
  Available from the results screen and from every history card.
- **PWA / offline** — installable; after the first online visit the service worker caches the app
  shell, all vendor libraries and KaTeX fonts, so the app (quizzes, saving to IndexedDB, PDF
  export included) works with no network at all. Google webfonts are cached on first use and
  degrade to system fonts otherwise.
- **Shareable links** — question sets travel compressed inside the URL hash (`#quiz=…`), unchanged.
- **KaTeX + mhchem** — inline `$…$` / `$$…$$` math and `\ce{…}` chemistry in questions and options.

## Run / deploy

Any static host works (the app uses only relative paths):

```bash
# local
python3 -m http.server 8000        # then open http://localhost:8000

# or deploy the folder as-is to Vercel / Netlify / GitHub Pages / any nginx box
```

For install prompts and service workers the origin must be HTTPS (or `localhost`).

## Notes for maintainers

- Bump `CACHE_VERSION` in `sw.js` whenever you change any cached file so returning visitors
  pick up the new shell.
- Question JSON format: `[{"q":"…","options":["…","…"],"answer":0}, …]` (`answer` = 0-based index).
- IndexedDB: database `du-mcq-db`, object store `results` (auto-increment `id`, index on `savedAt`).
- PDF pagination slices the rasterized report at question-card boundaries; a card taller than a
  page is raw-sliced.
