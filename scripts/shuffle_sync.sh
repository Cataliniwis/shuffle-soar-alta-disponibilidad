#!/usr/bin/env bash
# Sincroniza los datos de Shuffle del NODO PRINCIPAL hacia la RÉPLICA.
# Se ejecuta desde el crontab de root en el nodo principal:
#   */15 * * * * /usr/local/bin/shuffle_sync.sh >> /var/log/shuffle_sync.log 2>&1
#
# Diseño de mínimo privilegio:
#  - Llave SSH dedicada, autorizada solo contra un usuario NO privilegiado de la réplica.
#  - En la réplica ese usuario tiene sudo sin contraseña SOLO para shuffle_sync_apply.sh.
#  - No se habilita login SSH como root ni autenticación por contraseña.
set -euo pipefail

REPLICA="usuario@10.0.100.11"
KEY="/root/.ssh/id_ed25519_shuffle_sync"
STAGING="/home/usuario/shuffle_staging"
SSH="ssh -i ${KEY} -o BatchMode=yes"

echo "[$(date '+%F %T')] Inicio de sincronización"

rsync -az --delete -e "${SSH}" /home/usuario/shuffle/shuffle-apps/  "${REPLICA}:${STAGING}/shuffle-apps/"
rsync -az --delete -e "${SSH}" /home/usuario/shuffle/shuffle-files/ "${REPLICA}:${STAGING}/shuffle-files/"
rsync -az --delete -e "${SSH}" /var/lib/docker/volumes/shuffle_shuffledatabase/_data/ \
      "${REPLICA}:${STAGING}/shuffle-database/"

# Aplica la sincronización en la réplica (detiene el stack, copia y lo vuelve a levantar)
${SSH} "${REPLICA}" "sudo /usr/local/bin/shuffle_sync_apply.sh"

echo "[$(date '+%F %T')] Sincronización finalizada"
