# 📋 Guía de Pruebas Manuales — Flujo Completo de Remesas SaGiro

> Prueba end-to-end a través del **API Gateway** (`http://localhost:8765`).  
> Incluye: crear cuentas, KYC, cotización, remesa, pago blockchain y tracking.

---

## 🌐 URLs de referencia

| Servicio | URL directa | Via Gateway |
|---|---|---|
| **API Gateway** | — | `http://localhost:8765` |
| **Swagger UI (todo)** | — | `http://localhost:8765/swagger-ui.html` |
| **IAM Service** | `http://localhost:8082` | via gateway |
| **Ledger Service** | `http://localhost:8083` | via gateway |
| **Web3 Service** | `http://localhost:3001` | via gateway |
| **Keycloak Admin** | `http://localhost:8081` | admin / admin |

> ✅ **Usa siempre el Gateway** en el puerto `8765` para las pruebas del flujo completo.

---

## 🔑 Sobre la autenticación

El gateway extrae automáticamente el `sub` del JWT y lo inyecta como header `X-User-Id` a los microservicios.  
El Ledger Service **requiere** ese header.

En Swagger UI:
1. Haz click en **Authorize** (candado)
2. Pega el token como: `Bearer eyJhbGci...`

---

## 🔄 Flujo del escenario

```
USUARIO A (remitente en Perú)         USUARIO B (receptor en EEUU)
─────────────────────────────         ───────────────────────────
1. Registrar cuenta A          →
2. Login A → obtener JWT       →
3. Simular KYC A               →
4. Agregar cuenta bancaria A   →
                                       5. Registrar cuenta B
                                       6. Registrar wallet B (destino)
7. Pedir cotización (USD→PEN)  →
8. Crear remesa con quoteId    →
9. Confirmar depósito (Yape)   →       (Kafka dispara Web3)
10. Ver timeline Web3          →
11. Trackear TX blockchain     →
```

---

## 👤 PARTE A — Cuenta del REMITENTE (Usuario A)

### A-1 · Verificar que el gateway está activo

```http
GET http://localhost:8765/api/v1/test/ping
```

**Respuesta esperada `200`:**
```json
{
  "status": "SUCCESS",
  "message": "IAM service is reachable",
  "data": { "message": "pong" }
}
```

---

### A-2 · Registrar el usuario remitente

```http
POST http://localhost:8765/api/v1/users/register
Content-Type: application/json
```

```json
{
  "email": "miguel.torres@sagiro.test",
  "username": "miguel.torres",
  "phone": "+51912345678",
  "firstName": "Miguel",
  "lastName": "Torres",
  "country": "PE",
  "preferredLanguage": "es",
  "initialPassword": "Sagiro#2026Nuevo"
}
```
"id - A": "ee568dc1-6b33-4e90-870c-473b55b4ad19",

**Respuesta esperada `201`:**
```json
{
  "status": "SUCCESS",
  "message": "User registered successfully",
  "data": {
    "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "email": "miguel.torres@sagiro.test",
    "username": "miguel.torres",
    "accountStatus": "REGISTERED",
    "verificationStatus": "NOT_STARTED",
    "canOperate": false
  }
}
```

> 📝 **Guarda** el valor de `data.id` → **USER_A_ID**

---

### A-3 · Iniciar sesión con el usuario A

```http
POST http://localhost:8765/api/v1/users/login
Content-Type: application/json
```

```json
{
  "usernameOrEmail": "miguel.torres@sagiro.test",
  "password": "Sagiro#2026Nuevo"
}
```

**Respuesta esperada `200`:**
```json
{
  "status": "SUCCESS",
  "data": {
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzUxMiIs...",
    "expiresIn": 300,
    "tokenType": "Bearer"
  }
}
```

> 📝 **Guarda** el `accessToken` → **TOKEN_A**  
> Úsalo en todos los pasos siguientes como `Authorization: Bearer TOKEN_A`

---

### A-4 · Verificar datos del usuario A (antes del KYC)

```http
GET http://localhost:8765/api/v1/users/me
Authorization: Bearer TOKEN_A
```

