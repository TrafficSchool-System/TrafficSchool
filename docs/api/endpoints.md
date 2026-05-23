# API Endpoints — Komplett referens

Alla endpoints i TrafficSchool-systemet. Anrop sker alltid via **API Gateway** på
port `8080` (lokalt) eller `https://api-gateway.redriver-3645ccf7.westus2.azurecontainerapps.io` (produktion).

**Auth**-kolumnen: `PUBLIC` = ingen autentisering, `USER` = JWT med roll USER,
`ADMIN` = JWT med roll ADMIN, `INTERNAL` = `X-API-Key`-header (service-to-service).

---

## userService (port 8081)

### Autentisering — `/api/auth`

| Metod  | Path               | Auth   | Beskrivning                                         |
| ------ | ------------------ | ------ | --------------------------------------------------- |
| `POST` | `/api/auth/login`  | PUBLIC | Skicka magic link till angiven e-postadress         |
| `POST` | `/api/auth/verify` | PUBLIC | Verifiera magic link-token, returnerar auth-kontext |
| `POST` | `/api/auth/tokens` | PUBLIC | Verifiera magic link-token, returnerar JWT          |

### Användare — `/api/users`

| Metod  | Path            | Auth       | Beskrivning                      |
| ------ | --------------- | ---------- | -------------------------------- |
| `POST` | `/api/users`    | PUBLIC     | Registrera ny användare          |
| `GET`  | `/api/users/me` | USER/ADMIN | Hämta inloggad användares profil |

### Prenumerationer — `/api/subscriptions`

| Metod  | Path                                      | Auth                | Beskrivning                                                         |
| ------ | ----------------------------------------- | ------------------- | ------------------------------------------------------------------- |
| `POST` | `/api/subscriptions`                      | ADMIN/INTERNAL      | Skapa prenumeration (kallas av paymentService vid betald betalning) |
| `GET`  | `/api/subscriptions/user/{userId}`        | USER/ADMIN/INTERNAL | Hämta alla prenumerationer för en användare                         |
| `GET`  | `/api/subscriptions/user/{userId}/active` | USER/ADMIN/INTERNAL | Hämta aktiva prenumerationer för en användare                       |
| `GET`  | `/api/subscriptions/{id}`                 | USER/ADMIN/INTERNAL | Hämta specifik prenumeration                                        |

### Admin — Användarhantering (via userService) — `/api/admin/users`

| Metod    | Path                          | Auth           | Beskrivning                            |
| -------- | ----------------------------- | -------------- | -------------------------------------- |
| `GET`    | `/api/admin/users`            | ADMIN/INTERNAL | Lista alla användare                   |
| `POST`   | `/api/admin/users`            | ADMIN/INTERNAL | Skapa användare (admin-operation)      |
| `GET`    | `/api/admin/users/{id}`       | ADMIN/INTERNAL | Hämta specifik användare               |
| `PUT`    | `/api/admin/users/{id}`       | ADMIN/INTERNAL | Uppdatera användare                    |
| `DELETE` | `/api/admin/users/{id}`       | ADMIN/INTERNAL | Radera användare permanent             |
| `GET`    | `/api/admin/users/statistics` | ADMIN/INTERNAL | Hämta användarstatistik (totalt antal) |

### Intern kommunikation — `/api/internal`

| Metod | Path                                               | Auth     | Beskrivning                                      |
| ----- | -------------------------------------------------- | -------- | ------------------------------------------------ |
| `GET` | `/api/internal/users/{userId}/subscription-status` | INTERNAL | Kontrollera om användare har aktiv prenumeration |

---

## adminService (port 8082)

### Admin-autentisering — `/api/admin/auth`

| Metod  | Path                     | Auth   | Beskrivning                                            |
| ------ | ------------------------ | ------ | ------------------------------------------------------ |
| `POST` | `/api/admin/auth/login`  | PUBLIC | Admin-inloggning med e-post + lösenord, returnerar JWT |
| `GET`  | `/api/admin/auth/tokens` | ADMIN  | Validera admin-JWT, returnerar admin-info              |
| `GET`  | `/api/admin/auth/health` | PUBLIC | Hälsokontroll                                          |

### Admin — Aggregerad användardata — `/api/admin/users`

| Metod  | Path                        | Auth  | Beskrivning                                                                       |
| ------ | --------------------------- | ----- | --------------------------------------------------------------------------------- |
| `GET`  | `/api/admin/users`          | ADMIN | Lista alla användare med aggregerad data (profil + prenumerationer + betalningar) |
| `GET`  | `/api/admin/users/{userId}` | ADMIN | Hämta komplett användarinfo (aggregerat från userService + paymentService)        |
| `POST` | `/api/admin/users`          | ADMIN | Skapa användare + prenumeration i ett anrop (manuell försäljning)                 |
| `PUT`  | `/api/admin/users/{userId}` | ADMIN | Uppdatera användarinformation                                                     |

---

## paymentService (port 8083)

### Betalningar — `/api/payments`

| Metod  | Path                 | Auth       | Beskrivning                                |
| ------ | -------------------- | ---------- | ------------------------------------------ |
| `POST` | `/api/payments`      | USER/ADMIN | Initiera ny Swish-betalning för ett paket  |
| `GET`  | `/api/payments/{id}` | USER/ADMIN | Hämta betalningsstatus (ägarskapskontroll) |

### Webhook — `/api/webhooks`

| Metod  | Path                  | Auth   | Beskrivning                                  |
| ------ | --------------------- | ------ | -------------------------------------------- |
| `POST` | `/api/webhooks/swish` | PUBLIC | Ta emot betalningsstatus-callback från Swish |

### Paket — `/api/packages`

