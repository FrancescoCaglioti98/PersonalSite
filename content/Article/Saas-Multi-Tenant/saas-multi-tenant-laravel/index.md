---
title: "Multi-Tenant con Laravel: Isolamento Dati e Global Scope"
date: 2026-05-11
description: "Come ho costruito un SaaS B2B multi-tenant con isolamento dati automatico"
draft: false
categories: ["saas", "laravel", "backend"]
tags: ["multi-tenant", "laravel", "eloquent", "postgresql", "saas"]
keywords: ["laravel multi-tenant", "saas isolamento dati", "global scope eloquent", "tenant isolation"]
showAuthorBottom: true
showHero: true
series: ["Architettura di un SaaS Multi-Tenant"]
series_order: 1
sitemap:
  priority: 0.7
---
## Il Progetto

Ho appena finito di creare una piattaforma SaaS per aiutare le aziende di trasporti a gestire i loro servizi. Questa piattaforma è un sistema B2B multi-tenant, cioè ogni azienda cliente ha il proprio spazio dove può gestire la sua flotta, i suoi autisti, i magazzini ed i trasporti, senza vedere dati e/o azioni degli altri clienti.

Quando ho iniziato a progettare la piattaforma non sapevo se utilizzare database diversi per ogni cliente o crearne uno solo condiviso.

Alla fine, ho deciso di condividere un unico database tra tutti i clienti, per due motivi principali: facilità di manutenzione e risparmio di denaro una volta che si va in produzione.

Ho dovuto però imparare come dividere, isolare e gestire i dati dei clienti a compartimenti stagni.

In questo articolo racconto come ho applicato questo isolamento con Laravel, senza l'utilizzo di package esterni, quali errori ho commesso e cosa farei di diverso se dovessi riscrivere da capo una gestione del genere.

## Il Flusso Logico

Ecco come i dati vengono isolati dal momento della richiesta fino alla risposta del database:

```text
USER REQUEST
     │
     ▼
MIDDLEWARE (The Gatekeeper) ────────┐
     │                              │
     │ 1. Verifica Autenticazione   │ 403 UNAUTHORIZED
     │ 2. Estrazione Tenant ID      │ (Se nessun accesso)
     │                              └───────────────────► [ EXIT ]
     ▼
TENANT CONTEXT (Fonte di Verità)
     │
     │ 3. Salvataggio ID nel Singleton
     │
     ▼
ELOQUENT MODELS (The Workers)
     │
     │ 4. Boot del Trait BelongsToTenant
     │ 5. Applicazione automatica GlobalScope
     │
     ▼
DATABASE QUERY
     │
     │ SELECT * FROM table WHERE tenant_id = [X]
     │
     ▼
RISPOSTA DATI ISOLATI (Successo!)
```

## Shared Database: Perché questa scelta?

La decisione di usare un database condiviso (Single-Database Multi-tenancy) non è stata solo dettata dal costo. In un sistema B2B, la facilità di evoluzione del database è critica.

*   **Vantaggio:** Le migrazioni sono atomiche. Se aggiungo una colonna a `transports`, lo faccio una volta sola per tutti i clienti.
*   **Svantaggio:** Il rischio del "Noisy Neighbor" (un tenant che satura le risorse) è reale, e l'isolamento è logico, non fisico.

Se avessi optato per database separati, avrei avuto un isolamento hardware perfetto, ma gestire 500 migrazioni (se mai arriverò ad avere così tanti tenant) diverse ogni volta che rilascio una feature sarebbe diventato un lavoro a tempo pieno.

## Testare l'Isolamento (Seriamente)

La parte più importante è, e sarà sempre, scrivere dei test per ogni nuovo endpoint o funzione.

Per esempio, creo un punto API per il ritorno delle metriche di andamento mensile? Ci aggiungo un test specifico (al di là degli happy path ed edge cases) che vada a verificare che le metriche del TenantA non siano viste dal TenantB.

Non è solo perché non mi fido del mio lavoro, ma è soprattutto per assicurarmi che in futuro non vada a fare qualche sviluppo che rompa questa compartimentalizzazione, non ho fiducia nel me del futuro sul ricordarsi ogni cosa o non fare "cappellate".

Questo è un esempio in PhpUnit dove vado a testare un endpoint:

```php
public function test_cross_tenant_isolation(): void
{
    $tenantA = Tenant::factory()->create();
    $tenantB = Tenant::factory()->create();

    Product::factory()->for($tenantA)->create(['name' => 'Articolo A']);
    Product::factory()->for($tenantB)->create(['name' => 'Articolo B']);

    $response = $this->actingAs($this->userInTenant($tenantA))
        ->getJson('/api/v1/products');

    $response->assertOk();
    $response->assertJsonCount(1, 'data');
    $response->assertJsonPath('data.0.name', 'Articolo A');
}
```

Senza un test di questo tipo, sto solo "sperando" che il GlobalScope sia applicato in maniera globale.

## GlobalScope e TenantContext

A proposito di GlobalScope, si tratta di una funzionalità di Laravel che permette di applicare automaticamente una, o più, clausole `where` a tutte le query assegnate ad un model. Per il nostro scopo è manna dal cielo.

Ora resta una domanda importante, chi sarà la mia fonte di verità in merito all'ID del tenant da applicare alla query?