**Valida:**
- `accountStatus` = `"REGISTERED"`
- `canOperate` = `false`
- `verificationStatus` = `"NOT_STARTED"`

---

### A-5 · Simular aprobación de KYC del usuario A

```http
POST http://localhost:8765/api/v1/users/me/simulate-kyc
Authorization: Bearer TOKEN_A
```

**Body:** vacío (`{}` o sin body)

**Respuesta esperada `200`:**
```json
{
  "status": "SUCCESS",
  "message": "KYC simulated successfully",
  "data": {
    "accountStatus": "ACTIVE",
    "verificationStatus": "VERIFIED",
    "verificationLevel": "BASIC",
    "canOperate": true
  }
}
```

> ✅ Ahora el usuario puede hacer remesas (`canOperate: true`)

---

### A-6 · Agregar cuenta bancaria de origen (Usuario A)

```http
POST http://localhost:8765/api/v1/users/me/bank-accounts
Authorization: Bearer TOKEN_A
Content-Type: application/json
```

```json
{
  "bankName": "BBVA",
  "accountNumber": "0011-0474-0100234567",
  "accountType": "SAVINGS",
  "currency": "PEN",
  "country": "PE",
  "alias": "Mi cuenta BBVA ahorros"
}
```


**Respuesta esperada `201`:**
```json
{
  "status": "SUCCESS",
  "data": {
    "id": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
    "bankName": "BBVA",
    "accountNumber": "0011-0474-0100234567",
    "accountType": "SAVINGS",
    "currency": "PEN",
    "alias": "Mi cuenta BBVA ahorros"
  }
}
```

> 📝 Guarda el `id` → **BANK_ACCOUNT_A_ID**

"id - cuenta a": "451cc92d-4012-427b-b0cc-5a7ac5f10d33",
---

### A-7 · Agregar tarjeta de pago del usuario A (opcional)

```http
POST http://localhost:8765/api/v1/users/me/cards
Authorization: Bearer TOKEN_A
Content-Type: application/json
```

```json
{
  "cardNumber": "5500005555555559",
  "cardholderName": "MIGUEL TORRES",
  "expiryMonth": 9,
  "expiryYear": 2028,
  "cardBrand": "MASTERCARD",
  "cardType": "DEBIT",
  "alias": "Mastercard débito"
}
```
  "id - card ": "bf96f70c-7fc7-4586-9abe-d5553475ec47",


---

## 👤 PARTE B — Cuenta del RECEPTOR (Usuario B)

### B-1 · Registrar el usuario receptor

```http
POST http://localhost:8765/api/v1/users/register
Content-Type: application/json
```

```json
{
  "email": "jennifer.luna@sagiro.test",
  "username": "jennifer.luna",
  "phone": "+13055559876",
  "firstName": "Jennifer",
  "lastName": "Luna",
  "country": "US",
  "preferredLanguage": "en",
  "initialPassword": "Sagiro#Recv2026B"
}
```

**Respuesta esperada `201`:**
```json
{
  "status": "SUCCESS",
  "data": {
    "id": "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
    "email": "jennifer.luna@sagiro.test",
    "username": "jennifer.luna",
    "accountStatus": "REGISTERED"
  }
}
```

> 📝 Guarda el `data.id` → **USER_B_ID**
    "id - B": "c2e3637e-0650-47b5-8783-a82518288219",
---

### B-2 · Iniciar sesión con usuario B

```http
POST http://localhost:8765/api/v1/users/login
Content-Type: application/json
```

```json
{
  "usernameOrEmail": "jennifer.luna@sagiro.test",
  "password": "Sagiro#Recv2026B"
}
```

> 📝 Guarda el `accessToken` → **TOKEN_B**

---

### B-3 · Registrar wallet blockchain del receptor (destino del USDC)

```http
POST http://localhost:8765/api/v1/users/me/bank-accounts
Authorization: Bearer TOKEN_B
Content-Type: application/json
```

