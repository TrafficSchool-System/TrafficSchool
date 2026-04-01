# 🚀 Production Readiness Checklist

> **Status:** 🔧 UNDER UTVECKLING  
> **Senast uppdaterad:** 2026-03-28  
> **Ansvarig:** [Fahri Kuzey]  
> **Deployment Target:** ☁️ Microsoft Azure

---

## 📊 Progress Overview

- **Kritiska problem:** 6/6 ✅
- **Viktiga problem:** 4/4 ✅
- **Rekommendationer:** 0/5 ✗
- **Total progress:** 67% ⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜

---

## 🔴 KRITISKA SÄKERHETSPROBLEM (Blocker för lansering)

### 1. ENV-filer committade i Git

**Status:** ✅ KLAR  
**Prioritet:** 🔥 AKUT  
**Tid:** ~30 min  
**Genomfört:** 2026-03-14

**Problem:**

- ~~`.env` filer är committade i userService, adminService, examService, quizService~~
- ~~Känsliga credentials exponerade på GitHub~~
- ~~Databas-lösenord, API-nycklar synliga för alla~~

**Resultat:**

- ✅ Verifierade att ingen .env fil fanns i git (aldrig committad)
- ✅ Lagt till `.env` i `.gitignore` för alla services
- ✅ Committat och pushat till GitHub:
  - userService: 1297f47
  - adminService: d91327f
  - examService: b741b72
  - quizService: 5fc9a85
  - paymentService: hade redan .env i .gitignore

**Åtgärder:**

- [x] Kör `git rm --cached .env` i alla services med .env
- [x] Verifiera att `.env` finns i `.gitignore`
- [x] Force push för att ta bort från git historik
- [x] ~~Rotera alla exponerade secrets~~ (ej nödvändigt - aldrig exponerade)

**Kommandon:**

```bash
# Verifiering genomförd:
cd userService && git ls-files | Select-String "^\.env$"  # Ingen output = OK
# Upprepat för adminService, examService, quizService - alla OK

# .gitignore uppdaterad och pushad till GitHub
```

**Verify:**

```bash
git ls-files | grep ".env"  # Ska inte ge några resultat
```

---

### 2. Hårdkodad API Key i källkod

**Status:** ✅ KLAR  
**Prioritet:** 🔥 KRITISK  
**Tid:** ~15 min  
**Genomfört:** 2026-03-15

**Problem:**

- ~~`userService/Config/WebClientConfig.java:52` har hårdkodad API key~~
- ~~`"TrafficSchool-Internal-Key-2026-CHANGE-IN-PROD"` synlig i källkod~~
- ~~Samma key används av alla services~~

**Resultat:**

- ✅ userService/WebClientConfig.java: Använder nu `@Value("${service.api.key}")` variabel
- ✅ paymentService/ServiceApiKeyFilter.java: Tog bort fallback-värde från `@Value`
- ✅ Inga hårdkodade API-nycklar kvar i källkoden
- ✅ Alla services läser API key från .env filer via application.properties

**Åtgärder:**

- [x] Ta bort hårdkodad key från WebClientConfig.java
- [x] Konfigurera `@Value("${service.api.key}")` utan fallback
- [x] Generera ny säker API key
- [x] Sätt SERVICE_API_KEY environment variable i alla services

**Filer ändrade:**

- `userService/src/main/java/com/example/userService/Config/WebClientConfig.java`
- `paymentService/src/main/java/com/example/paymentService/Security/ServiceApiKeyFilter.java`

**Generera ny key (för produktion):**

```bash
openssl rand -base64 32 > service_api_key.txt
```

---

### 3. Svaga JWT Secrets med fallbacks

**Status:** ✅ KLAR  
**Prioritet:** 🔥 KRITISK  
**Tid:** ~20 min  
**Genomfört:** 2026-03-15

**Problem:**

- ~~JWT secret: `mySecretKey123456789012345678901234567890` i alla services~~
- ~~Alla services (userService, adminService, api-gateway) använder samma secret~~
- ~~Fallback-värde i application.properties~~

**Resultat:**

- ✅ Tog bort osäkra fallback-värden från alla application.properties
- ✅ Nu: `jwt.secret=${JWT_SECRET}` (utan fallback)
- ✅ Applikationen kraschar om JWT_SECRET saknas → Säkrare för produktion
- ✅ Alla services måste ha JWT_SECRET i .env fil

**Åtgärder:**

- [x] Ta bort fallback från application.properties (behåll endast `${JWT_SECRET}`)
- [x] Generera kryptografiskt säker 64-byte secret (för produktion)
- [x] Sätt JWT_SECRET environment variable identiskt i alla services

**Filer ändrade:**

- `userService/src/main/resources/application.properties`
- `adminService/src/main/resources/application.properties`
- `api-gateway/src/main/resources/application.properties`

**Generera stark secret (för produktion):**

```bash
openssl rand -base64 64 > jwt_secret.txt
```

**Environment variable (alla services):**

```bash
export JWT_SECRET="[innehållet från jwt_secret.txt]"
```

**⚠️ VIKTIGT för produktion:**
Använd INTE utvecklings-secret! Generera ny stark nyckel med kommandot ovan.

---

### 4. CORS endast för localhost

**Status:** ✅ KLAR  
**Prioritet:** 🔥 KRITISK  
**Tid:** ~10 min  
**Genomfört:** 2026-03-15

**Problem:**

- ~~CORS tillåter endast localhost:5173, localhost:3000, localhost:4173~~
- ~~Ingen produktion-domän konfigurerad~~
- ~~Frontend kan inte kommunicera med backend i produktion~~

**Resultat:**

