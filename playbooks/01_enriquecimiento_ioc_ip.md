# Playbook 1 · `Enriquecimiento_IoC_IP`

**Objetivo:** consultar en forma automática la reputación de una IP sospechosa en **AbuseIPDB**, para que el analista no tenga que hacerlo a mano en el navegador cada vez que aparece un IoC.

## Flujo

```
Webhook (recibe {"ip": ...}) ──► Http GET a AbuseIPDB ──► resultado de reputación
```

## Configuración del nodo Http

| Campo | Valor |
|---|---|
| Método | `GET` |
| URL | `https://api.abuseipdb.com/api/v2/check?ipAddress=$exec.ip&maxAgeInDays=90` |
| Encabezados | `Key: <API_KEY_ABUSEIPDB>` · `Accept: application/json` |

> La clave de API se guarda como credencial en Shuffle. Nunca va en el workflow ni en el repositorio.

## Prueba

```bash
curl -X POST "http://<IP_SHUFFLE>:3001/api/v1/hooks/<WEBHOOK_ID>" \
     -H "Content-Type: application/json" \
     -d '{"ip": "<IP_A_CONSULTAR>"}'
```

## Validación
- El panel **Debug** muestra la respuesta `200` de AbuseIPDB con los datos de reputación y `success: true`.
- Lo repetí con una **segunda IP** para confirmar que el resultado es reproducible.
