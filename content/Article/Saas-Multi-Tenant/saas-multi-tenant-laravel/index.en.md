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
series: ["Multi-Tenant SaaS Architecture"]
series_order: 1
sitemap:
  priority: 0.7
---
## The Project

I have just finished building a SaaS platform to help transport companies manage their services. This platform is a multi-tenant B2B system, meaning each customer company has its own space where it can manage its fleet, drivers, warehouses, and transports, without seeing the data and/or actions of other customers.

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

I created a `BelongsToTenant` trait that automates both reading and writing:

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

Every model representing a tenant entity (Customers, Vehicles, Transports, etc.) has this trait. This way, not only are queries filtered, but I don't even have to remember to assign the `tenant_id` when saving a new object.

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
- **Unique index without scope**: Almost all indices I create on entities will almost always be verified in combination with the `tenant_id`.
- **Using incremental IDs**: For tenantId, I prefer using **UUIDs**. It prevents someone from "guessing" the ID of a different customer.

## Conclusion

A multi-tenant SaaS built with Laravel is not fundamentally a matter of code, but of "trust in the system you've built" and "lack of trust in people."
The single DB solution is the most balanced for most products similar to this one. This solution offers maximum peace of mind thanks to GlobalScope Automation, along with the speed of development, release, and maintenance that could not be achieved with per-tenant databases.

To delve into this aspect, if I were to redo everything from scratch, I wouldn't change the basic structure I established; rather, I would focus more on creating extreme tests right from the start.

Laravel offers excellent documentation on how to use GlobalScope, but you can also use packages like spatie/laravel-multitenancy to create multi-tenant applications.
The most important aspect of this post is testing with your own implementation so you have maximum control over the code and how it's written (with its drawbacks).

For example, implementing the super-admin would not have been immediately possible with external packages.