```json
{
  "bankName": "Polygon Wallet",
  "accountNumber": "0x3D7E4B8F9C1A2E5D6F0B3C8A9E4D1F2B5C7A0E3",
  "accountType": "CHECKING",
  "currency": "USDC",
  "country": "US",
  "alias": "Wallet Polygon Jennifer"
}
```

> 📝 Guarda el `id` → **WALLET_B_ID**  
> Y la dirección: **WALLET_B_ADDRESS** = `0x3D7E4B8F9C1A2E5D6F0B3C8A9E4D1F2B5C7A0E3`


 "id CUENTA B": "5d2795c3-769b-45b3-9f0c-9b697db829e2",
---
/////////////ACA ME QUEDE
## 💱 PARTE C — Cotización y Remesa (con TOKEN_A)

### C-1 · Crear cotización de tipo de cambio

Este endpoint calcula la tasa de cambio USD → PEN y devuelve un `quoteId` que expira en ~5 minutos.

```http
POST http://localhost:8765/api/v1/quotes
Authorization: Bearer TOKEN_A
X-Idempotency-Key: quote-miguel-002
Content-Type: application/json
```

```json
{
  "sourceCurrency": "USD",
  "destCurrency": "PEN",
  "destinationCountry": "PE",
  "amountUSD": 0.05
}
```

**Respuesta esperada `201`:**
```json
{
  "quoteId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "amountUSD": 75.00,
  "sourceCurrency": "USD",
  "destinationCurrency": "PEN",
  "exchangeRate": 3.75,
  "fee": 0.02,
  "feeAmount": 1.50,
  "amountDestination": 276.00,
  "amountSourceCurrency": 281.25,
  "expiresAt": "2026-06-22T23:15:00Z"
}
```

> 📝 **Guarda** el `quoteId` → **QUOTE_ID**
> ⚠️ Tienes ~5 minutos antes de que expire. Continúa al siguiente paso de inmediato.
 "quoteId": "01416d2f-42af-4b7f-b2ce-b034c8646645",
---

### C-2 · Consultar la cotización creada

```http
GET http://localhost:8765/api/v1/quotes/QUOTE_ID
Authorization: Bearer TOKEN_A
```

**Valida que:**
- `exchangeRate` sea razonable (≈ 3.70 – 3.85)
- `expiresAt` sea en el futuro

---

### C-3 · Crear la remesa

Usa el `quoteId` del paso anterior. El `depositCode` que responde es como un "código Yape" que simula el pago.

```http
POST http://localhost:8765/api/v1/remittances
Authorization: Bearer TOKEN_A
X-Idempotency-Key: remittance-miguel-002
Content-Type: application/json
```

```json
{
  "quoteId": "QUOTE_ID",
  "destinationUserId": "USER_B_ID",
  "destinationBankAccountId": "WALLET_B_ID",
  "destinationWalletAddress": "WALLET_B_ADDRESS",
  "note": "Apoyo mensual Jennifer"
}
```

Ejemplo concreto con IDs reales:
```json
{
  "quoteId": "01416d2f-42af-4b7f-b2ce-b034c8646645",
  "destinationUserId": "c2e3637e-0650-47b5-8783-a82518288219",
  "destinationBankAccountId": "5d2795c3-769b-45b3-9f0c-9b697db829e2",
  "destinationWalletAddress": "0x3D7E4B8F9C1A2E5D6F0B3C8A9E4D1F2B5C7A0E3",
  "note": "Apoyo mensual Jennifer"
}
```

**Respuesta esperada `201`:**
```json
{
  "remittanceId": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
  "depositCode": "SAG-789012",
  "amountUSD": 0.05,
  "feeAmount": 1.50,
  "amountDestination": 276.00,
  "amountSourceCurrency": 281.25,
  "message": "Simula un Yape de S/281.25 con código SAG-789012",
  "expiresAt": "2026-06-22T23:25:00Z",
  "status": "PENDING_DEPOSIT"
}
```

> 📝 **Guarda** el `remittanceId` → **REMITTANCE_ID**  
> 📝 **Guarda** el `depositCode` → **DEPOSIT_CODE** (ej. `SAG-123456`)

---

### C-4 · Consultar el estado de la remesa creada

