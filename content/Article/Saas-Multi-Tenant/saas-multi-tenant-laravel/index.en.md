---
title: "Multi-Tenant with Laravel: Data Isolation and Global Scope"
date: 2026-05-11
description: "How I built a multi-tenant B2B SaaS with automatic data isolation"
draft: false
categories: ["saas", "laravel", "backend"]
tags: ["multi-tenant", "laravel", "eloquent", "postgresql", "saas"]
keywords: ["laravel multi-tenant", "saas data isolation", "global scope eloquent", "tenant isolation"]
showAuthorBottom: true
showHero: true
sitemap:
  priority: 0.7
---
## The Project

I built a SaaS platform to help transport companies manage their services. It is a personal project, started out of boredom and grown into an attempt at a product that never became one: the short version lives on my [projects page](/en/projects/). This platform is a multi-tenant B2B system, meaning each customer company has its own space where it can manage its fleet, drivers, warehouses, and transports, without seeing the data and/or actions of other customers.

When I started designing the platform, I didn't know whether to use different databases for each customer or create a single shared one.

Ultimately, I decided to share a single database among all customers for two main reasons: ease of maintenance and cost savings once in production.

However, I had to learn how to divide, isolate, and manage customer data in watertight compartments.

In this article, I share how I implemented this isolation with Laravel, without using external packages, what mistakes I made, and what I would do differently if I had to rewrite such a system from scratch.

## Logical Flow

Here is how data is isolated from the moment of the request until the database response:

```text
USER REQUEST
     │
     ▼
MIDDLEWARE (The Gatekeeper) ────────┐
     │                              │
     │ 1. Verify Authentication     │ 403 UNAUTHORIZED
     │ 2. Extract Tenant ID         │ (If no access)
     │                              └───────────────────► [ EXIT ]
     ▼
TENANT CONTEXT (Source of Truth)
     │
     │ 3. Store ID in Singleton Instance
     │
     ▼
ELOQUENT MODELS (The Workers)
     │
     │ 4. Boot BelongsToTenant Trait
     │ 5. Apply GlobalScope Automatically
     │
     ▼
DATABASE QUERY
     │
     │ SELECT * FROM table WHERE tenant_id = [X]
     │
     ▼
ISOLATED DATA RESPONSE (Success!)
```

## Shared Database: Why this choice?

The decision to use a shared database (Single-Database Multi-tenancy) was not just driven by cost. In a B2B system, the ease of database evolution is critical.

*   **Advantage:** Migrations are atomic. If I add a column to `transports`, I do it only once for all customers.
*   **Disadvantage:** The "Noisy Neighbor" risk (one tenant saturating resources) is real, and isolation is logical, not physical.

If I had opted for separate databases, I would have had perfect hardware isolation, but managing 500 different migrations (if I ever reach that many tenants) every time I release a feature would have become a full-time job.

## Testing Isolation (Seriously)

The most important part is, and always will be, writing tests for every new endpoint or function.

For example, am I creating an API endpoint to return monthly performance metrics? I add a specific test (beyond happy paths and edge cases) to verify that metrics for TenantA are not visible to TenantB.

It's not just because I don't trust my own work, but primarily to ensure that in the future I don't make some development that breaks this compartmentalization; I don't trust my future self to remember everything or not make mistakes.

This is an example in PhpUnit where I test an endpoint:

```php
public function test_cross_tenant_isolation(): void
{
    $tenantA = Tenant::factory()->create();
    $tenantB = Tenant::factory()->create();

    Product::factory()->for($tenantA)->create(['name' => 'Item A']);
    Product::factory()->for($tenantB)->create(['name' => 'Item B']);

    $response = $this->actingAs($this->userInTenant($tenantA))
        ->getJson('/api/v1/products');

    $response->assertOk();
    $response->assertJsonCount(1, 'data');
    $response->assertJsonPath('data.0.name', 'Item A');
}
```

Without a test like this, I'm just "hoping" the GlobalScope is applied globally.

## GlobalScope and TenantContext

Speaking of GlobalScope, it's a Laravel feature that allows you to automatically apply one or more `where` clauses to all queries assigned to a model. For our purpose, it's a godsend.

Now a key question remains: what will be my source of truth regarding the tenant ID to apply to the query?

I decided to create a TenantContext class, a singleton object that maintains the tenant's state for the entire duration of the request. It will be my source of truth.
The context is applied to all incoming requests via a specific Middleware. This makes the system testable and independent of the authentication driver (web, API, or CLI).

The scope lives in a class of its own, and a `BelongsToTenant` trait attaches it to the model, automating both reading and writing. The `qualifyColumn` matters because as soon as there are joins the `tenant_id` has to be qualified with its table, or the query becomes ambiguous:

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

Every model representing a tenant entity (Customers, Vehicles, Transports, etc.) has this trait. This way, not only are queries filtered, but I don't even have to remember to assign the `tenant_id` when saving a new object.

## The weak spot: when the context is empty

Re-reading that code, one thing stands out, and it took me a while to see it: if the context is not populated, `isSet()` returns `false` and the `where` clause is never added. The query does not fail. It runs unfiltered and sees every tenant's data.

