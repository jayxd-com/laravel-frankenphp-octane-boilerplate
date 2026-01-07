# 🚀 Laravel 12 + Filament 4 + Octane (FrankenPHP) Ultimate Starter

This is a comprehensive, production-ready boilerplate. It provides a seamless transition from a local development environment (via **Laravel Sail**) to a high-performance production stack (via **FrankenPHP Worker Mode**, **Redis**, and **Dokploy**).

---

## 🏗 Project Architecture
- **Local Dev:** Laravel Sail (Dockerized PHP 8.4, PostgreSQL, Redis, Mailpit).
- **Production Engine:** FrankenPHP + Laravel Octane (Worker Mode).
- **Admin Panel:** Filament 4 (Pre-installed & Optimized).
- **Queue Management:** Laravel Horizon (Redis-backed).
- **Deployment:** Zero-downtime ready for Dokploy / Traefik.

---

## 🛠 Local Development Setup

This project uses **Laravel Sail**. Ensure you have Docker installed.

### 1. Initial Installation
```bash
# Clone the repository
git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
cd your-repo-name

# Install dependencies via a temporary container
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):/var/www/html" \
    -w /var/www/html \
    laravelsail/php84-composer:latest \
    composer install --ignore-platform-reqs
```

### 2. Environment Configuration
Copy the environment file and note the custom **Sail Port Overrides** to avoid conflicts with other local projects:
```bash
cp .env.example .env
```

The following overrides are included in the `.env` for Sail:
```env
# SAIL PORT CONFIGURATION
APP_PORT=8100
FORWARD_DB_PORT=3390
FORWARD_REDIS_PORT=6400
FORWARD_MAILPIT_PORT=1100
FORWARD_MAILPIT_DASHBOARD_PORT=7100
VITE_PORT=5100
```

### 3. Start the Environment
Set up an alias for ease of use (optional but recommended):
`alias sail='[ -f sail ] && sh sail || php vendor/bin/sail'`

```bash
sail up -d
sail artisan migrate
sail artisan key:generate
```

### ⚠️ Note on Terminal Warnings
When running `docker compose` directly in the root, you may see:
1. **"Multiple config files found"**: This is normal. The project includes `compose.yaml` for local Sail development and `docker-compose.yml` for production. Docker will default to the local version.
2. **"WWWUSER variable not set"**: This is a Sail-specific warning. It does not affect production. Locally, Sail handles this automatically when using the `./vendor/bin/sail` command.
---

## 🚢 Production Infrastructure (Dokploy)

The production stack uses a dedicated multi-service architecture defined in `docker-compose.yml`.

### 1. Critical Production .env
Ensure these are set in your PaaS/Dokploy dashboard:
```env
OCTANE_SERVER=frankenphp
OCTANE_HTTPS=true         # Critical for SSL termination
QUEUE_CONNECTION=redis    # Required for Horizon
SESSION_DRIVER=redis      
CACHE_STORE=redis         
```

### 2. Service Definition
This boilerplate spins up four specialized containers from a single image:
- **web:** Octane server running on Port 80 (Admin Port 2019).
- **horizon:** Real-time queue monitoring.
- **worker:** Dedicated heavy-task queue processor.
- **scheduler:** Native cron replacement.

---

## 📁 Repository Structure
The following files manage the production and local runtime:
- `docker/entrypoint.sh` - Automated deployment (Migrations, Storage, Filament Caching).
- `docker/php/local.ini` - Custom PHP production configurations.
- `Dockerfile` - Multi-stage build for PHP 8.4.
- `docker-compose.yml` - Production stack definition.

---

## ⚡ Deployment Checklist
1. **Dokploy:** Create a new service and point to this repo.
2. **Ports:** Set the **Container Port** to `80`. Do NOT expose host ports manually; Dokploy's Traefik handles this.
3. **Optimizations:** The `entrypoint.sh` automatically runs `php artisan filament:optimize` to ensure the admin panel is blazing fast in worker mode.

---

## 📝 Maintenance
To clear all caches and reset the worker state:
```bash
sail artisan optimize:clear
# Or in production
php artisan optimize:clear
```