```http
GET http://localhost:8765/api/v1/remittances/REMITTANCE_ID
Authorization: Bearer TOKEN_A
```

**Respuesta esperada `200`:**
```json
{
  "remittanceId": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
  "userId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "status": "PENDING_DEPOSIT",
  "amountUSD": 75.00,
  "depositCode": "SAG-789012",
  "txHash": null,
  "timeline": []
}
```

**Valida:**
- `status` = `"PENDING_DEPOSIT"` (esperando que el usuario haga el Yape/depósito)
- `txHash` = `null` (aún no se envió a blockchain)

---

### C-5 · Confirmar el depósito (simula el Yape/pago)

Este paso simula que el banco/Yape notificó que el pago fue recibido. En producción lo haría un webhook; en testing lo hacemos manualmente.

```http
POST http://localhost:8765/api/v1/remittances/REMITTANCE_ID/confirm-deposit
Authorization: Bearer TOKEN_A
```

**Body:** vacío

**Respuesta esperada `204 No Content`** (sin body)

> 🚀 Después de este paso, Kafka dispara el evento al **Web3 Service** que inicia la transacción blockchain en Polygon AMOY.

---

### C-6 · Consultar remesas del usuario A

```http
GET http://localhost:8765/api/v1/remittances/user/USER_A_ID?page=0&size=10
Authorization: Bearer TOKEN_A
```

**Respuesta esperada `200`:**
```json
{
  "remittances": [
    {
      "remittanceId": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
      "status": "DEPOSIT_CONFIRMED",
      "amountUSD": 75.00,
      "depositCode": "SAG-789012",
      "txHash": null,
      "createdAt": "2026-06-22T22:58:00Z"
    }
  ],
  "totalElements": 1,
  "summary": {
    "totalUSD": 75.00,
    "totalRemittances": 1,
    "completedCount": 0,
    "failedCount": 0
  }
}
```

---

## ⛓️ PARTE D — Web3 / Blockchain Tracking

### D-1 · Verificar estado del Web3 Service

```http
GET http://localhost:8765/api/v1/health
```

**Respuesta esperada `200`:**
```json
{
  "status": "ok",
  "wallet": "0xcb3E3A9AF0D72786172fCeb2E27Ab835504daA00",
  "network": "polygon-amoy",
  "kafkaConnected": true,
  "dbConnected": true,
  "timestamp": "2026-06-14T10:12:00.000Z"
}
```

---

### D-2 · Ver timeline de la orden Web3

Después de confirmar el depósito (Paso C-5), el Web3 Service crea una Order internamente. Consulta el timeline con el mismo **REMITTANCE_ID**:

```http
GET http://localhost:8765/api/v1/orders/REMITTANCE_ID/timeline
Authorization: Bearer TOKEN_A
```

**Respuesta esperada `200`:**
```json
{
  "remittanceId": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
  "currentStatus": "IN_BLOCKCHAIN",
  "txHash": "0xa1b2c3d4e5f67890a1b2c3d4e5f67890a1b2c3d4e5f67890a1b2c3d4e5f67890",
  "blockNumber": null,
  "explorerUrl": "https://amoy.polygonscan.com/tx/0xa1b2c3d4...",
  "steps": [
    {
      "step": 1,
      "label": "Depósito recibido",
      "status": "completed",
      "timestamp": "2026-06-22T22:58:00Z",
      "detail": "S/281.25 recibidos"
    },
    {
      "step": 2,
      "label": "Enviando por blockchain",
      "status": "in_progress",
      "txHash": "0xa1b2c3d4...",
      "explorerUrl": "https://amoy.polygonscan.com/tx/0xa1b2c3d4..."
    },
    {
      "step": 3,
      "label": "Confirmado en red Polygon",
      "status": "pending",
      "blockNumber": null
    },
    {
      "step": 4,
      "label": "Pagado en destino",
      "status": "pending",
      "detail": "Pendiente"
    }
  ]
}
```

> 📝 **Guarda** el `txHash` → **TX_HASH**

---

### D-3 · Trackear la transacción en Polygon

