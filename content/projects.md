---
title: "Progetti"
description: "Alcuni progetti su cui ho lavorato"
date: 2025-01-01
draft: false
layout: "projects"
sitemap:
  priority: 0.8

projects:
  - name: "SaaS Trasporti"
    description: "Piattaforma B2B multi-tenant per aziende di trasporti: ogni azienda cliente gestisce la propria flotta, i suoi autisti, i magazzini e i trasporti nel proprio spazio isolato. Progetto personale, nato per noia e cresciuto in un tentativo di prodotto che non è mai diventato tale."
    period: "2026"
    role: "Progetto personale"
    featured: true
    tech: ["Laravel", "PostgreSQL", "Docker"]
    link: "/article/saas-multi-tenant/saas-multi-tenant-laravel/"
    linkText: "Come funziona l'isolamento"
    highlights:
      - "Isolamento multi-tenant su database condiviso, senza package esterni"
      - "Global scope automatico sui model e contesto tenant per singola richiesta"
      - "Impersonificazione dei tenant per il supporto"
      - "UUID come identificatori e test automatici di isolamento cross-tenant"

  - name: "HomeLab"
    description: "Il mio laboratorio casalingo dove sperimento con self-hosting, automazione e servizi personali."
    period: "2024 - oggi"
    role: "Maintainer"
    status: "active"
    featured: true
    tech: ["Proxmox", "Docker", "Tailscale", "Nginx Proxy Manager", "HomeAssistant"]
    link: "/article/tailscale/"
    linkText: "Vedi dettagli tecnici"
    highlights:
      - "HomeAssistant per la domotica"
      - "Paperless per la gestione documentale"
      - "Trilium Notes per la knowledge base"
      - "Vikunja per il task management"

  - name: "Personal Website"
    description: "Il mio sito personale e blog, un work-in-progress continuo dove sperimento nuove funzionalità."
    period: "2025 - oggi"
    role: "Full Stack Developer"
    status: "active"
    tech: ["Hugo", "Blowfish Theme", "Tailwind CSS", "Cloudflare Workers"]
    link: "https://github.com/FrancescoCaglioti98/PersonalSite"
    linkText: "Vedi il codice su GitHub"
    highlights:
      - "Bilingue (Italiano/Inglese)"
      - "Dark mode automatica"
      - "Analytics con Umami"
      - "Deploy automatico via GitHub Actions"

  - name: "Integrazione Office365 Graph API"
    description: "Integrazione delle Graph API di Office365 per la gestione email e calendari in un gestionale aziendale."
    period: "2023"
    role: "Backend Developer"
    status: "completed"
    tech: ["PHP", "Microsoft Graph API", "OAuth2"]
    highlights:
      - "Invio email tramite Outlook"
      - "Sincronizzazione eventi calendario"
      - "Gestione contatti"
      - "Notifiche in tempo reale"
    results:
      - "Unificazione della comunicazione"
      - "Riduzione switching tra app"
      - "Migliore tracciabilità"
---

Sono sempre interessato a discutere nuove idee, collaborazioni o sfide tecniche interessanti. Se hai un progetto in mente, contattami pure.
