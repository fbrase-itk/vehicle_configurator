# syntax=docker/dockerfile:1.7

# Stage 1: install dependencies (shared by dev and build)
FROM node:22-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install

# Stage 2: development server (used by docker/compose.yml)
FROM deps AS dev
EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# Stage 3: production build (static assets in /app/dist)
FROM deps AS build
COPY . .
RUN npm run build

# Stage 4: production runtime (used by docker/compose.prod.yml and ghcr.io image)
FROM nginx:1.27-alpine AS prod
COPY --from=build /app/dist /usr/share/nginx/html
RUN cat > /etc/nginx/conf.d/default.conf <<'NGINX'
server {
  listen 80;
  server_name _;

  root /usr/share/nginx/html;
  index index.html;

  # SPA: unknown routes fall back to index.html so Vue Router can handle them.
  location / {
    try_files $uri $uri/ /index.html;
  }

  # Proxy API calls to the backend container (Docker Compose DNS).
  # Override at deploy time by replacing this file if the backend lives elsewhere.
  location /api/ {
    proxy_pass http://backend:8080;
    proxy_http_version 1.1;
    proxy_set_header Host              $host;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
NGINX
EXPOSE 80