```http
GET http://localhost:8765/api/v1/tx/TX_HASH/track
Authorization: Bearer TOKEN_A
```

Ejemplo:
```http
GET http://localhost:8765/api/v1/tx/0xa1b2c3d4e5f67890a1b2c3d4e5f67890a1b2c3d4e5f67890a1b2c3d4e5f67890/track
```

**Respuesta esperada `200`:**
```json
{
  "txHash": "0xa1b2c3d4...",
  "status": "confirmed",
  "blockNumber": 23456789,
  "confirmations": 5,
  "explorerUrl": "https://amoy.polygonscan.com/tx/0xa1b2c3d4...",
  "from": "0xcb3E3A9AF0D72786172fCeb2E27Ab835504daA00",
  "to": "0x3D7E4B8F9C1A2E5D6F0B3C8A9E4D1F2B5C7A0E3",
  "value": "0.0",
  "gasUsed": "52000",
  "timestamp": "2026-06-22T22:59:00Z"
}
```

**Estados posibles del campo `status`:**

| Status | Significado |
|---|---|
| `pending` | TX enviada, sin minear todavía |
| `confirmed` | Minada con ≥ 3 confirmaciones ✅ |
| `failed` | TX revertida en la blockchain |

---

### D-4 · Status ligero de la TX (polling rápido)

```http
GET http://localhost:8765/api/v1/tx/TX_HASH/status
Authorization: Bearer TOKEN_A
```

**Respuesta esperada `200`:**
```json
{
  "txHash": "0xa1b2c3d4...",
  "status": "confirmed",
  "confirmations": 7
}
```

---

### D-5 · Ver info de la wallet operadora

```http
GET http://localhost:8765/api/v1/tx/wallet/info
Authorization: Bearer TOKEN_A
```

**Respuesta esperada `200`:**
```json
{
  "address": "0xcb3E3A9AF0D72786172fCeb2E27Ab835504daA00",
  "balanceUSDC": 245.50,
  "balanceMATIC": 0.85,
  "network": "polygon-amoy",
  "explorerUrl": "https://amoy.polygonscan.com/address/0xcb3E3A9AF0D72786172fCeb2E27Ab835504daA00"
}
```

---

## 🔍 PARTE E — Verificar desde el Explorador Blockchain

Una vez que tengas el `txHash`, puedes verificarlo directamente en el explorador de Polygon AMOY:

```
https://amoy.polygonscan.com/tx/TX_HASH
```

Debería mostrar:
- **Status**: ✅ Success
- **From**: `0xcb3E3A9AF0D72786172fCeb2E27Ab835504daA00` (wallet operadora)
- **To**: `0x3D7E4B8F9C1A2E5D6F0B3C8A9E4D1F2B5C7A0E3` (wallet de Jennifer)
- **Token Transfer**: cantidad de USDC enviada (~75 USDC)

---

## 🔐 PARTE F — Pruebas adicionales de seguridad

### F-1 · Acceso sin token (debe dar 401)

```http
GET http://localhost:8765/api/v1/users/me
```

**Respuesta esperada `401`:**
```json
{
  "timestamp": "...",
  "status": 401,
  "error": "Unauthorized"
}
```

---

### F-2 · Token de usuario A accediendo a remesa con user B (no debe ver otra)

El Ledger tiene lógica de ownership — un usuario solo ve sus propias remesas.

```http
GET http://localhost:8765/api/v1/remittances/user/USER_B_ID
Authorization: Bearer TOKEN_A
```

**Respuesta esperada:** `403 Forbidden` o lista vacía según implementación.

---

### F-3 · QuoteId expirado (debe dar error)

Si esperas más de 5 minutos después del Paso C-1 e intentas crear la remesa:

**Respuesta esperada `409` o `422`:**
```json
{
  "error": "Quote expired or not found"
}
```

---

## 📋 TABLA RESUMEN — Flujo completo

