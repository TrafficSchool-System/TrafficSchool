# api-gateway

Ingångspunkten för all extern trafik. Validerar JWT, rate-limitar,
hanterar CORS och routar requests till rätt mikrotjänst.

- **Port:** 8080
- **Åtkomst:** Publik (extern)
- **Teknologi:** Spring Cloud Gateway (reaktiv, non-blocking)

---

## Ansvar

- Ta emot alla requests från frontend och externa klienter
- Validera JWT-tokens och avvisa ogiltiga requests (401)
- Skydda mot överbelastning med rate limiting (429)
- Hantera CORS för frontend-origin
- Routa requests till rätt tjänst via Eureka
- Logga alla inkommande requests och response-koder

---

## Filter-kedja (ordning)

Varje request passerar dessa filter i ordning:

```
Request
  │
  ▼
1. RateLimitFilter          — Kontrollera tokens per IP (Bucket4j)
  │
  ▼
2. JwtAuthenticationGlobalFilter — Validera JWT, sätt X-User-* headers
  │
  ▼
3. SubscriptionValidationFilter  — (valfritt) Kontrollera aktiv prenumeration
  │
  ▼
4. RouteLocator                  — Matcha path → skicka till tjänst
  │
  ▼
5. requestLoggingFilter          — Logga request
6. responseLoggingFilter         — Logga response-status
```

---

## Routing

Routes matchas **uppifrån och ner** — mest specifik regel vinner.

| Path                          | Metod       | Destination    |
| ----------------------------- | ----------- | -------------- |
| `/api/admin/users/statistics` | GET         | userService    |
| `/api/admin/users/**`         | DELETE, PUT | userService    |
| `/api/admin/users/**`         | GET         | adminService   |
| `/api/admin/exams/**`         | Alla        | examService    |
| `/api/admin/quizzes/**`       | Alla        | quizService    |
| `/api/admin/payments/**`      | Alla        | paymentService |
| `/api/admin/packages/**`      | Alla        | paymentService |
| `/api/admin/**`               | Alla        | adminService   |
| `/api/auth/**`                | Alla        | userService    |
| `/api/users/**`               | Alla        | userService    |
| `/api/subscriptions/**`       | Alla        | userService    |
| `/api/payments/**`            | Alla        | paymentService |
| `/api/packages/**`            | Alla        | paymentService |
| `/api/webhooks/**`            | Alla        | paymentService |
| `/api/quizzes/**`             | Alla        | quizService    |
| `/api/exams/**`               | Alla        | examService    |

> Alla routes har **retry 3 gånger** vid `500 Internal Server Error`.

---

## JWT-validering

Filtret `JwtAuthenticationGlobalFilter` körs på alla requests utom publika endpoints.

**Publika endpoints (ingen JWT krävs):**

| Path                    | Metod |
| ----------------------- | ----- |
| `/api/auth/login`       | POST  |
| `/api/auth/verify`      | POST  |
| `/api/auth/tokens`      | POST  |
| `/api/users`            | POST  |
| `/api/admin/auth/login` | POST  |
| `/api/webhooks/swish`   | POST  |

**Vid giltig JWT:**

- Extraherar `userId`, `email`, `role` från token
- Tar bort inkommande `X-User-*` headers (säkerhet)
- Sätter `X-User-Id`, `X-User-Email`, `X-User-Role` på vidarebefordrad request

**Vid ogiltig JWT:** → `401 Unauthorized`

---

## Rate Limiting (Bucket4j)

Skyddar mot brute force och överbelastning. Mäts per IP-adress.

| Endpoint-typ                | Gräns         | Scope      |
| --------------------------- | ------------- | ---------- |
| Generellt                   | 100 req/minut | Per IP     |
| `/api/auth/login`           | 5 req/minut   | Per IP     |
| `/api/users` (registrering) | 2 req/minut   | Per IP     |
| `/api/payments`             | 10 req/minut  | Per userId |

Vid överskriden gräns: `429 Too Many Requests`  
Response-headern `X-Rate-Limit-Remaining` visar återstående tokens.

---

## CORS

Konfigureras dynamiskt baserat på miljö.

| Miljö      | Tillåtna origins                                                          |
| ---------- | ------------------------------------------------------------------------- |
| Lokal      | `http://localhost:5173`, `http://localhost:3000`, `http://localhost:4173` |
| Produktion | Värdet av env-variabel `FRONTEND_URL`                                     |

- Credentials (JWT) är tillåtet
- Alla HTTP-metoder tillåts
- Preflight-svar cachas i 1 timme

---

## Profiler

Gateway har två routing-konfigurationer beroende på miljö:

| Profil              | Klass                  | Används i                    |
| ------------------- | ---------------------- | ---------------------------- |
| `local` / `default` | `GatewayConfig`        | Lokal Docker, Eureka-baserad |
| `prod` / `prod`  | `ProductionGatewayConfig` | Azure Container Apps         |

Båda använder Eureka `lb://`-prefix för service discovery.

---

## Timeout-konfiguration

| Parameter              | Värde    |
| ---------------------- | -------- |
| Connect timeout        | 5 000 ms |
| Response timeout       | 30 s     |
| Max connections (pool) | 500      |
| Max idle time          | 10 s     |

---

## Miljövariabler

| Variabel                 | Beskrivning                                 | Krävs     |
| ------------------------ | ------------------------------------------- | --------- |
| `JWT_SECRET`             | Signeringsnyckel — måste matcha userService | Ja        |
| `SERVICE_API_KEY`        | Intern API-nyckel för service-kommunikation | Ja        |
| `FRONTEND_URL`           | Tillåten CORS-origin i produktion           | Ja (prod) |
| `SPRING_PROFILES_ACTIVE` | Aktiv profil (`prod`, `local`)              | Ja        |

---

## Beroenden

- **Eureka Server** — service discovery för `lb://`-routing
- **userService** — JWT-secret måste vara identisk
- Alla andra tjänster är beroende av att Gateway är uppe