This is not a textbook case. Outside the HTTP request cycle an empty context is the default, because there is no middleware to populate it: Artisan commands, queued jobs, seeders, the scheduler, tinker.

And the same `isSet()` governs writing too. If the context is missing, `creating` assigns nothing and the row lands in the database with a null `tenant_id`, which is a quiet way of creating data that belongs to nobody.

It's worth saying where this actually stands in my case, rather than pretending I have solved it. Today it doesn't bite me, but not because I was clever: I have no Artisan commands and no jobs. The only thing that genuinely ends up on a queue is a Mailable with `ShouldQueue` that serialises the tenant and the user, and the `User` model does not use `BelongsToTenant`. It holds by construction, not by luck. The difference matters, because the day I add a job that touches transports, the default behaviour is "see everything".

The options I weighed, with their trade-offs:

- **Throw an exception when the context is missing.** The safest and the most inconvenient: every piece of code outside HTTP has to declare who it is working for, seeders and tests included. It breaks immediately and loudly, which is exactly what I want from a security filter.
- **Distinguish the execution context.** Throw when the request comes from the web, tolerate it when running from the CLI. It sounds pragmatic, but it moves security onto an environmental condition, and a queued job is CLI for all practical purposes: I would be waving through precisely the case where I need the filter.
- **Require a declared opt-out.** The filter always stays on, and whoever genuinely needs to read everything writes it down: `Transport::withoutTenantScope()`. The upside is that global access becomes something you can find with a `grep`.

The one I would take is the third with the first as a safety net: scope always on, an exception when the context is missing, and an explicit, greppable opt-out for the legitimate cases. I haven't done it yet because as long as I have no queued jobs the risk stays potential, and I would rather write that here than claim I fixed it.

## The EnsureTenantAccess Middleware

The middleware is the "bridge" that populates our `TenantContext` at the beginning of each request.

```php
public function handle($request, Closure $next)
{
    $user = $request->user();

    if (!$user || (!$user->tenant_id && !$user->isSuperAdmin())) {
        abort(403, 'No tenant associated');
    }

    $tenantId = $user->isSuperAdmin() 
        ? session('impersonate_tenant_id') 
        : $user->tenant_id;

    if ($tenantId) {
        app(TenantContext::class)->set($tenantId);
        
        $tenant = Tenant::find($tenantId);
        if ($tenant->is_read_only && $request->isMethodSafe() === false) {
            abort(403, 'Account in read-only mode');
        }
    }

    return $next($request);
}
```

This middleware is applied to all routes operating with a tenant's data. Once passed, the currently logged-in user is "locked" into that tenant's context and the GlobalScope knows how to act.

## The Super Admin Case and Impersonation

A B2B system cannot function without a support service.
The `super_admin` must be able to "enter" a customer's account to diagnose problems, without their data mixing with the customer's.

The solution I adopted is **impersonation**:
- The Super Admin does not have a fixed `tenant_id`.
- Via an administration dashboard, they choose which Tenant (Customer) to assist/verify.
- We save the tenant ID in the session (`impersonate_tenant_id`).
- The middleware reads from the session and "pretends" the Super Admin belongs to that tenant for the duration of the navigation.

In support cases, this allows us to have the exact same views as a customer.

## The is_read_only Flag

A flag that proved useful is `is_read_only` on the tenants table.

When a tenant is in read-only mode, all POST, PUT, PATCH, and DELETE requests return HTTP 403.

This serves me for:
- Blocking a tenant for payment reasons
- Performing maintenance without write risks
- Preventing changes during investigations

The `EnsureTenantAccess` middleware checks this flag and blocks writes automatically.
No logic scattered in controllers, everything is centralized.

## Anti-Patterns I've Learned to Avoid

- **Manual tenant_id assignment**: If I did it manually, I'd eventually forget (as happened more than once). This is where tests and `BelongsToTenant` come in handy.
- **Unique index without scope**: Almost all indices I create on entities will almost always be verified in combination with the `tenant_id`. Two different companies can have a vehicle with the same plate, so the constraint belongs on the pair, not on the column:

```php
Schema::create('vehicles', function (Blueprint $table) {
    $table->unique(['tenant_id', 'plate']);
});
```

  The deliberate exception in my schema is `users.email`, which stays globally unique: authentication has to find the user before any context exists, so a per-tenant constraint there would make no sense.
- **Using incremental IDs**: For tenantId, I prefer using **UUIDs**. It prevents someone from "guessing" the ID of a different customer.

## Conclusion

What I would keep: the shared database, the automatic global scope and UUIDs as identifiers. The single database paid for itself in maintenance and in cost, and the global scope wiped out the whole class of bugs where you forget a `where`.

What I would do differently: isolation tests from day one, not later. I wrote them once the structure was already standing, and I wrote them because I did not trust what I had built. If I'd had them earlier I would have spotted the empty-context hole straight away, instead of finding it while re-reading my own code to write this article.

The rule I'm taking away: in a multi-tenant system the only test that counts does not check that the feature works. It checks that customer A cannot see customer B. That's the one you write first.
