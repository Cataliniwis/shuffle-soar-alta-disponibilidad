#!/usr/bin/env bash
# /usr/local/bin/shuffle_sync_apply.sh — se ejecuta en la RÉPLICA (vía sudo restringido).
# sudoers:  usuario ALL=(root) NOPASSWD: /usr/local/bin/shuffle_sync_apply.sh
#
# Requisito: SHUFFLE_ENCRYPTION_MODIFIER del archivo .env debe ser idéntico en ambos nodos;
# si no, las credenciales replicadas no se pueden descifrar después de un failover.
set -euo pipefail

SHUFFLE_DIR="/home/usuario/shuffle"
STAGING="/home/usuario/shuffle_staging"
DB_VOL="/var/lib/docker/volumes/shuffle_shuffledatabase/_data"

cd "${SHUFFLE_DIR}"

# 1. Detener el stack para no copiar OpenSearch en un estado inconsistente
docker compose stop

# 2. Aplicar los datos sobre las rutas definitivas
rsync -a --delete "${STAGING}/shuffle-apps/"     "${SHUFFLE_DIR}/shuffle-apps/"
rsync -a --delete "${STAGING}/shuffle-files/"    "${SHUFFLE_DIR}/shuffle-files/"
rsync -a --delete "${STAGING}/shuffle-database/" "${DB_VOL}/"

# 3. Corregir la propiedad de los archivos (OpenSearch corre con UID 1000 en su contenedor)
chown -R 1000:1000 "${DB_VOL}"

# 4. Levantar nuevamente el stack (la réplica está en standby: el corte es de segundos)
docker compose up -d
