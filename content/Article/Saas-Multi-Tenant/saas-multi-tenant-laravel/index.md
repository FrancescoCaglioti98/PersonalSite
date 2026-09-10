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
sitemap:
  priority: 0.7
---
## Il Progetto

Ho creato una piattaforma SaaS per aiutare le aziende di trasporti a gestire i loro servizi. È un progetto personale, nato per noia e cresciuto in un tentativo di prodotto che non è mai diventato tale: la scheda sintetica sta nella [pagina progetti](/projects/). Questa piattaforma è un sistema B2B multi-tenant, cioè ogni azienda cliente ha il proprio spazio dove può gestire la sua flotta, i suoi autisti, i magazzini ed i trasporti, senza vedere dati e/o azioni degli altri clienti.

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

Lo scope vive in una classe sua, e un trait `BelongsToTenant` lo attacca al model automatizzando sia la lettura che la scrittura. Il `qualifyColumn` serve perché appena ci sono delle join il `tenant_id` va qualificato con la tabella, altrimenti la query diventa ambigua:

```php
final class TenantScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        $context = app(TenantContext::class);

        if ($context->isSet()) {
            $builder->where($model->qualifyColumn('tenant_id'), $context->id());
        }
    }
}
```

```php
trait BelongsToTenant
{
    public static function bootBelongsToTenant(): void
    {
        static::addGlobalScope(new TenantScope());

        static::creating(function (self $model): void {
            if (! $model->getAttribute('tenant_id')) {
                $context = app(TenantContext::class);

                if ($context->isSet()) {
                    $model->setAttribute('tenant_id', $context->id());
                }
            }
        });
    }
}
```

Ogni model che rappresenta un'entità del tenant (Clienti, Veicoli, Trasporti, ecc.) ha questo trait. In questo modo, non solo le query sono filtrate, ma non devo nemmeno ricordarmi di assegnare il `tenant_id` quando salvo un nuovo oggetto.

## Il punto debole: quando il context è vuoto

Rileggendo quel codice c'è una cosa che salta all'occhio, e ci ho messo un po' a vederla: se il context non è popolato, `isSet()` restituisce `false` e la clausola `where` non viene mai aggiunta. La query non fallisce. Gira senza filtro e vede i dati di tutti i tenant.

Non è un caso di scuola. Fuori dal ciclo richiesta-HTTP il context vuoto è il default, perché non c'è nessun middleware che lo popoli: comandi Artisan, job in coda, seeder, scheduler, tinker.

E lo stesso `isSet()` governa anche la scrittura. Se il context manca, `creating` non assegna niente e la riga finisce a database con `tenant_id` nullo, che è un modo silenzioso di creare dati che non appartengono a nessuno.

Vale la pena dire come sta la faccenda nel mio caso, invece di far finta di averla risolta. Oggi non mi morde, ma non per bravura: non ho comandi Artisan e non ho job. L'unica cosa che finisce davvero in coda è una Mailable con `ShouldQueue` che serializza il tenant e l'utente, e il model `User` non usa `BelongsToTenant`. Regge per costruzione, non per fortuna. La differenza però conta, perché il giorno che aggiungo un job che tocca i trasporti il comportamento predefinito è "vedo tutto".

Le strade che ho valutato, con i loro compromessi:

- **Lanciare un'eccezione quando il context manca.** È la più sicura e la più scomoda: ogni pezzo di codice fuori dall'HTTP deve dichiarare per chi sta lavorando, seeder e test compresi. Rompe subito e rumorosamente, che è esattamente quello che voglio da un filtro di sicurezza.
- **Distinguere il contesto di esecuzione.** Eccezione quando la richiesta arriva dal web, tolleranza quando si gira da CLI. Sembra pragmatico ma sposta la sicurezza su una condizione ambientale, e un job in coda è CLI a tutti gli effetti: darei via libera proprio dove il filtro mi serve.
- **Richiedere un opt-out dichiarato.** Il filtro resta sempre attivo e chi ha davvero bisogno di leggere tutto lo scrive: `Transport::withoutTenantScope()`. Il vantaggio è che l'accesso globale diventa una cosa che si trova con un `grep`.

Quella che prenderei è la terza con la prima come rete: scope sempre attivo, eccezione se il context manca, e un opt-out esplicito e cercabile per i casi legittimi. Non l'ho ancora fatta perché finché non ho job in coda il rischio resta potenziale, e preferisco scriverlo qui piuttosto che raccontare di averlo sistemato.

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
- **Unique index senza scope**: Tutti gli indici che creo sulle entità verranno quasi sempre verificati in combinazione con il `tenant_id`. Due aziende diverse possono avere un veicolo con la stessa targa, quindi il vincolo va sulla coppia, non sulla colonna:

```php
Schema::create('vehicles', function (Blueprint $table) {
    $table->unique(['tenant_id', 'plate']);
});
```

  L'eccezione voluta nel mio schema è `users.email`, che resta unica a livello globale: l'autenticazione deve trovare l'utente prima che un context esista, quindi lì un vincolo per tenant non avrebbe senso.
- **Usare gli ID incrementali**: Per i tenantId preferisco utilizzare gli **UUID**. Evita che qualcuno possa "tirare ad indovinare" l'id di un diverso cliente.

## Conclusione

Cosa terrei: il database condiviso, il global scope automatico e gli UUID come identificatori. Il database unico si è ripagato in manutenzione e in costi, e il global scope mi ha risparmiato in blocco la classe di bug in cui ti dimentichi un `where`.

Cosa rifarei: i test di isolamento dal primo giorno, non dopo. Li ho scritti quando la struttura era già in piedi, e li ho scritti perché non mi fidavo di quello che avevo costruito. Se li avessi avuti prima, il buco del context vuoto lo avrei visto subito, invece di trovarlo rileggendo il mio stesso codice per scrivere questo articolo.

La regola che mi porto via: in un multi-tenant l'unico test che conta non verifica che la feature funzioni. Verifica che il cliente A non veda il cliente B. Quello lo scrivi per primo.
