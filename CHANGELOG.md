# Changelog

All notable changes to the **Laravel 12 Ultra Starter** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-01-07

### Added
- **Laravel 12 & PHP 8.4 Support**: Initial core setup.
- **FrankenPHP & Octane**: Integrated worker-mode for sub-10ms response times.
- **Filament 4**: Pre-installed and optimized for production caching.
- **Multi-Service Docker Stack**: Added dedicated containers for `web`, `horizon`, `worker`, and `scheduler`.
- **Laravel Sail**: Seamless local development environment with PGSQL, Redis, and Mailpit.
- **Healthchecks**: Integrated `/up` endpoint checks for zero-downtime deployments.
- **Auto-Optimizations**: Added `filament:optimize` and `key:generate` logic to `entrypoint.sh`.

### Changed
- **Compose Strategy**: Split configuration into `compose.yaml` (Local) and `docker-compose.yml` (Production) to avoid conflict.
- **Volumes**: Refined volume mapping to persist only `uploads` and `logs`, keeping framework caches fresh.

### Fixed
- **Terminal Warnings**: Added `.env` defaults for `WWWUSER` and `WWWGROUP` to silence Docker warnings.
- **Healthcheck Redirects**: Updated `curl` flags to `-fLk` to handle SSL redirects behind Traefik.

---

## [Unreleased]
- *Place upcoming features here (e.g., Socialite integration, S3 storage drivers).*
