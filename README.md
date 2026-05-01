# Hives Legacy Archive

`hives` was the original infrastructure manager for running many isolated MemberHive instances. It used Ruby scripts, Docker, Plesk subdomain provisioning, per-client runtime directories, and backup/update/restart commands.

The legacy code is preserved at:

- tag: `legacy-ruby-plesk-final`
- branch: `master`

Active MemberHive tenancy work now lives inside the main MemberHive Laravel application:

- repository: `https://github.com/digitaldeacon/memberhive`
- branch: `rework/laravel-inertia-vue`

## Current Direction

The new MemberHive app should include both contexts in one Laravel application:

- landlord/admin context for tenant provisioning, domains, health checks, backups, billing, and support operations.
- tenant context for each church or organization CRM.

The modern reference for landlord patterns is the ESRA Bible landlord app, especially its tenant lifecycle, deploy targets, onboarding jobs, health checks, backup/restore jobs, and service operation tracking.

This repository remains useful as historical context for the original deployment goals, but it should not become the active landlord app again.
