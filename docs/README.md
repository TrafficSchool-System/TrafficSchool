# TRAFFICSCHOOL

En webbaserad körskoleplattform där elever kan registrera sig, köpa paket,
öva med quiz och genomföra digitala teoriprov. Systemet är byggt som
mikroservicearkitektur med Spring Boot och React.

---

## TEKNOLOGISTACK 

| TJÄNST           | TEKNOLOGI                  | PORT  | ÅTKOMST  |
|------------------|----------------------------|-------|----------|
| frontend         | React 18, Vite, TailwindCSS| 5173  | Publik   |
| api-gateway      | Spring Cloud Gateway       | 8080  | Publik   |
| eureka-server    | Netflix Eureka             | 8761  | Intern   |
| userService      | Spring Boot 3, Java 21     | 8081  | Intern   |
| adminService     | Spring Boot 3, Java 21     | 8082  | Intern   |
| paymentService   | Spring Boot 3, Java 21     | 8083  | Intern   |
| examService      | Spring Boot 3, Java 21     | 8084  | Intern   |
| quizService      | Spring Boot 3, Java 21     | 8085  | Intern   |

**Databas:** MySQL 8.0 — en databas per tjänst  
**Auth:** Lösenordsfri inloggning via Magic Link (e-post) + JWT  
**E-post:** SendGrid  
**Betalning:** Swish  

---

## LIVE MILJÖ (Azure Container Apps)

| TJÄNST      | URL                                                                 |
|-------------|---------------------------------------------------------------------|
| Frontend    | https://frontend.redriver-3645ccf7.westus2.azurecontainerapps.io   |
| API Gateway | https://api-gateway.redriver-3645ccf7.westus2.azurecontainerapps.io|

Alla andra tjänster körs internt och nås bara via API Gateway.

---

## DOKUMENTATION


## Arkitektur

- [Arkitekturöversikt](architecture/overview.md)  
  Systemdiagram, designval och databasstrategi

- [Auth-flöde](architecture/auth-flow.md)  
  Magic links, JWT och admin-inloggning

- [Service-kommunikation](architecture/service-communication.md)  
  Eureka, interna headers och API-nycklar

---

## Services

- [API Gateway](services/api-gateway.md)  
  Routing, filters, CORS och rate limiting

- [userService](services/userService.md)  
  Authentication, profiler och prenumerationer

- [adminService](services/adminService.md)  
  Admin-login och användarhantering

- [paymentService](services/paymentService.md)  
  Paket och Swish-betalningar

- [examService](services/examService.md)  
  Provsessioner, svar och resultat

- [quizService](services/quizService.md)  
  Frågebank och ämnen

---

## API

- [Alla endpoints](api/endpoints.md)  
  Komplett API-referens

---

## Deployment & Setup

- [Kör lokalt](guides/local-setup.md)  
  Docker-setup, `.env` och lokal utveckling

- [Miljövariabler](guides/environment-variables.md)  
  Variabler per tjänst

- [Deployment](guides/deployment.md)  
  GitHub Actions + Azure Container Apps

---

# KÖR LOKALT

Kräver Docker och Docker Compose.

```bash
docker-compose up --build 
```

Se guides/local-setup.md för fullständig guide,
.env-mall och felsökning.