Ho deciso di creare una classe TenantContext, un oggetto singleton che mantiene lo stato del tenant per l'intera durata della richiesta. Sarà lui la mia fonte di verità.
Il context viene applicato a tutte le richieste in ingresso grazie ad un Middleware specifico. Questo rende il sistema testabile e indipendente dal driver di autenticazione (web, API, o CLI).

Ho creato un trait `BelongsToTenant` che automatizza sia la lettura che la scrittura:

```php
trait BelongsToTenant
{
    public static function bootBelongsToTenant(): void
    {
        static::addGlobalScope('tenant', function (Builder $query) {
            $context = app(TenantContext::class);
            if ($context->isSet()) {
                $query->where('tenant_id', $context->id());
            }
        });

        static::creating(function (Model $model) {
            $context = app(TenantContext::class);
            if ($context->isSet() && !$model->tenant_id) {
                $model->tenant_id = $context->id();
            }
        });
    }
}
```

Ogni model che rappresenta un'entità del tenant (Clienti, Veicoli, Trasporti, ecc.) ha questo trait. In questo modo, non solo le query sono filtrate, ma non devo nemmeno ricordarmi di assegnare il `tenant_id` quando salvo un nuovo oggetto.

## Il Middleware EnsureTenantAccess

Il middleware è il "ponte" che popola il nostro `TenantContext` all'inizio di ogni richiesta.

```php
public function handle($request, Closure $next)
{
    $user = $request->user();

    if (!$user || (!$user->tenant_id && !$user->isSuperAdmin())) {
        abort(403, 'Nessun tenant associato');
    }

    $tenantId = $user->isSuperAdmin() 
        ? session('impersonate_tenant_id') 
        : $user->tenant_id;

    if ($tenantId) {
        app(TenantContext::class)->set($tenantId);
        
        $tenant = Tenant::find($tenantId);
        if ($tenant->is_read_only && $request->isMethodSafe() === false) {
            abort(403, 'Account in sola lettura');
        }
    }

    return $next($request);
}
```

Questo middleware è applicato a tutte le rotte che operano con i dati di un tenant. Una volta che si passa da qua l'utente attualmente loggato è "bloccato" nel contesto di quel tenant ed il GlobalScope sa come agire.

## Il Caso Super Admin e l'Impersonificazione

Un sistema B2B non può funzionare senza un servizio di supporto.
Il `super_admin` deve poter "entrare" nell'account di un cliente per diagnosticare problemi, senza però che i suoi dati si mescolino con quelli del cliente.

La soluzione che ho adottato è l'**impersonificazione**:
- Il Super Admin non ha un `tenant_id` fisso.
- Tramite una dashboard di amministrazione, si sceglie quale Tenant (Cliente) da assistere/verificare.
- Salviamo l'ID del tenant in sessione (`impersonate_tenant_id`).
- Il middleware legge dalla sessione e "finge" che il Super Admin appartenga a quel tenant per la durata della navigazione.

In caso di supporto questo ci permette di avere le stesse ed identiche viste di un cliente.

## Il Flag is_read_only

Una flag che si è rivelata utile è `is_read_only` sulla tabella dei tenants.

Quando un tenant è in read-only, tutte le richieste POST, PUT, PATCH e DELETE restituiscono HTTP 403.

Questo mi serve per:
- Bloccare un tenant per motivi di pagamento
- Fare manutenzione senza rischi di scrittura
- Prevenire modifiche durante investigazioni

Il middleware `EnsureTenantAccess` controlla questo flag e blocca le scritture automaticamente.
Niente logica sparsa nei controller, tutto centralizzato.

## Anti-Pattern che ho imparato ad evitare

- **Assegnazione manuale del tenant_id**: Se lo facessi prima o poi me ne dimenticherei (come è successo più di una volta). Qua tornano comodi i test ed il `BelongsToTenant`.
- **Unique index senza scope**: Tutti gli indici che creo sulle entità verranno quasi sempre verificati in combinazione con il `tenant_id`.
- **Usare gli ID incrementali**: Per i tenantId preferisco utilizzare gli **UUID**. Evita che qualcuno possa "tirare ad indovinare" l'id di un diverso cliente.

## Conclusione

Un SaaS multitenant creato con Laravel non è fondamentalmente una questione di codice, ma di "fiducia nel sistema che hai costruito" e "mancanza di fiducia nelle persone".
La soluzione a DB singolo è la più equilibrata per la maggior parte dei prodotti simili a questo. Questa soluzione offre la massima tranquillità grazie a GlobalScope Automation, oltre alla rapidità di sviluppo, rilascio e manutenzione che non si potrebbe ottenere con dei DB per tenant.

Per approfondire questo aspetto, se dovessi rifare tutto da zero, non modificherei la struttura base che ho stabilito, piuttosto mi concentrerei maggiormente sulla creazione di test estremi sin da subito.

Laravel offre un eccellente documentazione su come utilizzare GlobalScope, ma si possono utilizzare anche pacchetti come spatie/laravel-multitenancy per creare applicazioni multi-tenant.
L'aspetto più importante di questo post è testare con una propria implementazione, in modo da avere il massimo controllo sul codice e su come viene scritto (con i suoi drawback).

Per esempio l'utilizzo del super-admin non sarebbe stato di immediata implementazione con pacchetti esterni.