- ✅ CorsConfig.java använder nu dynamisk FRONTEND_URL från environment variable
- ✅ If/else logik: Om FRONTEND_URL satt → använd den, annars → localhost fallback för dev
- ✅ Logging tillagd för att se vilken konfiguration som används
- ✅ FRONTEND_URL tillagd i api-gateway/.env (http://localhost:5173)
- ✅ FRONTEND_URL tillagd i api-gateway/.env.example med dev/prod exempel

**Åtgärder:**

- [x] Lägg till produktion-domän i allowedOrigins
- [x] Läs CORS origins från environment variable
- [x] Ta bort localhost från produktion

**Filer ändrade:**

- `api-gateway/src/main/java/com/example/api_gateway/Config/CorsConfig.java`
- `api-gateway/.env`
- `api-gateway/.env.example`

**Implementerad lösning:**

```java
String frontendUrl = System.getenv("FRONTEND_URL");
if (frontendUrl != null && !frontendUrl.isEmpty()) {
    config.setAllowedOrigins(Arrays.asList(frontendUrl));
    System.out.println("CORS: Using configured frontend URL: " + frontendUrl);
} else {
    config.setAllowedOrigins(Arrays.asList(
        "http://localhost:5173",
        "http://localhost:3000",
        "http://localhost:4173"
    ));
    System.out.println("CORS: Using localhost origins for development");
}
```

**För produktion:**
Sätt `FRONTEND_URL=https://trafficschool.se` i produktionsmiljön

---

### 5. Swish testmiljö och temporär ngrok URL

**Status:** ✅ KLAR  
**Prioritet:** 🔥 KRITISK  
**Tid:** ~45 min  
**Genomfört:** 2026-03-15

**Problem:**

- ~~Swish base URL: testmiljö (`https://mss.cpc.getswish.net`) med fallback~~
- ~~Test merchant number: `1234679304` hårdkodad som fallback~~
- ~~Callback URL: ngrok temporary tunnel som fallback~~
- ~~Keystore password: fallback-värde i application.properties~~

**Resultat:**

- ✅ Tog bort osäkra fallback-värden från application.properties
- ✅ Nu: `swish.base-url=${SWISH_BASE_URL}` (utan fallback)
- ✅ Nu: `swish.merchant-number=${SWISH_MERCHANT_NUMBER}` (utan fallback)
- ✅ Nu: `swish.callback-url=${SWISH_CALLBACK_URL}` (utan fallback)
- ✅ Nu: `swish.key-store-password=${SWISH_KEYSTORE_PASSWORD}` (utan fallback)
- ✅ Applikationen kraschar om Swish-config saknas → Säkrare för produktion

**Åtgärder:**

- [x] Ta bort fallback-värden från application.properties
- [x] Alla Swish configs läses nu från environment variables
- [ ] **TODO för produktion:** Beställ Swish produktions-credentials
- [ ] **TODO för produktion:** Konfigurera persistent callback URL (https://api.[dindomän].se/api/webhooks/swish)
- [ ] **TODO för produktion:** Uppdatera .env med produktion base URL: `https://cpc.getswish.net`

**Filer ändrade:**

- `paymentService/src/main/resources/application.properties`

**Development workflow (ngrok):**

```bash
# 1. Starta ngrok
ngrok http 8085

# 2. Få URL typ: https://abc123.ngrok-free.app

# 3. Uppdatera .env
SWISH_CALLBACK_URL=https://abc123.ngrok-free.app/api/webhooks/swish

# 4. Starta paymentService
```

**Production environment variables:**

```bash
SWISH_BASE_URL=https://cpc.getswish.net
SWISH_MERCHANT_NUMBER=[ditt riktiga nummer från Swish]
SWISH_CALLBACK_URL=https://api.trafficschool.se/api/webhooks/swish
SWISH_KEYSTORE_PASSWORD=[säkert password från Swish]
```

---

### 6. System.out och printStackTrace i produktionskod

**Status:** ✅ KLAR  
**Prioritet:** 🔥 HANTERAS FÖRE LANSERING  
**Tid:** ~2 timmar  
**Genomfört:** 2026-03-16

**Problem:**

- ~~50+ platser med `System.out.println()` över alla services~~
- ~~`printStackTrace()` exposar känslig information~~
- ~~Svenska felmeddelanden i exceptions och logs~~
- ~~Emails och användardata loggades i plain text~~

**Resultat:**

- ✅ Alla `System.out.println()` ersatta med SLF4J logging (`log.info()`, `log.error()`)
- ✅ Alla `printStackTrace()` ersatta med `log.error(e.getMessage(), e)`
- ✅ Alla svenska felmeddelanden konverterade till engelska
- ✅ Parametrized logging använt för bättre performance: `log.info("User: {}", id)`
- ✅ Static logger pattern: `private static final Logger log = LoggerFactory.getLogger(ClassName.class)`
- ✅ 0 kompileringsfel i alla services

**Services genomförda:**

- ✅ **userService** (7 filer): UserService, EmailService, AuthService, SubscriptionService, GlobalExceptionHandler, SecurityConfig
- ✅ **adminService** (2 filer): AdminSeeder, GlobalExceptionHandler
- ✅ **paymentService** (3 filer): GlobalExceptionHandler, PackageService, PaymentService
- ✅ **examService** (3 filer): ExamController, SubmitAnswerRequest, SecurityConfig
- ✅ **quizService** (4 filer): ZipExtractorUtil, GlobalExceptionHandler, ExcelImportService, ExcelValidationUtil

**Åtgärder:**

- [x] Ersätt alla `System.out.println()` med `log.info()` / `log.debug()`
- [x] Ersätt alla `printStackTrace()` med `log.error(e.getMessage(), e)`
- [x] Konvertera alla svenska exception messages till engelska
- [x] Använd parametrized logging för bättre performance
- [x] Verifiera 0 kompileringsfel

**Exempel översättningar:**

- "Användare hittades inte" → "User not found"
- "Felaktig förfrågan" → "Invalid request"
- "Betalning misslyckades" → "Payment failed"
- "saknas på rad" → "missing on row"
- "får inte bara vara siffror" → "must not be only digits"

**Verifiering:**

```bash
# Alla System.out och printStackTrace borttagna:
grep -r "System\.out\|printStackTrace" . --include="*.java"  # 0 resultat

# Alla services kompilerar utan fel:
get_errors  # 0 errors
```

**⚠️ OBS:** Svenska kommentarer i koden är OK och bevarade för svenska utvecklare.

---

## 🟡 VIKTIGA PRODUKTIONSPROBLEM (Bör fixas före lansering)

### 7. Email Service är mock implementation

**Status:** ✅ KLAR  
**Prioritet:** ⚠️ VIKTIGT  
**Tid:** ~4 timmar  
**Genomfört:** 2026-03-16

**Problem:**

- ~~EmailService skrev bara till konsol~~
- ~~Inga faktiska emails skickades~~
- ~~Magic link login fungerade inte~~

**Resultat:**

- ✅ SendGrid integrerad som email provider
- ✅ Professionella HTML email templates skapade:
  - Welcome email (grön tema 🚗)
  - Magic link login (blå tema 🔑)
- ✅ SendGrid API key konfigurerad i .env
- ✅ Sender email verifierad (Fk@excetra.se)
- ✅ Frontend URL fixad till http://localhost:5173
- ✅ Testat och verifierat - emails levereras!

**Åtgärder:**

- [x] Valde email provider: SendGrid (gratis 100 emails/dag)
- [x] Lade till SendGrid Java SDK dependency
- [x] Konfigurerade SendGrid API key och sender email
- [x] Implementerade HTML email templates med inline CSS
- [x] Testade välkomstmail och magic link

**Filer ändrade:**

- `userService/pom.xml` - Lade till SendGrid dependency (4.10.2)
- `userService/.env` - Lade till SENDGRID_API_KEY, SENDGRID_FROM_EMAIL, SENDGRID_FROM_NAME
- `userService/src/main/resources/application.properties` - SendGrid konfiguration
- `userService/Service/email/EmailService.java` - Ersatte mock med SendGrid implementation

**Email templates features:**

- Responsiv design (mobile-friendly)
- Professional layout med headers och footers
- Call-to-action buttons
- Security warnings (för magic links)
- Inline CSS för maximal kompatibilitet

**För produktion:**

```env
SENDGRID_FROM_EMAIL=noreply@trafficschool.se
MAGIC_LINK_BASE_URL=https://trafficschool.se
```

**SendGrid Dashboard:** https://app.sendgrid.com/  
**Free tier limit:** 100 emails/dag

---

### 8. Ingen monitoring eller health checks

**Status:** ✅ KLAR  
**Prioritet:** ⚠️ VIKTIGT  
**Tid:** ~3 timmar  
**Genomfört:** 2026-03-16

**Problem:**

- ~~Spring Boot Actuator kommenterad bort~~
- ~~Ingen insight i system health~~
- ~~Kan inte se om services är nere~~

**Resultat:**

- ✅ Spring Boot Actuator dependency tillagd i alla 7 microservices:
  - eureka-server (port 8761)
  - api-gateway (port 8080) - inkluderar gateway endpoint
  - userService (port 8081)
  - quizService (port 8082)
  - examService (port 8083)
  - adminService (port 8084)
  - paymentService (port 8085)
- ✅ Actuator konfigurerad i application.properties för alla services
- ✅ Health, info, metrics endpoints exponerade
- ✅ Detaljerad health info aktiverad (visa database, diskSpace status)
- ✅ Testat - alla services returnerar `{"status":"UP"}`

**Åtgärder:**

- [x] Aktivera Actuator endpoints i alla services
- [x] Exponera `/actuator/health`, `/actuator/info`, `/actuator/metrics`
- [x] Konfigurera `show-details=always` för health checks
- [ ] **TODO produktion:** Sätt upp Prometheus metrics collection
- [ ] **TODO produktion:** Konfigurera alerts för kritiska endpoints (Grafana/PagerDuty)
- [ ] **TODO produktion:** Dokumentera monitoring dashboard på svenska

**Konfiguration tillagd i alla application.properties:**

```properties
# Actuator Configuration (Health checks & Monitoring)
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always
```

**Testa health endpoints:**

```bash
# UserService
curl http://localhost:8081/actuator/health

# QuizService
curl http://localhost:8082/actuator/health

# ExamService
curl http://localhost:8083/actuator/health

# AdminService
curl http://localhost:8084/actuator/health

# PaymentService
curl http://localhost:8085/actuator/health

# API Gateway (inkluderar gateway routes)
curl http://localhost:8080/actuator/health
curl http://localhost:8080/actuator/gateway/routes

# Eureka Server
curl http://localhost:8761/actuator/health
```

**Health response format:**

```json
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"},           // Database connection
    "diskSpace": {"status": "UP"},    // Disk space monitoring
    "ping": {"status": "UP"},         // Basic availability
    "discoveryComposite": {           // Eureka service discovery
      "status": "UP",
      "details": {"services": [...]}
    }
  }
}
```

**Production monitoring rekommendationer:**

- Poll `/actuator/health` var 30:e sekund
- Alert om `status != "UP"`
- Alert om `diskSpace.details.free < 5GB`
- Alert om `db.status == "DOWN"`
- Använd Prometheus + Grafana för metrics dashboards
- Integrera med PagerDuty/Slack för incident alerts

---

### 9. Osäkra database konfigurationer

**Status:** ✅ KLAR  
**Prioritet:** ⚠️ VIKTIGT  
**Tid:** ~2 timmar  
**Genomfört:** 2026-03-17

**Problem:**

- ~~Tomt default DB password~~
- ~~Ingen connection pooling konfiguration~~
- ~~Ingen backup-strategi dokumenterad~~

**Resultat:**

- ✅ Tog bort osäkra fallback från `DB_PASSWORD` (app kraschar nu om password saknas)
- ✅ Konfigurerade HikariCP connection pooling i alla 5 database-services:
  - userService, adminService, paymentService, examService, quizService
  - maximum-pool-size: 10
  - minimum-idle: 5
  - connection-timeout: 20s
  - idle-timeout: 5 min
  - max-lifetime: 10 min
- ✅ Dokumenterade Azure Database for MySQL setup nedan
- ✅ 0 kompileringsfel efter ändringar

**Åtgärder:**

- [ ] Ta bort fallback från DB_PASSWORD (gör required)
- [ ] Konfigurera HikariCP connection pool (för lokal utveckling)
- [ ] Dokumentera Azure Database for MySQL setup
- [ ] Konfigurera Azure automatic backups

**Local Development - HikariCP konfiguration:**

```properties
# Connection Pooling (HikariCP)
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=20000
spring.datasource.hikari.idle-timeout=300000
spring.datasource.hikari.max-lifetime=600000
```

**Azure Production - Database Setup:**

1. **Skapa Azure Database for MySQL Flexible Server**
   - Välj tier: Burstable (B1ms) för start, skalbar senare
   - Region: North Europe (Stockholm) för låg latency
   - Backup retention: 7 dagar (gratis), kan öka till 35 dagar
   - High Availability: Optional (kostnad +100%)

2. **Säkerhet:**
   - Aktivera SSL/TLS enforcement
   - Konfigurera firewall: Endast Azure services
   - Använd Azure Key Vault för connection string

3. **Connection String (från Azure Key Vault):**

   ```
   jdbc:mysql://<server-name>.mysql.database.azure.com:3306/<database>?useSSL=true&requireSSL=true
   ```

4. **Automated Backups:**
   - Azure hanterar automatiska backups (ingen kod behövs)
   - Point-in-time restore tillgänglig
   - Geo-redundant backup optional

---

### 10. Ingen rate limiting

**Status:** ✅ KLAR  
**Prioritet:** ⚠️ VIKTIGT  
**Tid:** ~3 timmar  
**Genomfört:** 2026-03-28

**Problem:**

- ~~Oskyddad mot brute force~~
- ~~Ingen rate limit på login, register, payments~~
- ~~DDoS-sårbar~~

**Resultat:**

- ✅ Implementerade Bucket4j rate limiting i API Gateway
- ✅ Rate limits per endpoint:
  - **Login** (`POST /api/auth/login`): 5 försök/minut per IP
  - **Register** (`POST /api/users`): 2 försök/minut per IP
  - **Payments** (`POST /api/payments/**`): 10 försök/timme per userId
  - **Default** (alla andra): 100 requests/minut per IP
- ✅ Skapade `RateLimitConfig.java` med token bucket implementation
- ✅ Skapade `RateLimitFilter.java` som interceptar alla requests
- ✅ HTTP 429 Too Many Requests returneras vid överträdelse
- ✅ Response headers: `X-Rate-Limit-Remaining`, `X-Rate-Limit-Retry-After-Seconds`
- ✅ Testade alla endpoints - fungerar korrekt

**Implementerade filer:**

- `api-gateway/src/main/java/com/example/api_gateway/Config/RateLimitConfig.java`
- `api-gateway/src/main/java/com/example/api_gateway/Security/RateLimitFilter.java`

**Dependency tillagd:**

```xml
<dependency>
    <groupId>com.bucket4j</groupId>
    <artifactId>bucket4j-core</artifactId>
    <version>8.5.0</version>
</dependency>
```

**Använd:** Bucket4j med Token Bucket Algorithm

---

## 🟢 REKOMMENDATIONER (Kan vänta till efter lansering)

### 11. Docker + Azure Container Apps Deployment

**Status:** ❌ Ej påbörjad  
**Prioritet:** 💡 VIKTIGT FÖR CLOUD  
**Tid:** ~2-3 dagar

**Deployment Strategi: Azure Container Apps med Docker**

Vi använder Docker containers för flexibilitet och lägre kostnad.

**Fördelar:**

- ✅ Lägre kostnad (~500-800 SEK/månad vs ~1500 för Spring Apps)
- ✅ Mer flexibelt och portabelt
- ✅ Fungerar med vilken teknologi som helst
- ✅ Lätt att testa lokalt innan Azure deployment

**Fas 1: Dockerfiles (2-3 timmar)**

- [ ] Skapa `Dockerfile` för alla 7 microservices:
  - [ ] eureka-server
  - [ ] api-gateway
  - [ ] userService
  - [ ] adminService
  - [ ] paymentService
  - [ ] examService
  - [ ] quizService
- [ ] Skapa `.dockerignore` filer (exkludera target/, .env, etc)
- [ ] Skapa `docker-compose.yml` för lokal testning

**Fas 2: Lokal Docker Test (1 timme)**

- [ ] Bygga alla Docker images: `docker-compose build`
- [ ] Starta alla containers: `docker-compose up`
- [ ] Testa service discovery (Eureka)
- [ ] Testa inter-service communication
- [ ] Verifiera health checks

**Fas 3: Azure Setup (3-4 timmar)**

- [ ] Skapa Azure Resource Group
- [ ] Skapa Azure Container Registry (ACR)
- [ ] Pusha Docker images till ACR
- [ ] Skapa Azure Database for MySQL
- [ ] Skapa Azure Key Vault för secrets
- [ ] Skapa Container Apps Environment

**Fas 4: Azure Deployment (2-3 timmar)**

- [ ] Deploy eureka-server först (service discovery)
- [ ] Deploy api-gateway
- [ ] Deploy alla backend services (user, admin, payment, exam, quiz)
- [ ] Konfigurera environment variables från Key Vault
- [ ] Konfigurera health probes
- [ ] Sätt upp Azure Application Insights (monitoring)

**Fas 5: Frontend + Domain (1-2 timmar)**

- [ ] Deploy frontend till Azure Static Web Apps
- [ ] Konfigurera custom domain (optional)
- [ ] SSL/HTTPS certifikat (automatiskt via Azure)
- [ ] Uppdatera CORS för produktions-domän

**Swish Production:**

- Environment variables kan uppdateras senare när kunden ger credentials
- Ingen kod-ändring behövs, bara uppdatera Azure Key Vault secrets

---

### 12. CI/CD Pipeline med GitHub Actions + Azure

**Status:** ❌ Ej påbörjad  
**Prioritet:** 💡 NICE TO HAVE  
**Tid:** ~1 dag

**Azure DevOps Integration:**

**Åtgärder:**

- [ ] Skapa Azure Service Principal för GitHub Actions
- [ ] Lägg till Azure credentials i GitHub Secrets
- [ ] Skapa `.github/workflows/deploy-userservice.yml`
- [ ] Automated build + test on push
- [ ] Automated deploy till Azure on merge to main
- [ ] Skapa separate workflows för varje microservice

**GitHub Actions workflow exempel:**

```yaml
name: Deploy UserService to Azure
on:
  push:
    branches: [main]
    paths: ["userService/**"]
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 21
        uses: actions/setup-java@v3
      - name: Build with Maven
        run: mvn clean package
      - name: Deploy to Azure Spring Apps
        uses: azure/spring-apps-deploy@v1
        with:
          azure-credentials: ${{ secrets.AZURE_CREDENTIALS }}
          service-name: traffic-school-userservice
```

---

### 13. Frontend deployment till Azure Static Web Apps

**Status:** ❌ Ej påbörjad  
**Prioritet:** 💡 VIKTIGT FÖR PROD  
**Tid:** ~2 timmar

**Problem:**

- BASE_URL hårdkodad till localhost:8080
- Ingen production frontend hosting

**Azure Static Web Apps fördelar:**

- Gratis SSL/HTTPS
- Global CDN (snabb över hela världen)
- GitHub integration
- Automatisk deployment
- Custom domain support

**Åtgärder:**

- [ ] Skapa Azure Static Web App
- [ ] Konfigurera Vite environment variables
- [ ] Läs BASE_URL från import.meta.env.VITE_API_URL
- [ ] Skapa .env.production med Azure API Gateway URL
- [ ] Deploy via GitHub Actions
- [ ] Konfigurera custom domain (optional)

**Environment config:**

```bash
# .env.development
VITE_API_URL=http://localhost:8080

# .env.production
VITE_API_URL=https://trafficschool-api.azurewebsites.net
```

---

### 14. Load testing

**Status:** ❌ Ej påbörjad  
**Prioritet:** 💡 NICE TO HAVE  
**Tid:** ~4 timmar

**Åtgärder:**

- [ ] Kör JMeter load tests
- [ ] Testa 100 samtidiga användare
- [ ] Identifiera flaskhalsar

---

### 15. API dokumentation

**Status:** ❌ Ej påbörjad  
**Prioritet:** 💡 NICE TO HAVE  
**Tid:** ~4 timmar

**Åtgärder:**

- [ ] Lägg till SpringDoc OpenAPI
- [ ] Generera Swagger UI
- [ ] Dokumentera alla endpoints

---

## 📝 DEPLOYMENT TIMELINE

### ⏱️ Omedelbart (idag)

1. ✅ Ta bort .env från git
2. ✅ Ta bort hårdkodad API key
3. ✅ Lägg till .env i .gitignore

### 📅 Denna vecka (före deploy)

1. ✅ Generera säkra secrets (JWT, API keys)
2. ✅ Konfigurera environment variables
3. ✅ Fixa CORS för produktion
4. ✅ Ersätt System.out med logging

### 🚀 Vecka 1 - Förbered för cloud

1. ✅ Implementera email service (SendGrid)
2. ✅ Aktivera monitoring (Actuator)
3. ✗ Database säkerhet & pooling
4. ✗ Rate limiting (API Gateway)
5. ✗ Frontend environment config

### ☁️ Vecka 2-3 - Azure Deployment

1. ✗ Skapa Azure account & Resource Group
2. ✗ Sätt upp Azure Database for MySQL
3. ✗ Konfigurera Azure Key Vault (secrets)
4. ✗ Deploy backend services (Azure Spring Apps eller Container Apps)
5. ✗ Deploy frontend (Azure Static Web Apps)
6. ✗ Konfigurera custom domain & SSL
7. ✗ Sätt upp CI/CD (GitHub Actions)
8. ✗ Konfigurera Application Insights (monitoring)

### 🔮 Efter lansering

1. ✗ Konfigurera Swish produktion credentials
2. ✗ Load testing mot Azure
3. ✗ API dokumentation (Swagger/OpenAPI)
4. ✗ Sätt upp alerting (PagerDuty/Email)

---

## ☁️ AZURE DEPLOYMENT ÖVERSIKT

### Tjänster som behövs:

| Tjänst                     | Syfte                   | Månadskostnad (ca)  |
| -------------------------- | ----------------------- | ------------------- |
| Azure Spring Apps (Basic)  | 7 microservices hosting | ~1500 SEK           |
| Azure Database for MySQL   | Managed database        | ~500 SEK            |
| Azure Key Vault            | Secrets management      | ~50 SEK             |
| Azure Static Web Apps      | Frontend hosting        | Gratis              |
| Azure Application Insights | Monitoring & logs       | ~200 SEK            |
| **TOTALT**                 |                         | **~2250 SEK/månad** |

**Alternativ (billigare):**

- Azure Container Apps istället för Spring Apps: ~800 SEK
- **Total kostnad då:** ~1550 SEK/månad

### Setup steg-för-steg:

1. **Skapa Azure konto:**
   - Gå till https://azure.microsoft.com/
   - Student account ger gratis credits (100 USD)
2. **Installera Azure CLI:**

   ```bash
   # Windows (PowerShell)
   winget install Microsoft.AzureCLI

   # Logga in
   az login
   ```

3. **Skapa Resource Group:**

   ```bash
   az group create --name TrafficSchool-RG --location northeurope
   ```

4. **Dokumentation fortsätter i Step 11...**

---

## � DEPLOYMENT GUIDE: FRÅN LOCALHOST TILL PRODUKTION

**En pedagogisk guide för att förstå hela deployment-processen**

---

### 🎓 DEL 1: GRUNDLÄGGANDE KONCEPT

#### 🏠 Vad är Localhost?

**Kort svar:** Din egen dator som en server.

**Lång förklaring:**

```
Localhost = 127.0.0.1 = Din egen dator

När du kör:
http://localhost:8080 → Din dator lyssnar på port 8080
http://localhost:8081 → Din dator lyssnar på port 8081

Problemet:
- Bara DU kan nå dessa adresser
- Ingen annan i världen kan besöka localhost:8080
- Det finns på din dator, inte på internet
```

**Exempel:**

```
Din dator (localhost):
├─ Eureka Server    http://localhost:8761
├─ API Gateway      http://localhost:8080  ← Bara du kan nå detta
├─ UserService      http://localhost:8081
├─ QuizService      http://localhost:8082
└─ Frontend         http://localhost:5173

Någon annan (din kompis):
❌ http://localhost:8080 → Går till HANS dator, inte din!
```

---

#### 🌍 Vad är en Domän?

**Kort svar:** En adress på internet som alla kan nå.

**Lång förklaring:**

```
Domän = Ett namn som pekar på en server någonstans på internet

Exempel:
www.google.com    → Googles servrar
www.facebook.com  → Facebooks servrar
trafficschool.se  → DIN framtida server (Azure)

Hur det fungerar:
1. Användare skriver: www.trafficschool.se
2. DNS (Domain Name System) översätter det till: 51.124.45.78 (IP-adress)
3. Webbläsaren kontaktar servern på 51.124.45.78
4. Servern skickar tillbaka din hemsida
```

**Skillnaden:**

```
DEVELOPMENT (localhost):
Frontend:   http://localhost:5173
Backend:    http://localhost:8080
✅ Fungerar: Bara på din dator
❌ Problem: Ingen annan kan testa

PRODUCTION (domän):
Frontend:   https://www.trafficschool.se
Backend:    https://api.trafficschool.se
✅ Fungerar: Alla i hela världen kan nå det
✅ HTTPS: Krypterad (säker)
```

---

#### 🔄 Hur Hänger Allt Ihop i Produktion?

**DEVELOPMENT (Nu - På din dator):**

```
Din Dator (localhost)
┌─────────────────────────────────────┐
│                                     │
│  Frontend (localhost:5173)          │
│      ↓                              │
│  API Gateway (localhost:8080)       │
│      ↓                              │
│  Eureka (localhost:8761)            │
│      ↓                              │
│  7 Microservices (8081-8085)        │
│      ↓                              │
│  MySQL (localhost:3306)             │
│                                     │
└─────────────────────────────────────┘

✅ Allt på samma dator
✅ Snabb kommunikation
❌ Bara du kan nå det
```

**PRODUCTION (Azure - På internet):**

```
Internet Users
      ↓
┌──────────────────────────────────────────────────┐
│  Din Domän: www.trafficschool.se                 │
│  (DNS pekar på Azure Static Web Apps)            │
└──────────────────────────────────────────────────┘
      ↓
┌──────────────────────────────────────────────────┐
│  Azure Static Web Apps (Frontend)                │
│  https://www.trafficschool.se                    │
│  - React app (byggd med: npm run build)          │
│  - Global CDN (snabb överallt)                   │
│  - Konfigurerad med:                             │
│    VITE_API_BASE_URL=https://api.trafficschool.se│
└──────────────────────────────────────────────────┘
      ↓ (API calls)
┌──────────────────────────────────────────────────┐
│  Din Subdomän: api.trafficschool.se              │
│  (DNS pekar på Azure Load Balancer)              │
└──────────────────────────────────────────────────┘
      ↓
┌──────────────────────────────────────────────────┐
│  Azure Container Apps / Spring Apps              │
│                                                  │
│  API Gateway (api.trafficschool.se)              │
│      ↓                                           │
│  Eureka Server (intern: eureka-server:8761)      │
│      ↓                                           │
│  7 Microservices (Docker containers)             │
│  ├─ user-service                                 │
│  ├─ admin-service                                │
│  ├─ payment-service                              │
│  ├─ exam-service                                 │
│  ├─ quiz-service                                 │
│  ├─ api-gateway                                  │
│  └─ eureka-server                                │
└──────────────────────────────────────────────────┘
      ↓
┌──────────────────────────────────────────────────┐
│  Azure Database for MySQL                        │
│  trafficschool-db.mysql.database.azure.com       │
│  - userServiceDb                                 │
│  - adminServiceDb                                │
│  - paymentServiceDb                              │
│  - examServiceDb                                 │
│  - quizServiceDb                                 │
│                                                  │
│  ✅ Automatiska backups                          │
│  ✅ SSL/TLS kryptering                           │
│  ✅ High availability                            │
└──────────────────────────────────────────────────┘

✅ Tillgängligt globalt
✅ HTTPS kryptering
✅ Auto-scaling
✅ Monitoring
```

---

### 🎯 DEL 2: VAD BEHÖVS FRÅN KUNDEN?

**Checklista för kunden innan production deployment:**

#### 1️⃣ **Domännamn** (KRITISKT)

**Vad är det?**
Webbplatsens adress (t.ex. trafficschool.se)

**Alternativ:**

**A) Kunden HAR redan en domän:**

```
Exempel: kunden äger "korhjalpen.se"

Du behöver:
1. Tillgång till domänens DNS-inställningar
   (Vanliga registrars: Loopia, Binero, GoDaddy, Namecheap)

2. Kundens inloggning till DNS-panelen, ELLER
   Kunden lägger till dessa DNS-poster:

   Record Type: CNAME
   Name:        www
   Value:       trafficschool-frontend.azurestaticapps.net
   TTL:         3600

   Record Type: CNAME
   Name:        api
   Value:       trafficschool-api.azurewebsites.net
   TTL:         3600

   Record Type: A (eller CNAME för @)
   Name:        @
   Value:       51.124.45.78 (Azures IP-adress)
   TTL:         3600
```

**B) Kunden HAR INTE en domän:**

