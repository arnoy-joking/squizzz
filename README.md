# DU Admission — MCQ Practice (PWA)

A timed MCQ rehearsal room for Dhaka University admission. Single-page app, zero backend,
fully offline-capable Progressive Web App.

## What's in the box

| File | Purpose |
|---|---|
| `index.html` | The entire app (setup → quiz → results → history) |
| `sw.js` | Service worker — precaches the whole app shell for offline use |
| `manifest.webmanifest` | PWA manifest (installable, standalone, themed) |
| `supabase-config.js` | **Optional** Supabase credentials for short share-links (empty = serverless) |
| `supabase/schema.sql` | One-shot SQL: `quiz_sets` table + Row-Level-Security policies |
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
  Pages break only at question-card boundaries and carry a vector footer ("Page X of Y" +
  timestamp) plus a running header from page 2. Available from the results screen and from
  every history card.
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

## Supabase short share-links (optional, 5-minute setup)

Compressed URL-hash links get enormous with big question sets. With Supabase enabled,
"Copy shareable link" instead stores the compressed blob once in a `quiz_sets` table and
copies a tiny link like `https://yoursite.app/#s=k7vq2mxa` (≈33 chars, any size set).

**Setup**

1. **Create a project** — [supabase.com](https://supabase.com) → New project (free tier is plenty).
2. **Create the table** — Dashboard → SQL Editor → paste & run [`supabase/schema.sql`](supabase/schema.sql).
   It creates `quiz_sets(id text pk, payload text, created_at)` plus RLS policies that allow
   the anon key to **only INSERT and SELECT** (no update/delete, no other tables).
3. **Get credentials** — Project Settings → API → copy the **Project URL** and the **anon public** key.
4. **Configure the app** — edit `supabase-config.js` and paste both values. Empty values = old
   serverless behaviour (links travel inside the URL).
5. **Deploy** the folder as usual. Done — the copy button now reads "🔗 Copy short link".

**Behaviour & safety notes**

- The anon key is public by design; security comes from the RLS policies above, plus
  `check` constraints limiting id length and payload size (≤300 KB).
- Share codes are 8 random unguessable chars (no look-alikes), generated client-side.
- Opened short links are cached in `localStorage` (`du-mcq-share-cache-v1`, last 25),
  so a previously opened link re-opens **offline**; the PWA itself stays fully offline.
- If Supabase is unreachable when copying, the app silently falls back to the long
  self-contained link and says so in a toast.
- Optional tidy-up: the SQL file contains a commented-out `pg_cron` job that purges
  sets older than 180 days.
- After changing any cached file (including `supabase-config.js`), bump `CACHE_VERSION`
  in `sw.js` so returning visitors refetch.

## Notes for maintainers

- Bump `CACHE_VERSION` in `sw.js` whenever you change any cached file so returning visitors
  pick up the new shell.
- Question JSON format: `[{"q":"…","options":["…","…"],"answer":0}, …]` (`answer` = 0-based index).
- IndexedDB: database `du-mcq-db`, object store `results` (auto-increment `id`, index on `savedAt`).
- PDF pagination slices the rasterized report at question-card boundaries; a card taller than a
  page is raw-sliced.
