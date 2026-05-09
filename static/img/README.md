## 📸 Hero Image Guide

### Required Images

Create these images in `static/img/`:

#### 1. hero_image.png (or .webp)
- **Size**: 1200x630px (Open Graph standard)
- **Purpose**: Social media sharing, homepage background
- **Content suggestions**:
  - Your name: "Francesco Caglioti"
  - Title: "Backend Engineer"
  - Subtle tech/HomeLab background
  - Match Noir dark theme

#### 2. Article-specific images (optional)
- Save in `content/Article/<ArticleName>/`
- Name: `featured.png` or `social.png`
- Same 1200x630px size
- Used for article social sharing

### Tools to Create Images

**Free Options:**
- **Figma** - Professional design tool (free tier)
- **Canva** - Templates for social images
- **Photopea** - Free online Photoshop alternative
- **GIMP** - Desktop image editor

**AI-Assisted:**
- Use AI for background generation
- Add text overlays in Figma/Canva

### Example Layout

```
┌─────────────────────────────────────┐
│                                     │
│   Francesco Caglioti                │
│   Backend Engineer                  │
│                                     │
│   [subtle tech pattern/bg]          │
│                                     │
└─────────────────────────────────────┘
```

### Color Palette (Noir Theme)

- Background: `#1a1a1a` or `#0d0d0d`
- Text: `#ffffff` or `#e5e5e5`
- Accent: Check `themes/blowfish/assets/css/colors/noir.css`

### Optimization

- Use **WebP** format for better compression
- Keep file size under 200KB
- Test with [WebPageTest](https://www.webpagetest.org/) or [Lighthouse](https://developer.chrome.com/docs/lighthouse/overview/)

### Placeholder

Until you create your image, the site will work without it, but social sharing won't look as nice.
