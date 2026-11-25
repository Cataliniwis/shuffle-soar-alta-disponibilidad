#!/usr/bin/env bash
# Reglas de firewalld aplicadas en el nodo SOAR (Rocky Linux 9).
set -euo pipefail

# Línea base: qué está expuesto por defecto
firewall-cmd --list-all

# 1. Quitar servicios innecesarios (cockpit venía habilitado por defecto)
firewall-cmd --permanent --remove-service=cockpit

# 2. Abrir solo los puertos que necesita Shuffle (mínimo privilegio)
firewall-cmd --permanent --add-port=3001/tcp   # Interfaz web HTTP
firewall-cmd --permanent --add-port=3443/tcp   # Reservado para HTTPS

# 3. Mitigar CVE-1999-0524 (ICMP Timestamp Reply Information Disclosure)
firewall-cmd --permanent --add-rich-rule='rule icmp-type name="timestamp-request" drop'

# 4. Permitir VRRP (protocolo IP 112) para Keepalived
firewall-cmd --permanent --add-rich-rule='rule protocol value="vrrp" accept'

firewall-cmd --reload
firewall-cmd --list-all
