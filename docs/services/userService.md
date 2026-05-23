# userService

Hanterar all användarrelaterad funktionalitet: registrering, lösenordsfri
inloggning (Magic Link), JWT-utfärdande, profiler och prenumerationer.

- **Port:** 8081
- **Åtkomst:** Intern (nås via API Gateway)
- **Databas:** `userServiceDb`
- **Eureka-namn:** `user-service`

---

## Ansvar

- Registrera nya användare
- Skapa och verifiera Magic Link-tokens (skickas via SendGrid)
- Utfärda JWT-tokens efter lyckad inloggning
- Hantera användarprofiler (läsa/uppdatera)
- Hantera prenumerationer (skapas automatiskt vid betald betalning)
- Admin-endpoints för användarhantering

---

## Endpoints

### Auth (`/api/auth`)

| Metod | Path               | Auth | Beskrivning                              |
| ----- | ------------------ | ---- | ---------------------------------------- |
| POST  | `/api/auth/login`  | Nej  | Begär magic link till e-post             |
| POST  | `/api/auth/verify` | Nej  | Verifiera token, få minimal auth-context |
| POST  | `/api/auth/tokens` | Nej  | Verifiera token, få JWT (rekommenderad)  |

### Användare (`/api/users`)

| Metod | Path            | Auth             | Beskrivning                      |
| ----- | --------------- | ---------------- | -------------------------------- |
| POST  | `/api/users`    | Nej              | Registrera ny användare          |
| GET   | `/api/users/me` | JWT (USER/ADMIN) | Hämta inloggad användares profil |

### Prenumerationer (`/api/subscriptions`)

| Metod | Path                                      | Auth           | Beskrivning                                    |
| ----- | ----------------------------------------- | -------------- | ---------------------------------------------- |
| POST  | `/api/subscriptions`                      | INTERNAL/ADMIN | Skapa prenumeration (kallas av paymentService) |
| GET   | `/api/subscriptions/user/{userId}`        | JWT            | Hämta alla prenumerationer för användare       |
| GET   | `/api/subscriptions/user/{userId}/active` | JWT            | Hämta aktiva prenumerationer                   |

### Admin-endpoints (`/api/admin/users`)

| Metod  | Path                          | Auth  | Beskrivning                            |
| ------ | ----------------------------- | ----- | -------------------------------------- |
| GET    | `/api/admin/users`            | ADMIN | Lista alla användare                   |
| GET    | `/api/admin/users/{id}`       | ADMIN | Hämta specifik användare               |
| PUT    | `/api/admin/users/{id}`       | ADMIN | Uppdatera användare                    |
| DELETE | `/api/admin/users/{id}`       | ADMIN | Ta bort användare                      |
| GET    | `/api/admin/users/statistics` | ADMIN | Användarstatistik (totalt antal, etc.) |

---

## Inloggningsflöde (Magic Link)

```
1. POST /api/auth/login   { "email": "user@example.com" }
        ↓
   userService skapar LoginToken (UUID, 15 min giltig, engångs)
   Skickar e-post via SendGrid med länk:
   https://frontend.../verify?token=<uuid>
        ↓
2. Användaren klickar länken → frontend anropar:
   POST /api/auth/tokens  { "token": "<uuid>" }
        ↓
   userService verifierar token (ej använd, ej utgången)
   Returnerar JWT: { "token": "eyJhbGci..." }
        ↓
3. Frontend sparar JWT, skickar det i alla efterföljande requests:
   Authorization: Bearer <jwt>
```

---

## Prenumerationsflöde

Prenumerationer skapas **automatiskt** av paymentService när en betalning
registreras som PAID. Användaren behöver inte göra något manuellt.

```
paymentService (betalning bekräftad)
        ↓
POST /api/subscriptions
Header: X-Internal-API-Key: <SERVICE_API_KEY>
        ↓
userService skapar subscription med:
  - userId, packageId, packageName (snapshot)
  - packagePrice (snapshot), validityDays, validityHours
  - startDate, endDate, paymentId
```

