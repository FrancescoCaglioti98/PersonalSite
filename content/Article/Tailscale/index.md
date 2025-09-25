---
title: "VPN Tailscale"
date: 2025-09-24
description: "Accedo alla mia rete domestica da qualsiasi luogo"
draft: false
categories: ["homelab", "vpn", "tailscale"]
showAuthorBottom: true
showHero: true
---
## HomeLab

Ho un HomeLab con delle funzionalità molto basiche, come ad esempio:
- HomeAssistant 
- Paperless 
- Trilium Notes

A questi servizi ho sempre effettuato l'accesso tramite Cloudflare Tunnel e non mi sono mai trovato male nel suo utilizzo,
però mi ha sempre dato fastidio il dover pubblicare al mondo esterno tutti i miei servizi e renderlo accessibile a chiunque.

Quindi con il tempo ho cercato di valutare l'idea di utilizzare una VPN per poter utilizzare solo io, e le persone a concedo l'accesso, la possibilità di utilizzarli.
Questa decisione viene con dei drawback, per esempio non poter condividere dei link i documenti all'interno di paperless o non avere tutte le funzionalità
di “**away from zone**” di HomeAssistant, ma nulla che una soluzione ibrida non possa mitigare.

Per dare un attimo di contesto sulla struttura del mio HomeLab, ho un [MiniPc](https://www.amazon.it/dp/B0CXCT4M2F) su cui ho installato Proxmox. All'interno
del quale è presente un container LCX per il Tunnel Cloudflare, che fino a oggi si è occupato (insieme al pannello di configurazione sulla dashboard Cloudflare)
di svolgere funzioni di Reverse Proxy per servizi che volevo rendere disponibili al di fuori della rete.

## Tailscale
Informandomi su SubReddit e, in generale su Youtube (santo youtube), sono incappato in un diverse persone che utilizzano Tailscale,
un provider VPN con un ottimo piano gratuito per hobbisti basato su WireGuard.
A questo punto ho creato un account, collegato il mio pc e il telefono per la prima configurazione e
ho iniziato a progettare quello che sarebbe necessario configurare da qua in poi.



Ho deciso quindi di utilizzare un nuovo container LCX di Nginx Proxy Manager (https://community-scripts.github.io/ProxmoxVE/scripts?id=nginxproxymanager) per svolgere le funzioni di Reverse Proxy.