```
Köp domän via:
- Loopia.se (Svensk, rekommenderad): ~100 SEK/år för .se
- Binero.se (Svensk): ~150 SEK/år
- Namecheap.com (Internationell, billig): ~$10/år

Rekommendation:
- Köp .se om svenskt företag (trovärdigt)
- Köp .com om internationellt

Efter köp:
- Du får tillgång till DNS-panel
- Konfigurera enligt steg A ovan
```

**C) Kunden vill ha GRATIS (temporärt för test):**

```
Azure ger gratis subdomäner:

Frontend: trafficschool-app.azurestaticapps.net
Backend:  trafficschool-api.azurewebsites.net

✅ Fungerar direkt, inget DNS-setup
❌ Ser oprofessionellt ut
❌ Kan inte användas för produktion

Användning: Endast för demo/test innan riktig domän köps
```

#### 2️⃣ **Swish Produktion Credentials** (KRITISKT för betalningar)

**Vad du har nu:**

```
Nuvarande: Swish TEST miljö
- Base URL: https://mss.cpc.getswish.net (test)
- Merchant number: 1234679304 (test-nummer)
- Certifikat: Test-certifikat (Swish_Merchant_TestCertificate_1234679304.p12)

✅ Fungerar för utveckling
❌ Kan INTE användas i produktion (riktiga pengar)
```

