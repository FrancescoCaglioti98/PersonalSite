# CONTENT DIRECTORY

## OVERVIEW

Bilingual Markdown content (Italian default + English). Article bundles + standalone pages.

## STRUCTURE

```
content/
├── Article/           # Article bundles (capitalized - non-standard)
│   ├── _index.md      # List page (Italian)
│   ├── _index.en.md   # List page (English)
│   └── <Name>/
│       ├── index.md   # Article (Italian)
│       └── index.en.md # Article (English)
├── cv.md / cv.en.md   # CV page (bilingual pair)
├── projects.md / projects.en.md  # Projects page
└── CONTENT_GUIDELINES.md  # Content writing guidelines
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add new article | `content/Article/<Name>/index.md` + `.en.md` | Create both language versions |
| Edit existing | Match filename suffix | `.md` = Italian, `.en.md` = English |
| Content guidelines | `content/CONTENT_GUIDELINES.md` | Writing standards |

## CONVENTIONS

- **Bilingual suffix**: `.en.md` for English, plain `.md` for Italian (default)
- **Leaf bundles**: Each article in its own directory with `index.md`
- **Capitalized "Article"**: Non-standard (Hugo convention is lowercase `article/`)
- **Mixed structure**: Root-level pages (`cv.md`) + bundled articles

## ANTI-PATTERNS

- ❌ Single-language articles (always create both `.md` + `.en.md`)
- ❌ Flat files in `Article/` (must be in subdirectories as bundles)
- ❌ Inconsistent naming (use TitleCase for article directories)

## NOTES

- URL paths will include `/Article/` (capitalized) due to directory name
- Root-level pages (`cv.md`, `projects.md`) render at `/cv`, `/projects`