| # | Servicio | Método | Endpoint | Auth | Descripción |
|---|---|---|---|---|---|
| A-1 | IAM | GET | `/api/v1/test/ping` | ❌ | Health check |
| A-2 | IAM | POST | `/api/v1/users/register` | ❌ | Crear cuenta A |
| A-3 | IAM | POST | `/api/v1/users/login` | ❌ | Obtener JWT A |
| A-4 | IAM | GET | `/api/v1/users/me` | ✅ | Ver perfil propio |
| A-5 | IAM | POST | `/api/v1/users/me/simulate-kyc` | ✅ | Aprobar KYC |
| A-6 | IAM | POST | `/api/v1/users/me/bank-accounts` | ✅ | Agregar cuenta bancaria |
| B-1 | IAM | POST | `/api/v1/users/register` | ❌ | Crear cuenta B (receptor) |
| B-2 | IAM | POST | `/api/v1/users/login` | ❌ | Obtener JWT B |
| B-3 | IAM | POST | `/api/v1/users/me/bank-accounts` | ✅ B | Registrar wallet destino |
| C-1 | Ledger | POST | `/api/v1/quotes` | ✅ A | Cotizar USD → PEN |
| C-2 | Ledger | GET | `/api/v1/quotes/{id}` | ✅ | Consultar cotización |
| C-3 | Ledger | POST | `/api/v1/remittances` | ✅ A | Crear remesa |
| C-4 | Ledger | GET | `/api/v1/remittances/{id}` | ✅ | Ver estado remesa |
| C-5 | Ledger | POST | `/api/v1/remittances/{id}/confirm-deposit` | ✅ | Confirmar pago (Yape) |
| C-6 | Ledger | GET | `/api/v1/remittances/user/{userId}` | ✅ | Historial de remesas |
| D-1 | Web3 | GET | `/api/v1/health` | ❌ | Health Web3 |
| D-2 | Web3 | GET | `/api/v1/orders/{remittanceId}/timeline` | ✅ | Timeline blockchain |
| D-3 | Web3 | GET | `/api/v1/tx/{txHash}/track` | ✅ | Trackear TX |
| D-4 | Web3 | GET | `/api/v1/tx/{txHash}/status` | ✅ | Status ligero TX |
| D-5 | Web3 | GET | `/api/v1/tx/wallet/info` | ✅ | Info wallet operadora |

---

## 🐛 Errores comunes y soluciones

| Error | Causa probable | Solución |
|---|---|---|
| `503 Service Unavailable` | Microservicio caído | Verifica `docker ps` y `npm run dev` |
| `401 Unauthorized` | Token expirado (dura 5 min) | Repite el paso de login |
| `Quote expired` | Más de 5 min desde cotizar | Vuelve al Paso C-1 |
| `404 Order not found` | Web3 aún no procesó el evento Kafka | Espera 10-15s y reintenta |
| `txHash null` | Web3 aún procesando | Espera 30s, reintenta D-2 |
| `canOperate: false` | KYC no completado | Completa el Paso A-5 |
| `X-Idempotency-Key duplicada` | Reusaste la misma key | Cambia el valor de la key |

---

## 🧪 Headers requeridos por servicio

### Ledger Service (críticos)

| Header | Descripción | Ejemplo |
|---|---|---|
| `Authorization` | JWT Bearer token | `Bearer eyJhbGci...` |
| `X-Idempotency-Key` | Clave única por operación (anti-duplicado) | `quote-miguel-002` |
| `X-User-Id` | UUID del usuario — **lo inyecta el gateway** | (automático) |
| `X-Correlation-ID` | ID de correlación (opcional) | `my-trace-id-001` |

> ⚠️ `X-User-Id` es inyectado automáticamente por el API Gateway a partir del JWT.  
> **No lo pongas manualmente** si usas el gateway — ya viene del token.

---

## 🔄 Estado de la remesa — Ciclo de vida

```
PENDING_DEPOSIT
    ↓  (confirm-deposit)
DEPOSIT_CONFIRMED
    ↓  (Kafka → Web3 Service)
IN_BLOCKCHAIN
    ↓  (TX minada en Polygon)
TX_CONFIRMED
    ↓
PAYOUT_IN_PROGRESS
    ↓
COMPLETED ✅

En caso de error:
FAILED ❌
```