**Vad kunden måste fixa från sin bank:**

**Steg 1: Ansök om Swish Handel (hos kundens bank)**

```
Kunden kontaktar sin bank:
- Swedbank
- Handelsbanken
- SEB
- Nordea
- etc.

Säger: "Jag vill ha Swish Handel för mitt företag"

Banken frågar:
1. Organisationsnummer
2. Företagsnamn
3. Kontaktperson
4. Förväntat transaktionsvolym
5. Hemsida/affärsidé

Kostnad: ~0-500 SEK/månad (beror på bank)
Tid: 1-2 veckor handläggningstid
```

**Steg 2: Få produktions-credentials från Swish**

```
Efter godkännande får kunden från banken:

1. PRODUKTIONS CERTIFIKAT (.p12 fil)
   Exempel: Swish_Merchant_PROD_1231181189.p12
   + Certifikatets lösenord

2. MERCHANT NUMBER (Betalningsmottagarnummer)
   Exempel: 1231181189 (riktigt handelsnummer)

3. Swish PRODUKTION base URL:
   https://cpc.getswish.net/swish-cpcapi/api/v2/
   (Notera: INTE "mss" i början som test-miljön)

4. Callback URL krav:
   - MÅSTE vara HTTPS (inte HTTP)
   - MÅSTE vara publikt nåbar
   - Exempel: https://api.trafficschool.se/api/webhooks/swish
```

