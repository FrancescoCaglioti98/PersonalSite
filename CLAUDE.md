# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
hugo server          # http://localhost:1313, published content only
hugo server -D       # includes draft: true articles
hugo --gc --minify   # production build; the exact command CI runs
```

`-D` is drafts; `-d` is `--destination`. To build without touching `public/`, use
`hugo -d <dir>`.

There is no test suite, no linter and no `package.json`. Validation is build-only:
a clean `hugo --gc --minify` is the check. Two `WARN` lines are pre-existing and
come from the Blowfish submodule, not from local changes — the theme/Hugo version
compatibility notice and the `.Language.LanguageCode` deprecation. Treat only
*new* warnings as regressions.

## Bilingual content

Italian is the default language and serves from `/`; English serves from `/en/`.
The convention is suffix-based: `index.md` is Italian, `index.en.md` is English.
Root pages follow the same rule (`cv.md` / `cv.en.md`). Any content change needs
both files, including new i18n keys.

Canonical URLs are lowercase (`/article/tailscale/`) even though content
directories are capitalized (`content/Article/Tailscale/`). Hugo also emits
capitalized aliases, so a link using the old casing redirects rather than 404s —
still prefer the canonical lowercase form in new links. English internal links
need the `/en/` prefix; front matter cannot use `ref` shortcodes, so those paths
are hardcoded.

## Pages driven by structured front matter

`/cv/` and `/projects/` take almost all their content from front-matter arrays,
not from the markdown body:

- `content/cv.md` → `layouts/_default/cv.html` reads `contacts`, `current`,
  `experiences`, `projects`, `skills`, `education`, `languages`, `interests`.
  The markdown body is only the profile paragraph.
- `content/projects.md` → `layouts/_default/projects.html` reads `projects[]`.
  An entry with `featured: true` also appears on the homepage.

Adding a field to these pages means editing the content file (both languages)
**and** the layout, otherwise it renders nothing and fails silently. This has
already happened: `interests` sat in `cv.md` for months while `cv.html` never
referenced it.

## Homepage composition

`params.toml` sets `[homepage] layout = "custom"`, which makes the theme's
`index.html` dispatch to `layouts/partials/home/custom.html`. The other
`[homepage]` params are **not** applied automatically on that path — `custom.html`
has to invoke the partials itself. `showRecent` and `showRecentItems` were set to
`true`/`3` and silently ignored for exactly this reason.

`custom.html` composes, in order: `home/hero.html`, `aboutme.html`,
`recent-articles/main.html`, `home/featured-projects.html`.

`home/hero.html` renders `{{ .Content }}` inside the hero, so creating
`content/_index.md` would put prose over the hero image. That file deliberately
does not exist: the "what I do" copy lives in the i18n key
`homepage.whatIDoIntro` and renders below the hero instead.

## i18n

`i18n/it.yaml` and `i18n/en.yaml` carry the section chrome for the homepage, CV
and projects pages, and also some body copy. Keys must be added to both files or
the other language renders the raw key name.

## The dateFormat trap

`dateFormat` in `config/_default/languages.*.toml` is a **Go time layout**, not a
strftime string. A localized month name written as a literal is copied verbatim
by Go: `"2 gennaio 2006"` made every Italian date render as `<day> gennaio <year>`,
so the whole blog appeared stuck in January. Use a CLDR token (`:date_long`,
`:date_medium`) — Hugo localizes month names from the language's locale. Both
languages currently use `:date_long`.

## Anything in content/ becomes a public page

A markdown file dropped in `content/` without front matter is built and listed in
the sitemap. `content/AGENTS.md` was live at `https://fcaglioti.cc/agents/` and
submitted to search engines for this reason. Keep documentation out of `content/`.
Files with `draft: true` are excluded from production builds
(`buildDrafts = false`), which is what keeps `content/old_index.{md,en.md}` — the
leftovers of a previous homepage — off the site.

## Theme overrides and CSS

`themes/blowfish` is a git submodule. Files under `layouts/` shadow
`themes/blowfish/layouts/` at the same relative path; check the theme copy before
writing a new override. Site CSS lives in `assets/css/custom.css` and is global,
so the `.cv-*` and `.project-*` class families can be reused from any layout
rather than duplicated.

## Deploy

Pushing to `main` triggers `.github/workflows/deploy.yml`, which builds and
force-pushes `public/` to the `deploy` branch; Cloudflare Workers serves from
there. **A commit pushed to `main` publishes the site.** Prefer a branch for work
that is not meant to go live. `deploy.sh` in the repo root is deprecated.

## Article conventions

See "Convenzioni per gli articoli" in `README.md` — no emoji, both language
versions, `draft: true` until ready, informal first person with the mistakes left
in. The tone of existing articles is deliberate; changes to articles should be
corrections and additions, not rewrites of voice.
