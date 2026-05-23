# ARKITEKTURÖVERSIKT

## VAD ÄR SYSTEMET?

TrafficSchool är en mikroservicebaserad körskoleplattform. Varje domän
(auth, betalning, prov, quiz) är en egen fristående tjänst med egen databas.
All extern trafik går genom API Gateway, inga tjänster exponeras direkt.

---

## SYSTEMDIAGRAM 

```mermaid
flowchart TB

    A[Browser / Mobilapp]
    B[Frontend (React - port 80)]
    C[API Gateway (Spring Cloud Gateway - port 8080)]

    A --> B
    B --> C

    C -->|JWT validering<br/>sätter headers (UserId, Email, Role)| SVC

    subgraph SVC[Microservices]
        D[userService :8081]
        E[adminService :8082]
        F[paymentService :8083]
        G[examService :8084]
        H[quizService :8085]
    end

    C --> D
    C --> E
    C --> F
    C --> G
    C --> H

    subgraph INFRA[Infrastructure]
        I[Eureka Server :8761]
        J[MySQL (per service)]
    end

    D --> I
    E --> I
    F --> I
    G --> I
    H --> I

    D --> J
    E --> J
    F --> J
    G --> J
    H --> J
```

**Extern åtkomst:** Endast frontend och api-gateway är publikt åtkomliga.  
**Intern kommunikation:** Tjänster hittar varandra via Eureka (`lb://user-service`).

---

## DESIGNBESLUT

### Varför mikroservices?
Varje domän (auth, betalning, prov) kan driftsättas, skalas och uppdateras
oberoende av de andra. Ett fel i quizService stoppar inte inloggning.

### Varför Eureka (Service Discovery)?
Inga hårdkodade URL:er mellan tjänster. Gateway slår upp `lb://user-service`
i Eureka och lastbalanserar automatiskt. Fungerar lika bra lokalt och i moln.

### Varför Magic Link istället för lösenord?
- Ingen lösenordsdatabas att skydda eller läcka
- Bättre användarupplevelse (ingen att glömma)
- Admin tjänsten använder fortfarande email + lösenord (separat adminflöde)

### Varför JWT?
Stateless autentisering, ingen session att hantera på servern.
Token innehåller: `userId`, `email`, `role` (USER eller ADMIN).

### Database per Service
Varje tjänst äger sin databas och schema. Ingen tjänst läser direkt
ur en annan tjänsts databas — kommunikation sker alltid via API.

| Tjänst          | Databas            |
|-----------------|--------------------|
| userService     | `userServiceDb`    |
| adminService    | `adminServiceDb`   |
| paymentService  | `paymentServiceDb` |
| examService     | `examservicedb`    |
| quizService     | `quizServiceDb`    |

---

## Kodarkitektur (per tjänst)

Alla Spring Boot-tjänster följer **Vertical Slice Architecture**:
features/
auth/
controller/ ← HTTP-lager (ingen business logic)
service/ ← Use Cases (all business logic här)
dto/
entity/
repository/
user/
controller/
service/
...
shared/
security/
config/

--- 

## Teknikstack

| Kategori       | Teknologi                        |
|----------------|----------------------------------|
| Backend        | Spring Boot 3, Java 21, Maven    |
| Frontend       | React 18, Vite, TailwindCSS      |
| API Gateway    | Spring Cloud Gateway             |
| Service Disco  | Netflix Eureka                   |
| Databas        | MySQL 8.0 (en per tjänst)        |
| Auth           | JWT (HMAC-SHA256), Magic Link    |
| E-post         | SendGrid                         |
| Betalning      | Swish                            |
| Hosting        | Azure Container Apps             |
| CI/CD          | GitHub Actions + Azure ACR       |
| Lokalt         | Docker Compose                   |