**Steg 3: Upload till Azure Key Vault**

```
När du har certifikatet:

1. Ladda upp till Azure Key Vault:
   az keyvault certificate import \
     --vault-name trafficschool-vault \
     --name swish-production-cert \
     --file Swish_Merchant_PROD_1231181189.p12 \
     --password [certifikatets lösenord]

2. Uppdatera environment variables:
   SWISH_BASE_URL=https://cpc.getswish.net/swish-cpcapi/api/v2/
   SWISH_MERCHANT_NUMBER=1231181189
   SWISH_CALLBACK_URL=https://api.trafficschool.se/api/webhooks/swish
   SWISH_KEYSTORE_PASSWORD=[från Azure Key Vault]
```

**⚠️ VIKTIGT: Vad händer om kunden INTE har Swish credentials vid launch?**

```
Alternativ 1: Lansera utan betalningar
- Kommentera ut Swish-konfiguration
- Använd "fake payment" för test
- Lägg till riktiga betalningar senare

Alternativ 2: Använd annan betalmetod
- Stripe (enklare, inget bank-krav)
- Klarna Checkout
- PayPal

Alternativ 3: Vänta med lansering
- Kunden fixar Swish först
- Då lanserar ni med alla features
```

#### 3️⃣ **SendGrid Production Tier** (För email)

