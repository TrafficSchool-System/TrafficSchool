# adminService

Hanterar admin-autentisering (email + lösenord) och aggregerar användardata
från flera microservices till ett enda svar för admin-panelen.

- **Port:** 8082
- **Åtkomst:** Intern (nås via API Gateway)
- **Databas:** `adminServiceDb`
- **Eureka-namn:** `admin-service`

---

## Ansvar

- Autentisera administratörer (email + lösenord → JWT med `ADMIN`-roll)
- Validera admin-JWT-tokens
- Aggregera användardata från userService + paymentService i ett anrop
- Skapa användare med prenumeration i ett enda admin-flöde (manuell försäljning)

---

## Endpoints

### Admin-autentisering (`/api/admin/auth`)

| Metod | Path                     | Auth        | Beskrivning                            |
| ----- | ------------------------ | ----------- | -------------------------------------- |
| POST  | `/api/admin/auth/login`  | Nej         | Inloggning med e-post + lösenord → JWT |
| GET   | `/api/admin/auth/tokens` | JWT (ADMIN) | Validera token, returnera admin-info   |
| GET   | `/api/admin/auth/health` | Nej         | Hälsokontroll                          |

### Användarhantering (`/api/admin/users`)

Alla endpoints kräver ADMIN-roll (valideras i Gateway).

| Metod | Path                        | Auth  | Beskrivning                              |
| ----- | --------------------------- | ----- | ---------------------------------------- |
| GET   | `/api/admin/users`          | ADMIN | Lista alla användare med aggregerad data |
| GET   | `/api/admin/users/{userId}` | ADMIN | Hämta komplett användarinfo (aggregerad) |
| POST  | `/api/admin/users`          | ADMIN | Skapa användare + prenumeration manuellt |
| PUT   | `/api/admin/users/{userId}` | ADMIN | Uppdatera användarinfo                   |

---

## Aggregerat användarobjekt (`CompleteUserDetailsDto`)

`GET /api/admin/users` och `GET /api/admin/users/{userId}` returnerar ett
aggregerat objekt som samlar data från flera tjänster:

```json
{
  "userInfo": { ... },         // Från userService
  "subscriptions": [ ... ],    // Från userService
  "payments": [ ... ],         // Från paymentService
  "statistics": { ... }        // Beräknat (totalt antal köp, etc.)
}
```

Syfte: reducera antalet anrop från frontend (3 → 1).

---

## Manuell försäljning (`POST /api/admin/users`)

Används när en admin säljer ett paket manuellt (fysiskt, telefon, etc.):

```
1. adminService skapar användare i userService
        ↓
2. adminService skapar manuell betalning i paymentService
   (status: PAID, method: MANUAL)
        ↓
3. paymentService aktiverar prenumeration i userService
        ↓
Returnerar: skapad användare + prenumerationsdetaljer
```

---

## Admin-konto (Seeding)

Vid uppstart skapas ett default-adminkonto automatiskt om inget existerar:

| Fält     | Värde                      |
| -------- | -------------------------- |
| Username | `admin`                    |
| Password | `admin123` (BCrypt-hashat) |
| E-post   | `admin@trafficschool.com`  |

> Byt lösenord i produktion via miljövariabel eller databas.

---

## Databas

### Tabell: `admins`

| Kolumn       | Typ              | Beskrivning            |
| ------------ | ---------------- | ---------------------- |
| `id`         | BIGINT (PK)      | Auto-increment         |
| `username`   | VARCHAR (UNIQUE) | Inloggningsnamn        |
| `password`   | VARCHAR          | BCrypt-hashat lösenord |
| `email`      | VARCHAR (UNIQUE) | E-postadress           |
| `first_name` | VARCHAR          | Förnamn                |
| `last_name`  | VARCHAR          | Efternamn              |
| `active`     | BOOLEAN          | `true` = aktivt konto  |
| `created_at` | DATETIME         | Skapelsedatum          |
| `last_login` | DATETIME         | Senaste inloggning     |

---

## Miljövariabler

| Variabel                 | Beskrivning                                    | Krävs |
| ------------------------ | ---------------------------------------------- | ----- |
| `MYSQLHOST`              | Databasadress                                  | Ja    |
| `MYSQLPORT`              | Databasport (default 3306)                     | Ja    |
| `MYSQLDATABASE`          | Databasnamn (`adminServiceDb`)                 | Ja    |
| `MYSQLUSER`              | Databasanvändare                               | Ja    |
| `MYSQLPASSWORD`          | Databaslösenord                                | Ja    |
| `JWT_SECRET`             | Signeringsnyckel — måste matcha api-gateway    | Ja    |
| `SERVICE_API_KEY`        | Intern API-nyckel för service-to-service-anrop | Ja    |
| `SPRING_PROFILES_ACTIVE` | Aktiv profil (`prod`)                          | Ja    |

---

## Beroenden

- **Eureka Server** — registrerar sig vid uppstart
- **MySQL** — `adminServiceDb`
- **api-gateway** — JWT_SECRET måste vara identisk
- **userService** — anropas för att hämta/uppdatera användare och prenumerationer
- **paymentService** — anropas för att hämta betalningar och skapa manuella köp
