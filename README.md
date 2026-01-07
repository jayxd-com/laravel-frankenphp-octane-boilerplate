# 🚀 Laravel 12 + Filament 4 + Octane (FrankenPHP) Ultimate Starter

A production-grade, high-performance infrastructure boilerplate. It bridges the gap between local development (Laravel Sail) and production worker-mode (FrankenPHP + Octane) for sub-10ms response times.

---

## 🏗 Project Architecture
- **Local Dev:** Laravel Sail (Dockerized PHP 8.4, PostgreSQL, Redis, Mailpit).
- **Production Engine:** FrankenPHP + Laravel Octane (Worker Mode).
- **Admin Panel:** Filament 4 (Pre-installed & Optimized).
- **Queue Management:** Laravel Horizon (Redis-backed).
- **Deployment:** Zero-downtime ready for Dokploy / Traefik.

---

## 🛠 Local Development Setup (Laravel Sail)

Ensure you have Docker installed on your machine.

### 1. Initial Installation
```bash
# Clone the repository
git clone https://github.com/jayxd-com/laravel-frankenphp-octane-boilerplate.git
cd laravel-frankenphp-octane-boilerplate

# Install dependencies
# (If you have PHP/Composer locally)
composer install

# (OR use the Sail shortcut if you don't have PHP installed)
docker run --rm -it -v $(pwd):/var/www/html -w /var/www/html laravelsail/php84-composer:latest composer install --ignore-platform-reqs
```
### 2. Environment Configuration
Copy the environment file. Custom **Sail Port Overrides** are included to prevent conflicts with other local projects:
```bash
cp .env.example .env
```

The following overrides are pre-set for Sail:
```env
APP_PORT=8100
APP_URL=http://localhost:8100
FORWARD_DB_PORT=3390
FORWARD_REDIS_PORT=6400
FORWARD_MAILPIT_PORT=1100
FORWARD_MAILPIT_DASHBOARD_PORT=7100
VITE_PORT=5100
```

### 3. Start the Environment
```bash
# Alias for ease of use
alias sail='[ -f sail ] && sh sail || php vendor/bin/sail'

sail up -d
sail artisan key:generate
sail artisan migrate
```

---

## 🚢 Production Infrastructure (Dokploy)



### 1. Production Environment Checklist
Set these in your Dokploy Dashboard. **Failure to set these correctly will break Filament links and SSL.**

- [ ] `APP_ENV=production`
- [ ] `APP_DEBUG=false`
- [ ] `APP_URL=https://your-domain.com` (Must be your live URL)
- [ ] `OCTANE_HTTPS=true` (Critical for SSL termination behind Traefik)
- [ ] `APP_KEY=...` (Generate with `php artisan key:generate --show`)
- [ ] `QUEUE_CONNECTION=redis`
- [ ] `SESSION_DRIVER=redis` (Required for worker state persistence)

### 2. Service Definitions
This stack uses a single image to run four specialized roles:
- **web:** Octane server running on Port 80 (Internal healthcheck at `/up`).
- **horizon:** Dashboard-managed queue worker.
- **worker:** Standard queue worker for heavy tasks.
- **scheduler:** Native cron replacement.

*Note: Horizon and Scheduler depend on the Web service being "Healthy" (Migrations finished) before starting.*

---

## ⚠️ Known Terminal Warnings
1. **"Multiple config files found"**: Docker sees `compose.yaml` (Sail) and `docker-compose.yml` (Prod). This is normal. To stop the warning, use: `alias dc='docker compose -f compose.yaml'`.
2. **"WWWUSER/WWWGROUP not set"**: Sail specific. Only matters for local dev. Add `WWWUSER=1000` to your `.env` to silence.

---

## 📁 Repository Structure
```text
.
├── docker/
│   ├── entrypoint.sh      # Automated Deployment Logic
│   └── php/
│       └── local.ini      # Optimized Opcache & Memory limits
├── .dockerignore          # Clean production builds
├── .gitignore
├── Dockerfile             # Multi-stage PHP 8.4 build
├── compose.yaml           # Local Sail Config
├── docker-compose.yml     # Production Dokploy Config
└── README.md
```

---

## ⚡ Deployment Checklist
1. **Dokploy:** Point your service to this repo and the `docker-compose.yml` file.
2. **Ports:** Set **Container Port** to `80`. Do NOT expose host ports; Traefik routes internally.
3. **Healthcheck:** The web service uses `curl -fLk http://localhost/up`. Ensure your `Dockerfile` has `curl` installed.

---

## 📝 Maintenance
To clear all caches and reset the worker state:
```bash
# Local
sail artisan optimize:clear

# Production
php artisan optimize:clear
```