**Vad du har nu:**

```
SendGrid Free Tier:
✅ 100 emails/dag
✅ Fungerar för utveckling
⚠️ Kan vara för lite i produktion
```

**Om fler emails behövs:**

```
SendGrid Essentials Plan: $19.95/månad
- 50,000 emails/månad
- Email support
- Bättre deliverability

Vad kunden ska göra:
1. Logga in på SendGrid (med samma konto)
2. Gå till: Settings → Plan & Billing
3. Uppgradera till Essentials
4. Ingen kodändring behövs! Samma API key fungerar.
```

#### 4️⃣ **Azure Konto & Payment Method**

**Vad kunden behöver:**

```
1. Skapa Azure konto:
   https://azure.microsoft.com/

2. Lägg till betalmetod (kreditkort)
   - Kostnad: ~1500-2500 SEK/månad (beroende på traffic)

3. Verifiera email & identity

4. Ge dig (utvecklaren) access:
   - Owner eller Contributor role
   - På subscription-nivå
```

---

### 🚀 DEL 3: DEPLOYMENT WORKFLOW (Steg-för-steg)

#### **FÖRE DEPLOYMENT - Preparation Checklist**

```
✅ Checklist innan ni startar deployment:

1. Kod klar:
   ✅ Alla features implementerade
   ✅ Alla tester passar
   ✅ Inga compilation errors
   ✅ Security audit genomförd

2. Domän klar:
   ✅ Domän registrerad
   ✅ DNS-access tillgänglig
   ELLER
   ✅ Kunden okej med temporär Azure-domän för soft launch

3. Swish beslut taget:
   ✅ Produktions-credentials mottagna, ELLER
   ✅ Plan för att lansera utan betalningar först, ELLER
   ✅ Alternativ betalmetod vald (Stripe, etc.)

4. Azure konto:
   ✅ Azure account skapat
   ✅ Betalmetod tillagd
   ✅ Du har Owner/Contributor access

5. Secrets documented:
   ✅ JWT_SECRET genererad och sparad säkert
   ✅ SERVICE_API_KEY genererad och sparad
   ✅ SendGrid API key dokumenterad
   ✅ Database passwords genererade (stark: 32+ tecken)
```

---

#### **STEG 1: DEVELOPMENT TEST (Din dator)**

**Tid:** 30 minuter  
**Syfte:** Verifiera att allt fungerar lokalt innan deployment

```bash
# 1. Starta alla services
cd eureka-server
mvn spring-boot:run

cd api-gateway
mvn spring-boot:run

cd userService
mvn spring-boot:run

# ... (starta alla 7 services)

cd Frontend/frontend
npm run dev

# 2. Testa viktiga flöden:
- ✅ Registrering fungerar
- ✅ Login fungerar
- ✅ Quiz fungerar
- ✅ Exam fungerar
- ✅ Admin panel fungerar
- ⚠️ Swish (test-certifikat, fungerar i test)

# 3. Kolla health checks:
curl http://localhost:8081/actuator/health  # UserService
curl http://localhost:8080/actuator/health  # API Gateway
# Alla ska returnera: {"status":"UP"}

# 4. Kolla Eureka Dashboard:
http://localhost:8761
# Alla 6 services ska vara registrerade
```

---

#### **STEG 2: DOCKER BUILD (Lokalt test)**

**Tid:** 2 timmar  
**Syfte:** Bygg Docker images och testa lokalt

```bash
# 1. Skapa Dockerfiles (ska göras i nästa steg)

# 2. Build Docker images
cd userService
docker build -t trafficschool/user-service:latest .

cd adminService
docker build -t trafficschool/admin-service:latest .

# ... (bygg alla 7 services)

# 3. Test med Docker Compose
docker-compose up

# 4. Testa att containers kommunicerar:
docker ps  # Alla containers ska vara "Up"
curl http://localhost:8080/actuator/health

# 5. Troubleshooting:
docker logs user-service     # Om något inte fungerar
docker exec -it user-service sh  # Gå in i container
```

---

#### **STEG 3: AZURE SETUP**

**Tid:** 3 timmar  
**Syfte:** Skapa alla Azure-resurser

```bash
# 1. Logga in
az login

# 2. Skapa Resource Group
az group create \
  --name TrafficSchool-RG \
  --location northeurope

# 3. Skapa Container Registry (för Docker images)
az acr create \
  --name trafficschoolregistry \
  --resource-group TrafficSchool-RG \
  --sku Basic \
  --admin-enabled true

# 4. Skapa Database
az mysql flexible-server create \
  --name trafficschool-db \
  --resource-group TrafficSchool-RG \
  --location northeurope \
  --admin-user trafficadmin \
  --admin-password [STRONG-PASSWORD-HERE] \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 8.0

# 5. Skapa databaser
az mysql flexible-server db create \
  --server-name trafficschool-db \
  --resource-group TrafficSchool-RG \
  --database-name userServiceDb

# Upprepa för: adminServiceDb, paymentServiceDb, examServiceDb, quizServiceDb

# 6. Skapa Key Vault (för secrets)
az keyvault create \
  --name trafficschool-vault \
  --resource-group TrafficSchool-RG \
  --location northeurope

# 7. Lägg till secrets
az keyvault secret set \
  --vault-name trafficschool-vault \
  --name JWT-SECRET \
  --value [DIN-JWT-SECRET]

az keyvault secret set \
  --vault-name trafficschool-vault \
  --name DB-PASSWORD \
  --value [DATABASE-PASSWORD]

# ... (lägg till alla secrets)

# 8. Skapa Container Apps Environment
az containerapp env create \
  --name trafficschool-env \
  --resource-group TrafficSchool-RG \
  --location northeurope
```

