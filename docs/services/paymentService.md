# paymentService

Hanterar betalningar via Swish och pakethantering. Vid godkänd betalning
anropas userService automatiskt för att aktivera användarens prenumeration.

- **Port:** 8083
- **Åtkomst:** Intern (nås via API Gateway)
- **Databas:** `paymentServiceDb`
- **Eureka-namn:** `payment-service`

---

## Ansvar

- Initiera Swish-betalningar
- Ta emot betalningsåterrop (webhooks) från Swish
- Aktivera prenumerationer i userService efter godkänd betalning
- Hantera betalningspaket (CRUD för admin)
- Stödja manuella betalningar (admin-skapad, direktmarkerad som PAID)

---

## Endpoints

### Betalningar (`/api/payments`)

| Metod | Path                        | Auth             | Beskrivning              |
| ----- | --------------------------- | ---------------- | ------------------------ |
| POST  | `/api/payments`             | JWT (USER/ADMIN) | Initiera Swish-betalning |
| GET   | `/api/payments/{paymentId}` | JWT              | Hämta betalningsstatus   |

### Swish-webhook (`/api/webhooks/swish`)

| Metod | Path                  | Auth         | Beskrivning                       |
| ----- | --------------------- | ------------ | --------------------------------- |
| POST  | `/api/webhooks/swish` | Nej (extern) | Ta emot statuscallback från Swish |

### Paket (`/api/packages`)

| Metod | Path                 | Auth | Beskrivning           |
| ----- | -------------------- | ---- | --------------------- |
| GET   | `/api/packages`      | JWT  | Lista aktiva paket    |
| GET   | `/api/packages/{id}` | JWT  | Hämta specifikt paket |

### Admin — Betalningar (`/api/admin/payments`)

| Metod  | Path                                 | Auth           | Beskrivning                    |
| ------ | ------------------------------------ | -------------- | ------------------------------ |
| GET    | `/api/admin/payments`                | ADMIN/INTERNAL | Lista alla betalningar         |
| GET    | `/api/admin/users/{userId}/payments` | ADMIN/INTERNAL | Betalningar för en användare   |
| POST   | `/api/admin/payments/manual`         | ADMIN/INTERNAL | Skapa manuell betalning        |
| DELETE | `/api/admin/payments/users/{userId}` | ADMIN/INTERNAL | Ta bort användares betalningar |

### Admin — Paket (`/api/admin/packages`)

| Metod  | Path                              | Auth  | Beskrivning                       |
| ------ | --------------------------------- | ----- | --------------------------------- |
| GET    | `/api/admin/packages`             | ADMIN | Lista alla paket (inkl. inaktiva) |
| POST   | `/api/admin/packages`             | ADMIN | Skapa nytt paket                  |
| PUT    | `/api/admin/packages/{id}`        | ADMIN | Uppdatera paket                   |
| PUT    | `/api/admin/packages/{id}/status` | ADMIN | Aktivera/inaktivera paket         |
| DELETE | `/api/admin/packages/{id}`        | ADMIN | Ta bort paket                     |

---

## Betalningsflöde (Swish)

```
1. POST /api/payments
   { "payerAlias": "46712345678", "packageId": 1 }
   userId hämtas från JWT — skickas ALDRIG i body
        ↓
2. paymentService skapar Payment (status: PENDING)
   Skickar instruktion till Swish
   Returnerar: { "paymentId": "...", "deepLink": "swish://..." }
        ↓
3. Swish skickar callback:
   POST /api/webhooks/swish
   { "id": "...", "status": "PAID" }
        ↓
4. paymentService uppdaterar Payment.status → PAID
   Anropar userService:
   POST /api/subscriptions (med SERVICE_API_KEY)
        ↓
5. userService skapar aktiv prenumeration
```

**Möjliga statuses från Swish:** `PAID`, `DECLINED`, `CANCELLED`, `ERROR`  
**Interna statuses:** `CREATED` → `PENDING` → `PAID` / `DECLINED` / `CANCELLED` / `ERROR` / `EXPIRED`

---

## Betalningsmetoder

| Metod    | Beskrivning                                                            |
| -------- | ---------------------------------------------------------------------- |
| `SWISH`  | Standardflöde via Swish-integrering (kräver `payerAlias` och callback) |
| `MANUAL` | Admin-skapad betalning (markeras direkt som PAID, ingen callback)      |

---

