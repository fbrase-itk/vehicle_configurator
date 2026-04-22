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
FROM nginx:1.29-alpine AS prod
COPY --from=build /app/dist /usr/share/nginx/html

# Remove the config that ships with the nginx image so our template wins.
RUN rm -f /etc/nginx/conf.d/default.conf && mkdir -p /etc/nginx/templates

# Template: ${BACKEND_UPSTREAM} is substituted at container start by the
# nginx image's entrypoint (envsubst). NGINX_ENVSUBST_FILTER below
# restricts substitution to just this one variable, so nginx's own
# built-in variables like $host and $remote_addr are preserved.
RUN cat > /etc/nginx/templates/default.conf.template <<'NGINX'
server {
  listen 80;
  server_name _;

  root /usr/share/nginx/html;
  index index.html;

  # SPA: unknown routes fall back to index.html so Vue Router can handle them.
  location / {
    try_files $uri $uri/ /index.html;
  }

  # Proxy API calls to the backend. The upstream host:port is injected
  # at runtime so the same image works locally (backend:8080, container
  # listens directly) and on Azure Container Apps (the full internal
  # FQDN of the backend app, routed through the env's ingress on :80).
  #
  # IMPORTANT: Use $proxy_host (= the upstream host from proxy_pass) as
  # the Host header, NOT $host (= the browser's Host header). ACA's
  # internal ingress routes by Host, so sending the frontend's public
  # FQDN as Host makes ACA return 404 "App Unavailable" and the backend
  # never wakes up. With $proxy_host the Host matches the backend app's
  # FQDN and the scaler correctly cold-starts the backend replica.
  location /api/ {
    proxy_pass http://${BACKEND_UPSTREAM};
    proxy_http_version 1.1;
    proxy_set_header Host              $proxy_host;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 90s;
  }
}
NGINX

ENV NGINX_ENVSUBST_FILTER=BACKEND_UPSTREAM \
    BACKEND_UPSTREAM=backend:8080

EXPOSE 80
