## Development Environment

### One-command bootstrap

```bash
cd docker
docker compose up --build
```

- <http://localhost:5173/> — Vue app (Vite dev server, hot reload)
- <http://localhost:8080/api/> — Spring Boot REST surface
- <http://localhost:3306>     — MySQL (credentials in `docker/env/database.env`)
- <http://localhost:8000/>    — Structurizr Lite (this documentation)

The frontend container bind-mounts `frontend/` with `/app/node_modules`
kept inside an anonymous volume, so edits on the host hot-reload in the
browser while the container's installed modules remain intact.

### Typical edit loops

| You edited… | What happens |
|-------------|--------------|
| `frontend/src/**` | Vite HMR reloads the browser within ~100 ms. |
| `backend/src/**` | Rebuild: `docker compose up --build backend`. |
| `database/init/*.sql` | Only re-applied to a fresh DB. `docker compose down -v` drops the volume, next `up` re-seeds. |
| `docs/structurizr/workspace.dsl` | Structurizr Lite auto-reloads on save. |
| `docs/arc42/**` | Plain Markdown — render in Cursor/GitHub. |

### Ports summary

| Service | Dev port | Azure port | Ingress |
|---------|----------|------------|---------|
| frontend | 5173 | 80 | external (prod), local (dev) |
| backend | 8080 | 8080 | internal on Azure; exposed locally for curl/debug |
| database | 3306 | 3306 | internal on Azure; exposed locally for DB tooling |
| structurizr (docs) | 8000 | — | local only |

### Useful one-liners

```bash
# Full rebuild + fresh DB
cd docker && docker compose down -v && docker compose up --build

# Tail all logs
cd docker && docker compose logs -f

# Run the same integration smoke test CI runs (adapted)
cd docker && docker compose up -d database backend
curl -fs http://localhost:8080/api/options | jq '.carModels | length'
```
