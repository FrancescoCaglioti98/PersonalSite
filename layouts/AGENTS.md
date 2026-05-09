# LAYOUTS DIRECTORY

## OVERVIEW

Custom HTML template overrides for Blowfish theme. Uses Hugo's template inheritance.

## STRUCTURE

```
layouts/
├── _default/
│   ├── 404.html       # Error page override
│   ├── contact.html   # Custom contact page
│   ├── cv.html        # CV page layout
│   ├── projects.html  # Projects page layout
│   └── uses.html      # Uses page
└── partials/
    ├── aboutme.html   # About me section
    ├── calendly-widget.html  # Calendly integration
    ├── extend-head.html      # Custom <head> injections
    ├── related.html          # Related articles
    ├── related-inline.html   # Inline related articles
    └── home/
        ├── custom.html       # Custom homepage layout
        └── hero.html         # Hero section override
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add custom page type | `layouts/_default/<type>.html` | Create new template |
| Modify <head> | `layouts/partials/extend-head.html` | Analytics, meta tags |
| Change homepage | `layouts/partials/home/custom.html` | Custom layout |
| Add partial | `layouts/partials/` | Reusable template fragments |

## CONVENTIONS

- **Partial naming**: Descriptive, lowercase with hyphens
- **Template overrides**: Match Hugo's lookup order (`_default/<type>.html`)
- **Go templates**: Use Hugo's `{{ template }}` syntax

## ANTI-PATTERNS

- ❌ Direct theme file edits (always override in `layouts/`, never edit `themes/`)
- ❌ Inline styles (use Tailwind classes or `assets/css/custom.css`)
- ❌ Hardcoded strings (use i18n strings from `i18n/`)

## UNIQUE STYLES

- **Custom homepage**: Uses `custom.html` partial instead of theme defaults
- **Extend-head pattern**: Clean injection point for custom `<head>` elements

## NOTES

- Theme updates won't affect custom layouts
- Test changes with `hugo server -D` before committing