## Pakettyper (`PackageType`)

| Typ     | Giltighetstid | Exempel                |
| ------- | ------------- | ---------------------- |
| `DAY`   | 1–6 dagar     | "1 dag", "3 dagar"     |
| `WEEK`  | 7–29 dagar    | "1 vecka", "2 veckor"  |
| `MONTH` | 30+ dagar     | "1 månad", "3 månader" |

`validityHours` beräknas automatiskt från `validityDays × 24`.

---

## Databas

### Tabell: `payments`

| Kolumn                | Typ              | Beskrivning                                                               |
| --------------------- | ---------------- | ------------------------------------------------------------------------- |
| `id`                  | VARCHAR(32) (PK) | instructionUUID (uppercase, utan bindestreck)                             |
| `user_id`             | BIGINT           | Koppling till användare                                                   |
| `package_id`          | BIGINT           | Köpt paket                                                                |
| `payment_method`      | ENUM             | `SWISH` / `MANUAL`                                                        |
| `payer_alias`         | VARCHAR(15)      | Swish-nummer (format: `46712345678`)                                      |
| `amount`              | DECIMAL          | Betalningsbelopp                                                          |
| `status`              | ENUM             | `CREATED`, `PENDING`, `PAID`, `DECLINED`, `CANCELLED`, `ERROR`, `EXPIRED` |
| `payment_reference`   | VARCHAR(50)      | Referens från Swish vid PAID                                              |
| `callback_identifier` | VARCHAR(36)      | Identifier för att verifiera Swish-callback                               |
| `created_at`          | DATETIME         | Skapad                                                                    |
| `completed_at`        | DATETIME         | Genomförd (null om ej PAID)                                               |
| `error_message`       | TEXT             | Felinformation vid misslyckad betalning                                   |

### Tabell: `packages`

| Kolumn           | Typ              | Beskrivning                       |
| ---------------- | ---------------- | --------------------------------- |
| `id`             | BIGINT (PK)      | Auto-increment                    |
| `package_type`   | ENUM             | `DAY`, `WEEK`, `MONTH`            |
| `name`           | VARCHAR (UNIQUE) | Paketnamn                         |
| `price`          | DECIMAL          | Pris                              |
| `description`    | VARCHAR(500)     | Beskrivning                       |
| `validity_days`  | INT              | Antal giltiga dagar               |
| `validity_hours` | INT              | Beräknat automatiskt (dagar × 24) |
| `active`         | BOOLEAN          | `true` = visas för användare      |

---

## Säkerhet

- `userId` hämtas **alltid** från JWT-kontexten — accepteras aldrig från request body (förhindrar spoofing)
- Swish-webhook är publik men valideras via `callbackIdentifier`-header
- Alltid 200 OK i svar på webhook (förhindrar retry-loopar från Swish)
- Admin-endpoints kräver `ADMIN` eller `INTERNAL_SERVICE`-roll

---

## Miljövariabler

| Variabel                 | Beskrivning                                  | Krävs |
| ------------------------ | -------------------------------------------- | ----- |
| `MYSQLHOST`              | Databasadress                                | Ja    |
| `MYSQLPORT`              | Databasport (default 3306)                   | Ja    |
| `MYSQLDATABASE`          | Databasnamn (`paymentServiceDb`)             | Ja    |
| `MYSQLUSER`              | Databasanvändare                             | Ja    |
| `MYSQLPASSWORD`          | Databaslösenord                              | Ja    |
| `JWT_SECRET`             | Signeringsnyckel — måste matcha api-gateway  | Ja    |
| `SERVICE_API_KEY`        | Intern API-nyckel (skickas till userService) | Ja    |
| `SWISH_API_URL`          | Swish API-adress                             | Ja    |
| `SWISH_PHONE_NUMBER`     | Handlarens Swish-nummer                      | Ja    |
| `SWISH_CALLBACK_URL`     | Publik URL dit Swish skickar callbacks       | Ja    |
| `SPRING_PROFILES_ACTIVE` | Aktiv profil (`prod`)                        | Ja    |

---

## Beroenden

- **Eureka Server** — registrerar sig vid uppstart
- **MySQL** — `paymentServiceDb`
- **Swish** — extern betaltjänst (kräver certifikat och publik callback-URL)
- **userService** — anropas via `POST /api/subscriptions` efter PAID
- **api-gateway** — JWT_SECRET måste vara identisk
