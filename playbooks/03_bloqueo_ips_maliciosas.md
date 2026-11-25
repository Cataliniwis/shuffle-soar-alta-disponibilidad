# Playbook 3 · `Bloqueo_IPs_Maliciosas`

**Objetivo:** contener una IP maliciosa confirmada aplicando el bloqueo directamente en el firewall del nodo (firewalld), sin que el analista tenga que conectarse por SSH y escribir el comando.

## Flujo

```
Webhook (recibe {"ip": ...}) ──► Shuffle Tools · Run ssh command ──► rich rule en firewalld
```

## Configuración del nodo `Run ssh command`

| Campo | Valor |
|---|---|
| Host | `<IP_NODO_PRINCIPAL>` |
| Usuario / contraseña | Credenciales de servicio guardadas en Shuffle |
| Comando | ver abajo |

```bash
echo '<PASSWORD>' | sudo -S firewall-cmd --permanent \
  --add-rich-rule="rule family='ipv4' source address='$exec.ip' reject" \
  && echo '<PASSWORD>' | sudo -S firewall-cmd --reload
```

> 💡 **Mejora recomendada para producción:** reemplazar la autenticación por contraseña y `sudo -S` por una llave SSH dedicada y una regla de `sudoers` limitada a un script fijo de bloqueo, igual que en el esquema de sincronización del proyecto.

## Validación
- El panel **Debug** muestra `success: true`. El texto en `error_log` es solo el prompt de contraseña de `sudo` que capturó la salida de error, no un fallo.
- **Verificación independiente** en el nodo:

```bash
sudo firewall-cmd --list-rich-rules
# rule family="ipv4" source address="<IP_BLOQUEADA>" reject
```
