# PROJECT KNOWLEDGE BASE

**Generated:** 2026-05-09
**Commit:** 2e0a00d
**Branch:** main

## OVERVIEW

Personal blog/site built with Hugo v0.161.0 + Blowfish theme (Tailwind CSS). Bilingual (Italian default + English). Deployed via GitHub Actions → `deploy` branch → Cloudflare Workers.

## STRUCTURE

```
./
├── config/_default/     # Hugo + theme configuration (TOML)
├── content/             # Markdown content (bilingual: .md + .en.md)
├── layouts/             # Custom template overrides (HTML)
├── assets/              # Processable assets (CSS, JS)
├── static/              # Static files (images, favicons)
├── i18n/                # Translation strings (YAML)
├── archetypes/          # Content templates
├── themes/blowfish/     # External theme (git submodule)
├── public/              # Generated output (gitignored)
└── .github/workflows/   # CI/CD deployment
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add/edit content | `content/Article/<Name>/index.md` + `.en.md` | Bilingual pairs |
| Change site config | `config/_default/hugo.toml`, `params.toml` | Hugo + theme settings |
| Custom templates | `layouts/_default/`, `layouts/partials/` | Overrides theme defaults |
| Styling | `themes/blowfish/tailwind.config.js` | Custom color scheme "Noir" |
| Deployment | `.github/workflows/deploy.yml` | Auto-deploy on push to main |
| Analytics | `config/_default/params.toml` | Umami config |

## CODE MAP

| Symbol | Type | Location | Role |
|--------|------|----------|------|
| `hugo.toml` | Config | `config/_default/` | Site baseURL, languages, taxonomies |
| `params.toml` | Config | `config/_default/` | Theme options, dark mode, analytics |
| `markup.toml` | Config | `config/_default/` | Goldmark renderer, math delimiters |
| `extend-head.html` | Partial | `layouts/partials/` | Custom head injections |
| `custom.html` | Partial | `layouts/partials/home/` | Custom homepage layout |
| `home.js` | Script | `assets/js/` | Currently empty |

## CONVENTIONS

- **Bilingual content**: Suffix-based (`.en.md` for English, no suffix for Italian default)
- **Article bundles**: `content/Article/<Name>/index.md` (leaf bundles)
- **Dark-first**: Default appearance is dark with auto-switch
- **No root package.json**: Build relies on Hugo CLI + GitHub Actions only

## ANTI-PATTERNS (THIS PROJECT)

- ❌ Manual deployment via `deploy.sh` (DEPRECATED - use GitHub Actions)
- ❌ Committing `.DS_Store` or `.idea/` (present but should be ignored)
- ❌ Empty config files (`module.toml` is 0 bytes)
- ❌ Direct internet exposure of Nginx services (documented security rule)

## UNIQUE STYLES

- **Color scheme**: "Noir" (custom dark theme via CSS variables)
- **Fingerprint algorithm**: SHA-512 (vs default SHA-256)
- **Homepage**: Custom layout with card view, 3 recent articles
- **Sharing**: LinkedIn, Twitter, Reddit, Facebook, Email, WhatsApp, Telegram

## COMMANDS

```bash
# Local development
hugo server -D

# Production build
hugo --minify

# Update theme (submodule)
git submodule update --remote

# Update Hugo modules
hugo mod get -u
```

## NOTES

- **Deploy handoff**: CI pushes to `deploy` branch; Cloudflare Workers picks up from there
- **Theme version**: Blowfish v2.103.0 (requires Hugo 0.141.0+)
- **Content structure**: Mixed - some root-level pages (`cv.md`, `projects.md`) + article bundles
- **No tests**: Validation is build-only via GitHub Actions
