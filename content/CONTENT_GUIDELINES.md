---
title: "Francesco Caglioti"
description: "Backend Engineer specializzato in PHP, Laravel e Symfony. Appassionato di HomeLab, self-hosting e tecnologie open source."
keywords: ["Francesco Caglioti", "Backend Engineer", "PHP Developer", "Laravel", "Symfony", "HomeLab", "Italia"]
sitemap:
  priority: 1.0
  changefreq: weekly
draft: true
---


## 📝 Content Guidelines

### Writing Articles

#### Required Frontmatter
```markdown
---
title: "Your Article Title"
date: 2025-01-01
description: "Brief description (1-2 sentences)"
draft: false
categories: ["category1", "category2"]
tags: ["tag1", "tag2", "tag3"]
keywords: ["keyword1", "keyword2"] # For SEO
showHero: true
showAuthorBottom: true
sitemap:
  priority: 0.7
---
```

#### Optional Frontmatter
```markdown
socialImage: "img/article-image.png" # Custom social image
series: "My Series Name" # If part of a series
keywords: ["seo", "keywords"] # For search engines
```

#### Content Structure
1. **Hook** - First paragraph should grab attention
2. **Context** - Why this matters
3. **Main content** - Use headings (H2, H3)
4. **Code examples** - Use code blocks with language
5. **Images** - Add screenshots when helpful
6. **Conclusion** - Summary and next steps
7. **Call-to-action** - Link to related articles

#### Cross-Linking Strategy

At the end of each article, add:

```markdown
## 📚 Related Articles

- [Article Title 1](/Article/slug-1/)
- [Article Title 2](/Article/slug-2/)
```

This helps with:
- SEO (internal linking)
- User engagement (more page views)
- Content discoverability

### Bilingual Content

For each article:
1. Create `content/Article/Name/index.md` (Italian)
2. Create `content/Article/Name/index.en.md` (English)
3. Keep same structure in both
4. Translate, don't literal translate

### Categories vs Tags

**Categories** (2-3 max):
- Broad topics
- Used for navigation
- Example: `["homelab", "vpn", "tutorial"]`

**Tags** (5-8 max):
- Specific keywords
- Used for filtering
- Example: `["tailscale", "wireguard", "nginx", "proxmox"]`

### SEO Best Practices

1. **Unique descriptions** - Each page needs unique meta description
2. **Keywords in title** - Include main keyword in title
3. **Internal links** - Link to your other articles
4. **External links** - Link to authoritative sources
5. **Image alt text** - Describe images for accessibility
6. **Headings hierarchy** - H1 → H2 → H3 (don't skip levels)

### Content Ideas

Based on your expertise:

#### PHP/Symfony
- "Building Robust APIs with Symfony and ApiPlatform"
- "PHP 8.x Features You Should Be Using"
- "Testing Symfony Applications with PHPUnit"
- "Docker Development Environment for PHP"

#### HomeLab
- "My Complete HomeLab Setup (2025)"
- "Self-Hosting vs Cloud: My Journey"
- "Automating HomeLab Backups"
- "HomeAssistant Automation Ideas"

#### Career/Dev
- "From Web Developer to Backend Engineer"
- "Working with Agile/Scrum: Lessons Learned"
- "Code Review Best Practices"
- "My Developer Workflow"

### Draft Workflow

1. Set `draft: true` while writing
2. Preview locally: `hugo server -D`
3. When ready, set `draft: false`
4. Push to main → auto-deploy

### Updating Old Articles

When you update an article:
1. Add `showDateUpdated: true` to frontmatter
2. Add "Last updated" note at bottom
3. Update internal links if needed
4. Check external links still work
