---
title: "Projects"
description: "Some projects I've worked on"
date: 2025-01-01
draft: false
layout: "projects"
sitemap:
  priority: 0.8

projects:
  - name: "Transport SaaS"
    description: "Multi-tenant B2B platform for transport companies: each customer company manages its own fleet, drivers, warehouses and shipments in its own isolated space. Personal project, started out of boredom and grown into an attempt at a product that never became one."
    period: "2026"
    role: "Personal project"
    featured: true
    tech: ["Laravel", "PostgreSQL", "Docker"]
    link: "/en/article/saas-multi-tenant/saas-multi-tenant-laravel/"
    linkText: "How the isolation works"
    highlights:
      - "Multi-tenant isolation on a shared database, without third-party packages"
      - "Automatic global scopes on models and a per-request tenant context"
      - "Tenant impersonation for support"
      - "UUID identifiers and automated cross-tenant isolation tests"

  - name: "HomeLab"
    description: "My home laboratory where I experiment with self-hosting, automation, and personal services."
    period: "2024 - present"
    role: "Maintainer"
    status: "active"
    featured: true
    tech: ["Proxmox", "Docker", "Tailscale", "Nginx Proxy Manager", "HomeAssistant"]
    link: "/en/article/tailscale/"
    linkText: "See technical details"
    highlights:
      - "HomeAssistant for home automation"
      - "Paperless for document management"
      - "Trilium Notes for knowledge base"
      - "Vikunja for task management"

  - name: "Personal Website"
    description: "My personal website and blog, a continuous work-in-progress where I experiment with new features."
    period: "2025 - present"
    role: "Full Stack Developer"
    status: "active"
    tech: ["Hugo", "Blowfish Theme", "Tailwind CSS", "Cloudflare Workers"]
    link: "https://github.com/FrancescoCaglioti98/PersonalSite"
    linkText: "See the code on GitHub"
    highlights:
      - "Bilingual (Italian/English)"
      - "Automatic dark mode"
      - "Analytics with Umami"
      - "Automated deploy via GitHub Actions"

  - name: "Office365 Graph API Integration"
    description: "Integration of Office365 Graph APIs for email and calendar management in a business ERP."
    period: "2023"
    role: "Backend Developer"
    status: "completed"
    tech: ["PHP", "Microsoft Graph API", "OAuth2"]
    highlights:
      - "Email sending via Outlook"
      - "Calendar event synchronization"
      - "Contact management"
      - "Real-time notifications"
    results:
      - "Unified communication"
      - "Reduced app switching"
      - "Better traceability"
---

I'm always interested in discussing new ideas, collaborations, or interesting technical challenges. If you have a project in mind, feel free to contact me.