---

#### **STEG 4: DOCKER PUSH TO AZURE**

**Tid:** 1 timme  
**Syfte:** Push Docker images till Azure Container Registry

```bash
# 1. Login till Container Registry
az acr login --name trafficschoolregistry

# 2. Tag images med registry URL
docker tag trafficschool/user-service:latest \
  trafficschoolregistry.azurecr.io/user-service:latest

docker tag trafficschool/admin-service:latest \
  trafficschoolregistry.azurecr.io/admin-service:latest

# ... (tag alla services)

# 3. Push images
docker push trafficschoolregistry.azurecr.io/user-service:latest
docker push trafficschoolregistry.azurecr.io/admin-service:latest
# ... (push alla)

# 4. Verifiera att images finns:
az acr repository list --name trafficschoolregistry
```

---

#### **STEG 5: DEPLOY BACKEND TO AZURE**

**Tid:** 4 timmar  
**Syfte:** Deploy alla microservices

```bash
# 1. Deploy Eureka Server FÖRST (andra services behöver den)
az containerapp create \
  --name eureka-server \
  --resource-group TrafficSchool-RG \
  --environment trafficschool-env \
  --image trafficschoolregistry.azurecr.io/eureka-server:latest \
  --target-port 8761 \
  --ingress external \
  --registry-server trafficschoolregistry.azurecr.io \
  --env-vars \
    SERVER_PORT=8761

# Vänta 2-3 minuter tills Eureka startat

# 2. Deploy API Gateway
az containerapp create \
  --name api-gateway \
  --resource-group TrafficSchool-RG \
  --environment trafficschool-env \
  --image trafficschoolregistry.azurecr.io/api-gateway:latest \
  --target-port 8080 \
  --ingress external \
  --env-vars \
    EUREKA_URL="http://eureka-server:8761/eureka/" \
    JWT_SECRET="secretref:jwt-secret" \
    SERVICE_API_KEY="secretref:service-api-key"

# 3. Deploy UserService
az containerapp create \
  --name user-service \
  --resource-group TrafficSchool-RG \
  --environment trafficschool-env \
  --image trafficschoolregistry.azurecr.io/user-service:latest \
  --target-port 8081 \
  --ingress internal \
  --env-vars \
    EUREKA_URL="http://eureka-server:8761/eureka/" \
    DB_URL="jdbc:mysql://trafficschool-db.mysql.database.azure.com:3306/userServiceDb?useSSL=true" \
    DB_USERNAME="trafficadmin" \
    DB_PASSWORD="secretref:db-password" \
    JWT_SECRET="secretref:jwt-secret" \
    SERVICE_API_KEY="secretref:service-api-key" \
    SENDGRID_API_KEY="secretref:sendgrid-api-key" \
    SENDGRID_FROM_EMAIL="noreply@trafficschool.se" \
    SENDGRID_FROM_NAME="Traffic School"

# ... (Upprepa för alla andra services: adminService, paymentService, etc.)

# 4. Verifiera deployment:
az containerapp list --resource-group TrafficSchool-RG --output table

# 5. Testa health checks:
curl https://[API-GATEWAY-URL]/actuator/health
```

---

#### **STEG 6: DEPLOY FRONTEND TO AZURE**

**Tid:** 1 timme  
**Syfte:** Deploy React frontend

```bash
# 1. Bygg production version
cd Frontend/frontend

# 2. Uppdatera .env.production med riktig API URL:
# .env.production:
VITE_API_BASE_URL=https://[DIN-API-GATEWAY-URL].azurewebsites.net

# 3. Bygg
npm run build

# 4. Deploy till Azure Static Web Apps
az staticwebapp create \
  --name trafficschool-frontend \
  --resource-group TrafficSchool-RG \
  --location westeurope \
  --source ./dist \
  --branch main

# 5. Få frontend URL:
az staticwebapp show \
  --name trafficschool-frontend \
  --resource-group TrafficSchool-RG \
  --query "defaultHostname" \
  --output tsv

# Output exempel: trafficschool-frontend.azurestaticapps.net
```

---

#### **STEG 7: KONFIGURERA CUSTOM DOMAIN (Om kunden har domän)**

**Tid:** 30 minuter  
**Syfte:** Koppla riktig domän till Azure

**A) Frontend (www.trafficschool.se):**

```bash
# 1. Lägg till custom domain i Azure
az staticwebapp hostname set \
  --name trafficschool-frontend \
  --resource-group TrafficSchool-RG \
  --hostname www.trafficschool.se

# 2. Azure visar dig DNS-poster att lägga till:
# Gå till kundens domän-registrar (Loopia, Binero, etc.) och lägg till:

Record Type: CNAME
Name:        www
Value:       trafficschool-frontend.azurestaticapps.net
TTL:         3600

# 3. Vänta 10-60 minuter (DNS propagation)

# 4. Azure skapar automatiskt SSL-certifikat (HTTPS)
```

**B) Backend API (api.trafficschool.se):**

```bash
# 1. Lägg till custom domain till API Gateway
az containerapp hostname add \
  --name api-gateway \
  --resource-group TrafficSchool-RG \
  --hostname api.trafficschool.se

# 2. Lägg till DNS-post:

Record Type: CNAME
Name:        api
Value:       [API-GATEWAY-URL från Azure]
TTL:         3600

# 3. Bind SSL certificate (kräver domain verification)
az containerapp hostname bind \
  --name api-gateway \
  --resource-group TrafficSchool-RG \
  --hostname api.trafficschool.se \
  --environment trafficschool-env \
  --validation-method CNAME
```

**C) Uppdatera Frontend .env.production:**

```bash
# Nu när du har custom domain:
# .env.production:
VITE_API_BASE_URL=https://api.trafficschool.se

# Re-build och re-deploy frontend:
npm run build
az staticwebapp upload --name trafficschool-frontend --source ./dist
```

---

#### **STEG 8: SWISH PRODUCTION SETUP (Om credentials finns)**

**Tid:** 1 timme  
**Syfte:** Aktivera riktiga betalningar

```bash
# 1. Upload Swish production certificate till Key Vault
az keyvault certificate import \
  --vault-name trafficschool-vault \
  --name swish-production-cert \
  --file Swish_Merchant_PROD_[NUMBER].p12 \
  --password [CERT-PASSWORD]

# 2. Uppdatera PaymentService environment variables
az containerapp update \
  --name payment-service \
  --resource-group TrafficSchool-RG \
  --set-env-vars \
    SWISH_BASE_URL="https://cpc.getswish.net/swish-cpcapi/api/v2/" \
    SWISH_MERCHANT_NUMBER="[RIKTIGT-NUMMER]" \
    SWISH_CALLBACK_URL="https://api.trafficschool.se/api/webhooks/swish" \
    SWISH_KEYSTORE_PASSWORD="secretref:swish-cert-password"

# 3. Restart PaymentService
az containerapp restart \
  --name payment-service \
  --resource-group TrafficSchool-RG

# 4. Testa Swish payment i production
# Använd riktig Swish-app med riktiga pengar (test med 1 kr först!)
```

