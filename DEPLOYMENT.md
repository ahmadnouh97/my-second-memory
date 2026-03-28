# Deployment Guide — Second Memory on Coolify

**Domains:**
- API → `https://memo-api.nouhlab.com`
- Web → `https://memo.nouhlab.com`

**Prerequisites:** Coolify is already installed on your VPS.

---

## Phase 0 — DNS

Add two A records at your domain registrar (wherever `nouhlab.com` is managed):

| Name | Type | Value |
|------|------|-------|
| `memo-api` | A | `<your-vps-ip>` |
| `memo` | A | `<your-vps-ip>` |

Propagation is usually under 5 minutes with a short TTL. Verify with:
```bash
nslookup memo-api.nouhlab.com
nslookup memo.nouhlab.com
```

---

## Phase 1 — Deploy the Backend (Docker Compose)

### 1.1 Create the resource in Coolify

1. Coolify dashboard → **New Resource** → **Docker Compose**
2. Source → **Public GitHub repository** → paste your repo URL
3. Branch: `main`
4. **Compose file path**: `docker-compose.yml`

### 1.2 Configure the domain

Coolify's built-in Traefik proxy does **not** handle routing for this app. Instead, Nginx runs directly on the VPS as the reverse proxy (see Phase 1.6).

### 1.3 Set environment variables

In the resource → **Environment Variables** tab, add:

| Key | Value |
|-----|-------|
| `POSTGRES_DB` | `secondmemory` |
| `POSTGRES_USER` | `postgres` |
| `POSTGRES_PASSWORD` | *(strong password)* |
| `GROQ_API_KEY` | *(your key)* |
| `GOOGLE_API_KEY` | *(your key)* |
| `APP_ENV` | `production` |
| `CORS_ORIGINS` | `https://memo.nouhlab.com` |

> Do **not** add `DATABASE_URL` — it is constructed from the other DB vars inside `docker-compose.yml`.

### 1.4 Deploy

Click **Deploy**. Watch the build logs until you see uvicorn start.

### 1.5 Run database migrations (first deploy only)

SSH into the VPS:

```bash
docker exec $(docker ps --format '{{.Names}}' | grep backend) alembic upgrade head
```

### 1.6 Configure Nginx reverse proxy (first deploy only)

Nginx runs on the VPS host and proxies HTTPS traffic to the backend container.

**Create the site config:**

```bash
sudo vim /etc/nginx/sites-available/memo-api
```

```nginx
server {
    listen 80;
    server_name memo-api.nouhlab.com;

    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Enable it:**

```bash
sudo ln -s /etc/nginx/sites-available/memo-api /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

**Obtain a Let's Encrypt certificate:**

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d memo-api.nouhlab.com
```

Certbot updates the Nginx config to serve HTTPS on port 443 and auto-renews the certificate.

**Cloudflare SSL/TLS setting:** set to **Full (Strict)**.

---

## Phase 2 — Deploy the Flutter Web App (Dockerfile)

### 2.1 Create the resource in Coolify

1. **New Resource** → **Dockerfile**
2. Same GitHub repo, branch `main`
3. **Dockerfile path**: `frontend/Dockerfile.web`
4. **Build context**: `.` (dot — Coolify sets this to the repo root; the Dockerfile uses `frontend/` prefixes on all COPY paths accordingly)
5. **Build arguments**:
   ```
   BACKEND_URL=https://memo-api.nouhlab.com
   ```

### 2.2 Configure the port mapping

Do **not** assign a domain or enable Let's Encrypt in Coolify for this resource — Nginx on the host handles that (see 2.3).

In the resource → **Ports** (or **Network**) tab, map the container port to a free host port:

| Host port | Container port |
|-----------|----------------|
| `3000` | `80` |

This exposes the Flutter nginx container at `http://127.0.0.1:3000` on the VPS, which the host Nginx will proxy.

### 2.3 Configure Nginx reverse proxy (first deploy only)

```bash
sudo vim /etc/nginx/sites-available/memo
```

```nginx
server {
    listen 80;
    server_name memo.nouhlab.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/memo /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d memo.nouhlab.com
```

**Cloudflare SSL/TLS setting:** set to **Full (Strict)**.

### 2.4 Deploy

Click **Deploy**. The build takes a few minutes (Flutter SDK download is cached after the first run).

---

## Phase 3 — Auto-deploy via GitHub Webhook

Coolify generates a unique webhook URL per resource. Repeat for **both** the backend and web resources:

1. In Coolify → resource → **Webhook** tab → copy the URL
2. In GitHub → repo **Settings** → **Webhooks** → **Add webhook**
   - Payload URL: paste Coolify webhook URL
   - Content type: `application/json`
   - Secret: leave blank (Coolify validates its own token)
   - Events: **Just the push event**
3. Save

Every push to `main` now triggers a redeploy of both services. You can still click **Redeploy** in the Coolify UI at any time.

---

## Phase 4 — Build Android APK

Run locally after the backend is live:

```bash
cd frontend
flutter build apk --release \
  --dart-define=BACKEND_URL=https://memo-api.nouhlab.com
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Install directly:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Verification Checklist

- [ ] `https://memo-api.nouhlab.com/health` → `{"status": "ok"}`
- [ ] `https://memo-api.nouhlab.com/docs` → FastAPI Swagger UI loads
- [ ] `https://memo.nouhlab.com` → Flutter web app loads
- [ ] Save a URL in the web app — item appears with AI-generated title/tags
- [ ] Chat page returns streamed responses and renders item cards
- [ ] Android APK connects and saves items
- [ ] Push a dummy commit to `main` → both Coolify services redeploy automatically

---

## Ongoing Operations

### View backend logs
Coolify → backend resource → **Logs** tab, or on the VPS:
```bash
docker logs -f <backend-container-name>
```

### Apply a new database migration
```bash
# After merging a migration file to main and redeploying:
docker exec $(docker ps --format '{{.Names}}' | grep backend) alembic upgrade head
```

### Update secrets
Edit them in Coolify → resource → **Environment Variables** → **Redeploy**.
Never commit secrets to the repo.

### Renew SSL certificate
Certbot auto-renews. To manually force a renewal:
```bash
sudo certbot renew
```

### Reload Nginx after config changes
```bash
sudo nginx -t && sudo systemctl reload nginx
```

### Backup the database
```bash
docker exec <db-container> pg_dump -U postgres secondmemory > backup.sql
```
