# Self-contained MySQL image that includes the seed data, so the same
# image works locally (compose.prod.yml) and on Azure Container Apps
# without needing a volume mount.
FROM mysql:9.6
COPY init/*.sql /docker-entrypoint-initdb.d/
