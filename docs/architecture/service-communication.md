# Service-kommunikation

Beskriver hur tjänsterna hittar varandra, pratar med varandra och
hur trafik flödar genom systemet.

---

## 1. API Gateway — Routing

All extern trafik går genom API Gateway på port 8080.
Gateway routar baserat på URL-path till rätt tjänst.

### Routing-tabell

| Path-prefix                   | Metod       | Tjänst         |
| ----------------------------- | ----------- | -------------- |
| `/api/auth/**`                | Alla        | userService    |
| `/api/users/**`               | Alla        | userService    |
| `/api/subscriptions/**`       | Alla        | userService    |
| `/api/payments/**`            | Alla        | paymentService |
| `/api/packages/**`            | Alla        | paymentService |
| `/api/webhooks/**`            | Alla        | paymentService |
| `/api/quizzes/**`             | Alla        | quizService    |
| `/api/exams/**`               | Alla        | examService    |
| `/api/admin/users/statistics` | GET         | userService    |
| `/api/admin/users/**`         | DELETE, PUT | userService    |
| `/api/admin/users/**`         | GET         | adminService   |
| `/api/admin/exams/**`         | Alla        | examService    |
| `/api/admin/quizzes/**`       | Alla        | quizService    |
| `/api/admin/payments/**`      | Alla        | paymentService |
| `/api/admin/packages/**`      | Alla        | paymentService |
| `/api/admin/**`               | Alla        | adminService   |

> **OBS:** Routes är ordnade från mest specifik till minst specifik.
> `/api/admin/users/statistics` måste komma före `/api/admin/**`.

---

## 2. Service Discovery (Eureka)

Istället för hårdkodade URL:er använder Gateway och tjänster Eureka
för att hitta varandra.

```
Tjänst startar
    │
    ▼
Registrerar sig i Eureka Server (:8761)
med namn: user-service, quiz-service, exam-service, ...
    │
    ▼
Gateway slår upp: lb://user-service
    │
    ▼
Eureka returnerar aktuell IP + port
    │
    ▼
Gateway skickar request dit
```

**Fördelen:** Om en tjänst byter port eller skalas upp automatiskt
hittar alla andra den via Eureka — ingen config behöver ändras.

### Eureka-namn per tjänst

| Tjänst         | Eureka-namn       |
| -------------- | ----------------- |
| userService    | `user-service`    |
| adminService   | `admin-service`   |
| paymentService | `payment-service` |
| examService    | `exam-service`    |
| quizService    | `quiz-service`    |
| eureka-server  | `eureka-server`   |

---

## 3. Service-till-service (examService → quizService)

Normalt kommunicerar tjänster **inte** direkt med varandra — all trafik
går via Gateway. Undantaget är examService som hämtar frågor från quizService.

```
Användare: POST /api/exams (starta prov)
        │
        ▼
examService
        │
        │  GET http://quiz-service/api/quizzes/final-exam
        │  Header: X-Internal-API-Key: <SERVICE_API_KEY>
        ▼
quizService
        │
        └── Verifierar API-nyckeln
            Returnerar 70 frågor (14 per ämne)
```

**Konfiguration i examService:**

```
quiz.service.url=http://quiz-service   # Lokalt via Eureka
quiz.service.url=http://quizservice:8085  # Produktion direktadress
```

WebClient är konfigurerad med `X-Internal-API-Key` header på alla anrop.

---

## 4. Gateway-headers till downstream

När JWT är validerat sätter Gateway dessa headers på alla vidarebefordrade requests:

| Header         | Innehåll               | Exempel              |
| -------------- | ---------------------- | -------------------- |
| `X-User-Id`    | Användarens databas-ID | `42`                 |
| `X-User-Email` | Användarens e-post     | `user@example.com`   |
| `X-User-Role`  | Roll från JWT          | `USER` eller `ADMIN` |

Inkommande `X-User-*` headers från klienten **tas bort** av Gateway
innan de sätts på nytt — förhindrar header injection-attacker.

Tjänsterna läser dessa via `GatewayHeaderAuthenticationFilter` som
bygger ett `CustomUserAuthentication`-objekt i Spring SecurityContext.

---

## 5. Rate Limiting

Gateway begränsar antalet requests per IP med Bucket4j.

| Typ                           | Gräns         | Scope      |
| ----------------------------- | ------------- | ---------- |
| Generella requests            | 100 req/minut | Per IP     |
| Login (`/api/auth/login`)     | 5 req/minut   | Per IP     |
| Registrering (`/api/users`)   | 2 req/minut   | Per IP     |
| Betalningar (`/api/payments`) | 10 req/minut  | Per userId |

Vid överskriden gräns returneras `429 Too Many Requests`.

---

## 6. Retry-logik

Gateway försöker automatiskt igen vid `500 Internal Server Error`:

- **Max 3 försök** per route
- Gäller alla tjänster
- Hjälper vid kortvariga uppstarter eller tillfälliga fel

---

## 7. Sammanfattning av kommunikationsflöden

```
[Browser]
    │ HTTPS
    ▼
[API Gateway :8080]
    ├── Validerar JWT
    ├── Rate limiting
    ├── Sätter X-User-* headers
    ├── Route matching
    │
    ├──→ [userService :8081]     (Eureka: lb://user-service)
    ├──→ [adminService :8082]    (Eureka: lb://admin-service)
    ├──→ [paymentService :8083]  (Eureka: lb://payment-service)
    ├──→ [examService :8084]     (Eureka: lb://exam-service)
    │         │
    │         └──→ [quizService :8085]  (direkt via WebClient + API-nyckel)
    └──→ [quizService :8085]     (Eureka: lb://quiz-service)

[Eureka Server :8761]
    └── Alla tjänster registrerar sig hit vid uppstart
```