| Metod | Path                 | Auth       | Beskrivning             |
| ----- | -------------------- | ---------- | ----------------------- |
| `GET` | `/api/packages`      | USER/ADMIN | Lista alla aktiva paket |
| `GET` | `/api/packages/{id}` | USER/ADMIN | Hämta specifikt paket   |

### Admin — Betalningar — `/api/admin/payments`

| Metod    | Path                                          | Auth           | Beskrivning                                               |
| -------- | --------------------------------------------- | -------------- | --------------------------------------------------------- |
| `GET`    | `/api/admin/payments`                         | ADMIN/INTERNAL | Lista alla betalningar                                    |
| `GET`    | `/api/admin/payments/users/{userId}/payments` | ADMIN/INTERNAL | Lista betalningar för en specifik användare               |
| `POST`   | `/api/admin/payments/manual`                  | ADMIN/INTERNAL | Skapa manuell betalning (direkt markerad PAID)            |
| `DELETE` | `/api/admin/payments/users/{userId}`          | ADMIN/INTERNAL | Radera alla betalningar för en användare (cascade delete) |

### Admin — Paket — `/api/admin/packages`

| Metod    | Path                              | Auth  | Beskrivning                          |
| -------- | --------------------------------- | ----- | ------------------------------------ |
| `GET`    | `/api/admin/packages`             | ADMIN | Lista alla paket (aktiva + inaktiva) |
| `POST`   | `/api/admin/packages`             | ADMIN | Skapa nytt paket                     |
| `PUT`    | `/api/admin/packages/{id}`        | ADMIN | Uppdatera paket                      |
| `PUT`    | `/api/admin/packages/{id}/status` | ADMIN | Växla aktiv/inaktiv-status           |
| `DELETE` | `/api/admin/packages/{id}`        | ADMIN | Radera paket                         |

---

## examService (port 8084)

### Prov — `/api/exams`

| Metod  | Path                           | Auth | Beskrivning                                               |
| ------ | ------------------------------ | ---- | --------------------------------------------------------- |
| `POST` | `/api/exams`                   | USER | Starta nytt prov (70 frågor, 50 min)                      |
| `GET`  | `/api/exams/active`            | USER | Hämta pågående prov med sparade svar                      |
| `POST` | `/api/exams/active/answers`    | USER | Spara svar på en fråga                                    |
| `POST` | `/api/exams/active/submission` | USER | Avsluta och rätta prov (godkänt ≥ 70 %)                   |
| `GET`  | `/api/exams/latest/result`     | USER | Hämta resultat från senaste avslutade prov                |
| `GET`  | `/api/exams`                   | USER | Lista alla prov med summerad info                         |
| `GET`  | `/api/exams/statistics`        | USER | Hämta statistik (totalt/godkänt/underkänt, snitt, streak) |

### Admin — Prov — `/api/admin/exams`

| Metod | Path                                    | Auth  | Beskrivning                                                |
| ----- | --------------------------------------- | ----- | ---------------------------------------------------------- |
| `GET` | `/api/admin/exams/statistics`           | ADMIN | Systemövergripande provstatistik (aktiva + avslutade prov) |
| `GET` | `/api/admin/exams/users/{userId}/exams` | ADMIN | Lista alla prov för en specifik användare                  |

---

## quizService (port 8085)

### Quiz — `/api/quizzes`

| Metod | Path                                          | Auth          | Beskrivning                                           |
| ----- | --------------------------------------------- | ------------- | ----------------------------------------------------- |
| `GET` | `/api/quizzes/final-exam`                     | USER/INTERNAL | Hämta 70 frågor för provläge (används av examService) |
| `GET` | `/api/quizzes/sessions?subjects=1,2&limit=10` | USER          | Hämta övningsfrågor filtrerade på ämnen               |

### Admin — Quiz — `/api/admin/quizzes`

| Metod    | Path                            | Auth  | Beskrivning                     |
| -------- | ------------------------------- | ----- | ------------------------------- |
| `GET`    | `/api/admin/quizzes`            | ADMIN | Lista alla frågor               |
| `GET`    | `/api/admin/quizzes/{id}`       | ADMIN | Hämta specifik fråga            |
| `PUT`    | `/api/admin/quizzes/{id}`       | ADMIN | Uppdatera fråga                 |
| `POST`   | `/api/admin/quizzes/imports`    | ADMIN | Importera frågor från Excel/ZIP |
| `GET`    | `/api/admin/quizzes/files`      | ADMIN | Lista Excel-importhistorik      |
| `DELETE` | `/api/admin/quizzes/files/{id}` | ADMIN | Radera importpost               |

---

## Sammanfattning — Antal endpoints per tjänst

| Tjänst         | Publika | USER   | ADMIN  | INTERNAL | Totalt |
| -------------- | ------- | ------ | ------ | -------- | ------ |
| userService    | 3       | 6      | 7      | 2        | 18     |
| adminService   | 2       | —      | 6      | —        | 8      |
| paymentService | 1       | 4      | 7      | —        | 12     |
| examService    | —       | 7      | 2      | —        | 9      |
| quizService    | —       | 2      | 6      | —        | 8      |
| **Totalt**     | **6**   | **19** | **28** | **2**    | **55** |

---

## Autentiseringsflöde

```
Användare:
  POST /api/auth/login  →  magic link skickas via e-post
  POST /api/auth/tokens →  returnerar { token: "eyJ..." }
  Alla vidare anrop: Authorization: Bearer <token>

Admin:
  POST /api/admin/auth/login  →  returnerar { token: "eyJ..." }
  Alla vidare anrop: Authorization: Bearer <token>

Interna tjänster:
  X-API-Key: <SERVICE_API_KEY>
```
