#!/usr/bin/env bash
# /etc/keepalived/check_shuffle.sh
# Health check que usa Keepalived: devuelve 0 si el frontend de Shuffle está corriendo.
# Si falla, Keepalived resta el "weight" a la prioridad del nodo.
docker ps --filter "name=shuffle-frontend" --filter "status=running" --format '{{.Names}}' \
  | grep -q "shuffle-frontend"
