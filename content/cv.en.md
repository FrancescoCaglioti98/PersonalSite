---
title: "Francesco Caglioti"
date: 2025-09-27
description: "Software Engineer — backend PHP, Symfony and Go. 4+ years of experience, currently at Iliad Italia."
draft: false
layout: "cv"
categories: ["cv"]
sitemap:
  priority: 0.8
showAuthorBottom: false
showAuthor: false
showDate: false
showReadingTime: false
sharingLinks: false
showHero: true

subtitle: "Software Engineer — Backend · PHP · Symfony · Go"
location: "Milan area, Italy"

contacts:
  - label: "personal@fcaglioti.cc"
    url: "mailto:personal@fcaglioti.cc"
  - label: "linkedin.com/in/frcaglioti"
    url: "https://linkedin.com/in/frcaglioti"
  - label: "github.com/FrancescoCaglioti98"
    url: "https://github.com/FrancescoCaglioti98"

current:
  role: "Software Engineer @ Iliad Italia"
  stack: "PHP 8.3, Symfony 6.4, PostgreSQL, Go, Docker"

experiences:
  - role: "Software Engineer"
    company: "Iliad Italia"
    location: "Milan"
    period: "Aug 2024 – Present"
    description: "PHP/Symfony backend of the business customer management platform. Agile (Scrum, Kanban)."
    highlights:
      - "Co-designed a new **multi-tenant billing service in Go** with the backend team: scoped the MVP, wrote the first lines of code, currently one of its two active developers."
      - "Built the **complaints management system end to end**: customers now open investigation cases from their own account area without calling customer care, which in turn gets full visibility on case progress."
      - "Rewrote the **mock server for external services** (billing, network line provisioning): a Docker service that intercepts partner API calls and optionally proxies them. Used by the whole backend, frontend and QA team, it removed our dependency on partner development environments for staging tests."
      - "Introduced **PHPStan and PHP CS Fixer** into the main project's GitLab CI pipelines, moving static analysis and code style from manual review to automated checks on every merge request."
      - "**REST API development** with Symfony and API Platform, event queues with Messenger, unit and functional tests (PHPUnit) on every new feature; migrated address lookup APIs from a legacy Elasticsearch system to centralised services."

  - role: "Web Developer"
    company: "Atik S.r.l."
    location: "Lissone (Italy)"
    period: "Apr 2022 – Aug 2024"
    description: "In-house ERP/CRM for small and medium businesses (PHP 5.6), integrated with Microarea Mago ERP via direct database access and XML APIs. Around 50 customers, each with a dedicated on-premise or managed installation."
    highlights:
      - "Rebuilt the **e-commerce module from scratch**, single-handedly, with several integrated channels (Amazon, eBay, Shopify, PrestaShop and others): replaced runtime data conversion with normalisation at ingestion into a canonical JSON format shared across all platforms. Order list load time went **from roughly 2 minutes to under 5 seconds**."
      - "Designed the module configuration layer: SKU mapping between storefront and ERP, and handling of bundle SKUs. Also wrote the PrestaShop connector installed on the customer side."
      - "**Introduced version control** in a team that worked without it, developing over SSH on one shared server; later moved development to isolated local Docker environments."
      - "Wrote the **remote module update script** for customer installations, removing manual deployment work on each environment."
      - "Designed and delivered **3 bespoke applications** for customers with non-standard needs, working full stack on my own (Laravel, Vue.js, PrimeVue): requirements gathering with the client, interface design, frontend and backend development, and final acceptance checks."
      - "Built a configurable automated email module for leads (reminders, appointments) using the **Office 365 Microsoft Graph API**. CentOS server administration, cron jobs and production troubleshooting."

  - role: "Earlier roles"
    period: "2020 – 2022"
    description: "Teaching assistant, Computer Technologies — Puecher-Olivetti technical high school, Rho (Mar – Jun 2021) · ServiceNow administrator, Blue IT (Sep 2021 – Jan 2022): workflow configuration, user management, first scripting · Customer service and technical support (Amazon; Sielte for Vodafone) · Startup in the security and risk-management sector."

projects:
  - name: "Multi-tenant B2B SaaS platform"
    label: "personal project"
    tech: "Laravel, PostgreSQL"
    description: "Fleet, driver, warehouse and shipment management for logistics companies. Multi-tenant data isolation on a shared database, implemented without third-party packages: automatic global scopes on models, per-request tenant context, tenant impersonation for support, UUID identifiers and automated cross-tenant isolation tests. [Architecture written up here](/en/article/saas-multi-tenant/saas-multi-tenant-laravel/)."

skills:
  - group: "Languages"
    items: "PHP 8.3 · Go (in production since 2026, still learning) · JavaScript · SQL · Bash"
  - group: "Frameworks"
    items: "Symfony 6.4 · API Platform · Symfony Messenger · Laravel · Vue.js / PrimeVue"
  - group: "Databases"
    items: "PostgreSQL · MySQL / MariaDB · Redis · Elasticsearch"
  - group: "Quality"
    items: "PHPUnit · PHPStan · PHP CS Fixer · code review · Agile (Scrum, Kanban)"
  - group: "Tooling"
    items: "Docker · Git · GitLab CI · Nginx · Jira · ClickUp"

education:
  - title: "Technical diploma in IT and Telecommunications (Computer Science track)"
    period: "2017"
  - title: "University of Pisa — Electronic Engineering"
    note: "coursework only, degree not completed"
    period: "2017 – 2020"

languages:
  - "Italian native"
  - "English B1/B2 — fluent technical reading, intermediate conversation"

interests:
  - name: "Homelab"
    description: "Proxmox, LXC containers, reverse proxy with SSL, networking and self-hosted services"
  - name: "Technical writing"
    description: "The articles on this site, where I write up technical decisions and mistakes"
---

Backend developer with 4+ years in PHP, from legacy PHP 5.6 to PHP 8.3 with Symfony. Currently on the backend of a business customer management platform, where I co-design a multi-tenant billing service in Go. I have worked on both architectural models: around 50 single-tenant installations deployed at customer sites, and multi-tenant systems on a shared database designed from scratch.