En prenumeration är aktiv om: `cancelled = false` och `endDate` är i framtiden.

---

## Databas

### Tabell: `users`

| Kolumn            | Typ              | Beskrivning          |
| ----------------- | ---------------- | -------------------- |
| `id`              | BIGINT (PK)      | Auto-increment       |
| `first_name`      | VARCHAR          | Förnamn              |
| `last_name`       | VARCHAR          | Efternamn            |
| `email`           | VARCHAR (UNIQUE) | E-post               |
| `personal_number` | VARCHAR (UNIQUE) | Personnummer         |
| `phone_number`    | VARCHAR          | Mobilnummer          |
| `role`            | VARCHAR          | `USER` eller `ADMIN` |
| `created_at`      | DATETIME         | Skapelsedatum        |

### Tabell: `login_token`

| Kolumn       | Typ              | Beskrivning           |
| ------------ | ---------------- | --------------------- |
| `id`         | BIGINT (PK)      | Auto-increment        |
| `token`      | VARCHAR (UNIQUE) | UUID magic link-token |
| `email`      | VARCHAR          | Tillhörande e-post    |
| `expires_at` | DATETIME         | Utgångstid            |
| `used`       | BOOLEAN          | Sant om redan använd  |
| `created_at` | DATETIME         | Skapelsedatum         |

### Tabell: `subscriptions`

| Kolumn           | Typ         | Beskrivning                              |
| ---------------- | ----------- | ---------------------------------------- |
| `id`             | BIGINT (PK) | Auto-increment                           |
| `user_id`        | BIGINT      | Koppling till `users.id`                 |
| `package_id`     | BIGINT      | Referens till paket i paymentService     |
| `package_name`   | VARCHAR     | Snapshot av paketnamn vid köp            |
| `package_price`  | DECIMAL     | Snapshot av pris vid köp                 |
| `validity_days`  | INT         | Antal dagar prenumerationen gäller       |
| `validity_hours` | INT         | Totalt antal timmar                      |
| `payment_id`     | VARCHAR     | Koppling till betalning i paymentService |
| `purchase_date`  | DATETIME    | Köpdatum                                 |
| `start_date`     | DATETIME    | Startdatum                               |
| `end_date`       | DATETIME    | Slutdatum                                |
| `cancelled`      | BOOLEAN     | `false` = aktiv, `true` = avbruten       |

> Prenumerationspriset och paketnamnet sparas som **snapshot** — ändras
> inte om paketet senare uppdateras i paymentService.

---

## Miljövariabler

| Variabel                 | Beskrivning                                 | Krävs |
| ------------------------ | ------------------------------------------- | ----- |
| `MYSQLHOST`              | Databasadress                               | Ja    |
| `MYSQLPORT`              | Databasport (default 3306)                  | Ja    |
| `MYSQLDATABASE`          | Databasnamn (`userServiceDb`)               | Ja    |
| `MYSQLUSER`              | Databasanvändare                            | Ja    |
| `MYSQLPASSWORD`          | Databaslösenord                             | Ja    |
| `JWT_SECRET`             | Signeringsnyckel — måste matcha api-gateway | Ja    |
| `SERVICE_API_KEY`        | Intern API-nyckel                           | Ja    |
| `SENDGRID_API_KEY`       | API-nyckel för e-postutskick                | Ja    |
| `SENDGRID_FROM_EMAIL`    | Avsändaradress                              | Ja    |
| `SENDGRID_FROM_NAME`     | Avsändarnamn                                | Ja    |
| `FRONTEND_URL`           | CORS-tillåten origin                        | Ja    |
| `SPRING_PROFILES_ACTIVE` | Aktiv profil (`prod`)                       | Ja    |

---

## Beroenden

- **Eureka Server** — registrerar sig vid uppstart
- **MySQL** — `userServiceDb`
- **SendGrid** — skickar magic link-mail
- **api-gateway** — JWT_SECRET måste vara identisk
- **paymentService** — anropar `/api/subscriptions` vid bekräftad betalning
