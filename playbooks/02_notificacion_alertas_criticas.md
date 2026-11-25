# Playbook 2 · `Notificacion_Alertas_Criticas`

**Objetivo:** avisar al equipo del SOC por correo cuando llega una alerta crítica, en vez de revisar la consola a mano cada cierto tiempo.

## Por qué Http en lugar de la app Email
La acción nativa de correo de Shuffle no tenía, en esta instancia, un campo de autenticación SMTP que se pudiera usar. Por eso invoqué directamente la **API transaccional de Brevo**, cuyo plan gratuito no exige dominio propio. El remitente es una cuenta de correo dedicada al SOC, verificada en Brevo.

## Flujo

```
Webhook (recibe {"ip": ...}) ──► Http POST a la API de Brevo ──► correo al SOC
```

## Configuración del nodo Http

| Campo | Valor |
|---|---|
| Método | `POST` |
| URL | `https://api.brevo.com/v3/smtp/email` |
| Encabezados | `api-key: <API_KEY_BREVO>` · `Content-Type: application/json` |

```json
{
  "sender":  { "name": "SOC Alertas", "email": "<remitente_verificado>" },
  "to":      [ { "email": "<destinatario_soc>" } ],
  "subject": "Alerta critica de seguridad",
  "htmlContent": "<p>Se registró una alerta crítica asociada a la IP <b>$exec.ip</b>.</p>"
}
```

## Validación
- Ejecución `FINISHED`. El nodo Http devolvió `201` con el `messageId` que asignó Brevo.
- El correo **"Alerta critica de seguridad"** llegó a la bandeja del destinatario con la IP de la alerta.
