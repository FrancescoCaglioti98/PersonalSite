---
title: "Francesco Caglioti"
date: 2025-09-27
description: "Software Engineer — backend PHP, Symfony e Go. Oltre 4 anni di esperienza, oggi in Iliad Italia."
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
location: "Castellanza (VA), Italia"

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
    location: "Milano"
    period: "Ago 2024 – oggi"
    description: "Backend PHP/Symfony della piattaforma di gestione clienti business. Metodologia Agile (Scrum, Kanban)."
    highlights:
      - "Co-progettato con il team backend un nuovo servizio di fatturazione **multi-tenant in Go**: definito il perimetro dell'MVP, scritte le prime righe di codice, attualmente uno dei due sviluppatori attivi."
      - "Sviluppata **end-to-end la gestione dei reclami**: i clienti aprono procedure di verifica dalla propria area personale senza contattare il customer care, che ottiene visibilità sull'avanzamento delle pratiche."
      - "Riscritto il **mock server dei servizi esterni** (billing, gestione linee di rete): servizio Docker che intercetta le chiamate ai partner e all'occorrenza fa da proxy. Usato da tutto il team backend, frontend e QA, ha rimosso la dipendenza dagli ambienti di sviluppo dei partner nei test in staging."
      - "Introdotti **PHPStan e PHP CS Fixer** nelle pipeline GitLab CI del progetto principale: analisi statica e stile del codice da controllo manuale a verifica automatica su ogni merge request."
      - "Sviluppo di **API REST** con Symfony e API Platform, code di eventi con Messenger, test unit e funzionali (PHPUnit) su ogni nuova feature; migrate le API di ricerca indirizzi da un sistema Elasticsearch legacy a servizi centralizzati."

  - role: "Web Developer"
    company: "Atik S.r.l."
    location: "Lissone"
    period: "Apr 2022 – Ago 2024"
    description: "ERP/CRM proprietario per PMI (PHP 5.6), integrato con i gestionali Microarea Mago via database e API XML. Circa 50 clienti, ciascuno con installazione dedicata on-premise o su server gestiti."
    highlights:
      - "Riscritto da zero, in autonomia, il **modulo e-commerce con diversi canali integrati** (Amazon, eBay, Shopify, PrestaShop e altri): sostituita la conversione dei dati a runtime con la normalizzazione in fase di ingestione verso un formato JSON canonico comune a tutte le piattaforme. Caricamento della vista ordini **da circa 2 minuti a meno di 5 secondi**."
      - "Progettata la configurazione del modulo: transcodifica degli SKU tra shop ed ERP e gestione degli SKU-bundle. Scritto anche il connettore PrestaShop installato lato cliente."
      - "**Introdotto il controllo di versione** in un team che sviluppava senza versionamento, in SSH sullo stesso server condiviso; portato successivamente lo sviluppo su ambienti locali isolati con Docker."
      - "Scritto lo script di **aggiornamento remoto** dei moduli sulle installazioni dei clienti, eliminando gli interventi manuali su ogni ambiente."
      - "Progettati e realizzati **3 applicativi custom** per clienti con esigenze fuori standard, in autonomia full stack (Laravel, Vue.js, PrimeVue): raccolta dei requisiti con il cliente, disegno dell'interfaccia, sviluppo frontend e backend, verifica finale delle funzionalità."
      - "Realizzato un modulo di invio email automatiche e configurabili ai lead (reminder, appuntamenti) tramite **Microsoft Graph API** di Office 365. Amministrazione dei server CentOS, cron e troubleshooting in produzione."

  - role: "Esperienze precedenti"
    period: "2020 – 2022"
    description: "Professore assistente di Tecnologie Informatiche, Istituto Puecher-Olivetti, Rho (mar – giu 2021) · Amministratore ServiceNow, Blue IT (set 2021 – gen 2022): configurazione di workflow, gestione utenze, primi script · Customer service e assistenza tecnica (Amazon; Sielte per Vodafone) · Startup nel settore sicurezza e risk management."

projects:
  - name: "Piattaforma SaaS B2B multi-tenant"
    label: "progetto personale"
    tech: "Laravel, PostgreSQL"
    description: "Gestione di flotte, autisti, magazzini e trasporti per aziende di logistica. Isolamento dei dati multi-tenant su database condiviso implementato senza package esterni: global scope automatico sui model, contesto tenant per singola richiesta, impersonificazione dei tenant per il supporto, UUID come identificatori e test automatici di isolamento cross-tenant. [Architettura documentata qui](/article/saas-multi-tenant/saas-multi-tenant-laravel/)."

skills:
  - group: "Linguaggi"
    items: "PHP 8.3 · Go (in produzione dal 2026, in apprendimento) · JavaScript · SQL · Bash"
  - group: "Framework"
    items: "Symfony 6.4 · API Platform · Symfony Messenger · Laravel · Vue.js / PrimeVue"
  - group: "Database"
    items: "PostgreSQL · MySQL / MariaDB · Redis"
  - group: "Qualità"
    items: "PHPUnit · PHPStan · PHP CS Fixer · code review · Agile (Scrum, Kanban)"
  - group: "Strumenti"
    items: "Docker · Git · GitLab CI · Nginx · Jira · ClickUp"

education:
  - title: "Diploma di Tecnico Informatico e Telecomunicazioni, articolazione Informatica"
    period: "2017"
  - title: "Università di Pisa, Ingegneria Elettronica"
    note: "percorso non completato"
    period: "2017 – 2020"

languages:
  - "Italiano madrelingua"
  - "Inglese B1/B2 — lettura tecnica fluente, conversazione intermedia"

interests:
  - name: "Homelab"
    description: "Proxmox, container LXC, reverse proxy con SSL, networking e servizi self-hosted"
  - name: "Divulgazione tecnica"
    description: "Gli articoli di questo sito, dove racconto le scelte tecniche e gli errori"
---

Backend developer con oltre 4 anni di esperienza in PHP, dal legacy PHP 5.6 a PHP 8.3 con Symfony. Attualmente sul backend di una piattaforma di gestione clienti business, dove co-progetto un servizio di fatturazione multi-tenant in Go. Ho lavorato su entrambi i modelli architetturali: circa 50 installazioni single-tenant distribuite presso i clienti e sistemi multi-tenant su database condiviso progettati da zero.