---

#### **STEG 9: MONITORING & ALERTING**

**Tid:** 2 timmar  
**Syfte:** Sätt upp monitoring för production

```bash
# 1. Skapa Application Insights
az monitor app-insights component create \
  --app trafficschool-insights \
  --location northeurope \
  --resource-group TrafficSchool-RG

# 2. Få Instrumentation Key
az monitor app-insights component show \
  --app trafficschool-insights \
  --resource-group TrafficSchool-RG \
  --query "instrumentationKey" \
  --output tsv

# 3. Lägg till Application Insights till alla Container Apps
az containerapp update \
  --name user-service \
  --resource-group TrafficSchool-RG \
  --set-env-vars \
    APPLICATIONINSIGHTS_CONNECTION_STRING="[CONNECTION-STRING]"

# Upprepa för alla services

# 4. Konfigurera Alerts i Azure Portal:
- CPU > 80% i 5 minuter → Email alert
- Memory > 90% → Email alert
- Error rate > 5% → Email alert
- Database connection failures → Email alert
```

---

### 🎯 DEL 4: POST-DEPLOYMENT CHECKLIST

**Efter deployment - Verifiera att allt fungerar:**

```
✅ Frontend:
1. Besök: https://www.trafficschool.se (eller Azure-URL)
2. Testa registrering
3. Testa login
4. Testa quiz
5. Testa exam
6. Testa admin panel
7. Kolla browser console för errors

✅ Backend:
1. Testa health checks:
   curl https://api.trafficschool.se/actuator/health

2. Kolla Eureka Dashboard:
   https://[eureka-url]/

   Alla 6 services ska vara "UP"

3. Testa API endpoints:
   curl https://api.trafficschool.se/api/auth/health

✅ Database:
1. Logga in på Azure Portal
2. Kolla "Monitoring" → "Metrics"
3. Verifiera connections < 10 per service
4. Kolla query performance

✅ Monitoring:
1. Öppna Application Insights i Azure Portal
2. Kolla "Live Metrics" (real-time)
3. Verifiera att alla services syns
4. Kolla error logs

✅ Email (SendGrid):
1. Registrera ny användare
2. Kolla att welcome email kommer
3. Test magic link login
4. Verifiera i SendGrid dashboard att emails skickats

✅ Swish (om production):
1. Gör test-betalning (1 kr)
2. Kolla att callback kommer
3. Verifiera i Swish admin panel
4. Refund test-betalning

✅ Security:
1. Testa HTTPS fungerar (grönt hänglås i browser)
2. Verifiera JWT expiration fungerar
3. Testa rate limiting (om implementerat)
4. Kolla CORS settings
```

---

### 📋 DEL 5: MAINTENANCE & UPDATES

**Hur uppdaterar man efter deployment?**

#### **AUTOMATISK DEPLOYMENT (CI/CD med GitHub Actions)**

```yaml
# .github/workflows/deploy-userservice.yml

name: Deploy UserService to Azure
on:
  push:
    branches: [main]
    paths:
      - "userService/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build JAR
        run: |
          cd userService
          mvn clean package -DskipTests

      - name: Build Docker image
        run: |
          docker build -t trafficschoolregistry.azurecr.io/user-service:${{ github.sha }} userService/

      - name: Push to ACR
        run: |
          az acr login --name trafficschoolregistry
          docker push trafficschoolregistry.azurecr.io/user-service:${{ github.sha }}

      - name: Deploy to Azure Container Apps
        run: |
          az containerapp update \
            --name user-service \
            --resource-group TrafficSchool-RG \
            --image trafficschoolregistry.azurecr.io/user-service:${{ github.sha }}

# Nu: Push till GitHub → Automatisk deployment! 🚀
```

#### **MANUELL UPDATE (Om något går fel)**

```bash
# 1. Bygg ny version
cd userService
mvn clean package

# 2. Bygg Docker image
docker build -t trafficschoolregistry.azurecr.io/user-service:v2 .

# 3. Push
docker push trafficschoolregistry.azurecr.io/user-service:v2

# 4. Update Azure Container App
az containerapp update \
  --name user-service \
  --resource-group TrafficSchool-RG \
  --image trafficschoolregistry.azurecr.io/user-service:v2

# 5. Verifiera
az containerapp logs show --name user-service --resource-group TrafficSchool-RG
```

---

### 🚨 DEL 6: TROUBLESHOOTING GUIDE

**Vanliga problem och lösningar:**

#### **Problem: "Frontend kan inte nå backend"**

```
Symptom:
- Frontend visar "Network Error"
- Browser console: "ERR_CONNECTION_REFUSED"

Lösningar:
1. Kolla VITE_API_BASE_URL i .env.production
   - Ska vara: https://api.trafficschool.se
   - INTE: http://localhost:8080

2. Verifiera API Gateway körs:
   curl https://api.trafficschool.se/actuator/health

3. Kolla CORS settings i API Gateway
   - Lägg till din frontend domain i allowedOrigins

4. Kolla Azure logs:
   az containerapp logs show --name api-gateway --resource-group TrafficSchool-RG
```

#### **Problem: "Services kan inte hitta varandra"**

```
Symptom:
- Eureka Dashboard visar 0 services
- Services loggar: "Cannot resolve service name"

Lösningar:
1. Kolla Eureka URL i varje service:
   EUREKA_URL=http://eureka-server:8761/eureka/

   OBS: Använd service NAME (eureka-server), inte localhost!

2. Verifiera Eureka körs:
   curl https://[eureka-url]:8761/

3. Restart alla services (Eureka först, sedan resten)
```

#### **Problem: "Database connection failed"**

```
Symptom:
- Services loggar: "Communications link failure"
- Health check visar: db: DOWN

Lösningar:
1. Kolla DB_URL:
   jdbc:mysql://trafficschool-db.mysql.database.azure.com:3306/userServiceDb?useSSL=true

2. Kolla firewall rules i Azure Portal:
   - Tillåt "Azure Services"
   - Eller whitelist Container Apps IP

3. Testa connection från Azure Cloud Shell:
   mysql -h trafficschool-db.mysql.database.azure.com -u trafficadmin -p

4. Kolla HikariCP logs:
   Se efter "maximum-pool-size" i logs
```

#### **Problem: "Swish payments inte fungerar"**

```
Symptom:
- 500 error vid betalning
- Swish callback kommer aldrig

Lösningar:
1. Kolla certifikat är korrekt:
   - Production cert för production
   - Test cert för test

2. Verifiera callback URL:
   - MÅSTE vara HTTPS
   - MÅSTE vara publikt nåbar
   - Test: curl https://api.trafficschool.se/api/webhooks/swish

3. Kolla Swish logs i Azure:
   az containerapp logs show --name payment-service | grep -i swish

4. Kontakta Swish support om allt annat fungerar
```

---

## �🔗 Related Documentation

- [Architecture Overview](./01-Architecture/Architecture.md)
- [Security Guide](./02-Security/Security.md)
- [Services Documentation](./03-Services/)

---

## 📞 Contact & Support

**Vid frågor kontakta:**

- Tech Lead: [Namn]
- DevOps: [Namn]
- Security: [Namn]

---

**⚠️ VIKTIGT:** Uppdatera detta dokument när du bockar av items. Håll det levande!
