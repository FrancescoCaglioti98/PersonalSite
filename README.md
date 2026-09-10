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

## Sviluppo locale

```bash
hugo server          # http://localhost:1313, solo contenuti pubblicati
hugo server -D       # include anche gli articoli con draft: true
hugo --gc --minify   # build di produzione, lo stesso comando che gira in CI
```

Attenzione a `-D` maiuscolo: `-d` minuscolo è `--destination`, cioè la cartella
di output.

Il tema è un submodule git. Dopo un clone serve `git submodule update --init
--recursive`, e per aggiornarlo `git submodule update --remote`.

Lo script `deploy.sh` in root è deprecato: il deploy passa dalla GitHub Action.

## Deploy

Il deploy è automatico: ogni push su `main` triggera la GitHub Action che builda il sito e fa force-push del contenuto di `public/` sul branch `deploy`. Cloudflare Workers riprende da lì e pubblica il sito.

## Convenzioni per gli articoli

- Niente emoji nel testo degli articoli.
- Niente commenti inutili nei blocchi di codice: solo se c'è qualcosa di non ovvio.
- Elenchi numerati solo quando l'ordine conta davvero, altrimenti elenchi puntati.
- Sempre entrambe le lingue: `index.md` (italiano) e `index.en.md` (inglese).
- `draft: true` finché l'articolo non è pronto per la pubblicazione.
- Tono informale, in prima persona, con le ammissioni di errore dove ci sono state.
