# Personal Blog

Sito personale e blog, costruito con [Hugo](https://gohugo.io/) e il tema [Blowfish](https://blowfish.page/).

## Stack

- **Hugo** (v0.161.0) con tema Blowfish (Tailwind CSS)
- **Bilingue**: italiano (default) + inglese
- **Analytics**: Umami
- **Deploy**: GitHub Actions → branch `deploy` → Cloudflare Workers

## Struttura contenuti

- `content/Article/<Nome>/index.md` — versione italiana
- `content/Article/<Nome>/index.en.md` — versione inglese

## Deploy

Il deploy è automatico: ogni push su `main` triggera la GitHub Action che builda il sito e fa force-push del contenuto di `public/` sul branch `deploy`. Cloudflare Workers riprende da lì e pubblica il sito.
