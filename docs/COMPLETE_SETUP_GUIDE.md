# 🚀 STEG-FÖR-STEG GUIDE - TrafficSchool

**Datum:** 2026-04-03  
**Mål:** Få allt att fungera lokalt → Deploya till Railway

---

# DEL 1: LOKAL UTVECKLING ✅

## STEG 1: Uppdatera .env-filer med dina riktiga värden

### 1.1 Uppdatera SendGrid API Key

Öppna `userService\.env` och uppdatera denna rad:

```bash
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Ersätt `ÄNDRA_TILL_DIN_SENDGRID_API_KEY` med din riktiga SendGrid API key.

### 1.2 Kontrollera MySQL lösenord

Om ditt MySQL root-lösenord INTE är "root", uppdatera `DB_PASSWORD` i dessa filer:

- `userService\.env`
- `adminService\.env`
- `paymentService\.env`
- `quizService\.env`
- `examService\.env`

## STEG 2: Skapa MySQL databaser

Öppna **PowerShell** och kör:

```powershell
# Anslut till MySQL
mysql -u root -p
```

Kör dessa SQL-kommandon:

```sql
CREATE DATABASE IF NOT EXISTS userServiceDb;
CREATE DATABASE IF NOT EXISTS adminServiceDb;
CREATE DATABASE IF NOT EXISTS paymentServiceDb;
CREATE DATABASE IF NOT EXISTS quizServiceDb;
CREATE DATABASE IF NOT EXISTS examservicedb;

-- Visa att de skapades
SHOW DATABASES;

-- Avsluta MySQL
EXIT;
```

**ELLER** använd SQL-skripten (om de finns):

```powershell
cd C:\src\projects\TrafficSchool
mysql -u root -p < SQL\userServiceDb.sql
mysql -u root -p < SQL\adminServiceDb.sql
mysql -u root -p < SQL\paymentServiceDb.sql
mysql -u root -p < SQL\quizServiceDb.sql
mysql -u root -p < SQL\examServiceDb.sql
```

## STEG 3: Starta Eureka Server

Öppna **Terminal 1** i VS Code eller PowerShell:

```powershell
cd C:\src\projects\TrafficSchool\eureka-server
.\mvnw.cmd clean spring-boot:run
```

**Vänta tills du ser:** `Started EurekaServerApplication`

**Testa:** Öppna http://localhost:8761 i webbläsaren.

Du ska se Eureka Dashboard (inga services registrerade ännu).

---

## STEG 4: Starta Backend Services (5 terminaler)

### Terminal 2 - User Service

```powershell
cd C:\src\projects\TrafficSchool\userService
.\mvnw.cmd clean spring-boot:run
```

**Vänta på:** `Started UserServiceApplication` (port 8081)

### Terminal 3 - Admin Service

```powershell
cd C:\src\projects\TrafficSchool\adminService
.\mvnw.cmd clean spring-boot:run
```

**Vänta på:** `Started AdminServiceApplication` (port 8084)

### Terminal 4 - Payment Service

```powershell
cd C:\src\projects\TrafficSchool\paymentService
.\mvnw.cmd clean spring-boot:run
```

**Vänta på:** `Started PaymentServiceApplication` (port 8085)

### Terminal 5 - Quiz Service

```powershell
cd C:\src\projects\TrafficSchool\quizService
.\mvnw.cmd clean spring-boot:run
```

**Vänta på:** `Started QuizServiceApplication` (port 8082)

### Terminal 6 - Exam Service

```powershell
cd C:\src\projects\TrafficSchool\examService
.\mvnw.cmd clean spring-boot:run
```

**Vänta på:** `Started ExamServiceApplication` (port 8083)

---

## STEG 5: Kontrollera Eureka Registration (VIKTIGT!)

**Gå till:** http://localhost:8761

Under "Instances currently registered with Eureka" ska du se **ALLA 5 services:**

- ✅ USER-SERVICE (1 instance)
- ✅ ADMIN-SERVICE (1 instance)
- ✅ PAYMENT-SERVICE (1 instance)
- ✅ QUIZ-SERVICE (1 instance)
- ✅ EXAM-SERVICE (1 instance)

**Om någon service saknas:**

- Vänta 30 sekunder (registration tar tid)
- Kontrollera terminalfönstret för felmeddelanden
- Kolla att `EUREKA_URL=http://localhost:8761/eureka/` finns i .env

---

## STEG 6: Starta API Gateway

### Terminal 7 - API Gateway

```powershell
cd C:\src\projects\TrafficSchool\api-gateway
.\mvnw.cmd clean spring-boot:run
```

**Vänta på:** `Started ApiGatewayApplication` (port 8080)

**VIKTIGT:** Du ska se i loggen:

```
GatewayConfig : Initializing routes for local development
```

**INTE se:**

```
RailwayGatewayConfig : Initializing with direct service URLs
```

**Obs:** Eftersom `SPRING_PROFILES_ACTIVE` INTE är satt till "railway" i lokal .env, kommer den vanliga `GatewayConfig` att användas (med Eureka).

---

## STEG 7: Testa Backend

Öppna dessa URLs i webbläsaren eller Postman:

### Test 1: API Gateway Health

```
GET http://localhost:8080/actuator/health
```

**Förväntat svar:**

```json
{ "status": "UP" }
```

### Test 2: User Service Health (via Gateway)

```
GET http://localhost:8080/api/users/health
```

eller direkt:

```
GET http://localhost:8081/actuator/health
```

### Test 3: Admin Service Health (via Gateway)

```
GET http://localhost:8080/api/admin/health
```

eller direkt:

```
GET http://localhost:8084/actuator/health
```

---

## STEG 8: Starta Frontend

### Terminal 8 - Frontend

```powershell
cd C:\src\projects\TrafficSchool\frontend
npm install
npm run dev
```

**Vänta på:**

```
Local:   http://localhost:5173/
```

Öppna http://localhost:5173 i webbläsaren.

---

## STEG 9: Testa Komplett Flow

### Test 1: User Registration

1. Gå till **Register** på frontend (http://localhost:5173)
2. Fyll i formuläret med **din riktiga email**
3. Skicka registrering

**Förväntat:**

- ✅ Registrering lyckas
- ✅ Du får email med välkomstlänk (kontrollera inbox!)
- ✅ Länken pekar till http://localhost:5173/?token=xxx

4. Klicka på länken i emailet
5. Du ska automatiskt loggas in

### Test 2: Admin Login

1. Gå till **Admin Login** (http://localhost:5173/admin)
2. Logga in med admin credentials
3. Du ska se admin dashboard

---

## ✅ CHECKLISTA - LOKAL MILJÖ

- [ ] MySQL igång och databaser skapade
- [ ] SendGrid API key uppdaterad i `userService\.env`
- [ ] Eureka Server startat (http://localhost:8761)
- [ ] Alla 5 backend services startade och registrerade i Eureka
- [ ] API Gateway startat (port 8080)
- [ ] Frontend startat (http://localhost:5173)
- [ ] User registration fungerar
- [ ] Email skickas och tas emot
- [ ] Magic link i email fungerar
- [ ] Admin login fungerar

---

# DEL 2: RAILWAY DEPLOYMENT 🚂

**OBS:** Gör detta EFTER att allt fungerar lokalt!

## STEG 10: Committa och pusha Railway-fixes

Öppna **Terminal** i VS Code:

```powershell
cd C:\src\projects\TrafficSchool

# Kontrollera vad som ändrats
git status

# Lägg till ENDAST Railway-relevanta filer (inte .env!)
git add api-gateway/src/main/java/com/example/api_gateway/Config/RailwayGatewayConfig.java
git add api-gateway/src/main/java/com/example/api_gateway/Config/GatewayConfig.java
git add api-gateway/src/main/resources/application-railway.properties

# Committa
git commit -m "Fix: Railway Gateway routing - use direct service URLs instead of Eureka"

# Pusha till GitHub (Railway kommer auto-deploya)
git push origin main
```

**VIKTIGT:** `.env`-filer ska **INTE** committas! De är redan i `.gitignore`.

---

## STEG 11: Vänta på Railway Auto-Deploy

1. Gå till **Railway Dashboard**: https://railway.app
2. Välj ditt **TrafficSchool** projekt
3. Klicka på **api-gateway** service
4. Gå till **Deployments** tab
5. Vänta tills den nya deploymenten är **"Active"** (2-3 minuter)

**Kontrollera loggen:**
Du ska se:

```
🚂 [Railway Gateway Config] Initializing with direct service URLs:
  - User Service: http://userservice.railway.internal:8081
  - Admin Service: http://adminservice.railway.internal:8084
  ...
```

---

## STEG 12: Uppdatera Railway Environment Variables

### 12.1 API Gateway

**Kontrollera att denna variabel finns:**

Railway → **api-gateway** → **Variables**

```
SPRING_PROFILES_ACTIVE = railway
```

Om den INTE finns, lägg till den och **Restart** service!

### 12.2 User Service

Railway → **userService** → **Variables**

**Lägg till/uppdatera dessa 3 variabler:**

```
SENDGRID_API_KEY = SG.xxxxxxxxxxxxxx
(Din riktiga SendGrid API key)

SENDGRID_FROM_EMAIL = noreply@yourdomain.com
(Din verifierade sender email från SendGrid)

MAGIC_LINK_BASE_URL = https://[DIN-FRONTEND-DOMAIN].up.railway.app
(Exempel: https://frontend-production-a1b2.up.railway.app)
```

**Så här hittar du din frontend domain:**

1. Railway → **frontend** → **Settings** → **Domains**
2. Kopiera den genererade domänen

**Efter att du lagt till variablerna → Restart userService**

---

## STEG 13: Verifiera Railway Deployment

### Test 1: API Gateway Health

```
GET https://[API-GATEWAY-DOMAIN].up.railway.app/actuator/health
```

**Förväntat:**

```json
{ "status": "UP" }
```

### Test 2: Admin Login via Railway

1. Öppna din Railway frontend URL i webbläsaren
2. Gå till Admin Login
3. Logga in med admin credentials

**Förväntat:**

- ✅ Login ska fungera (INGEN Connection Refused error)
- ✅ Du ska se admin dashboard

### Test 3: User Registration & Email

1. Registrera en ny användare med din riktiga email
2. Kontrollera inbox

**Förväntat:**

- ✅ Du får välkomst-email
- ✅ Magic link pekar till Railway frontend URL (inte localhost!)
- ✅ Klicka på länken → automatisk inloggning

---

## ✅ CHECKLISTA - RAILWAY DEPLOYMENT

- [ ] Railway-fixes committade och pushade
- [ ] api-gateway auto-deployed i Railway
- [ ] `SPRING_PROFILES_ACTIVE=railway` satt för api-gateway
- [ ] SendGrid variabler uppdaterade i userService
- [ ] `MAGIC_LINK_BASE_URL` pekar till Railway frontend
- [ ] userService restarted
- [ ] Admin login fungerar på Railway
- [ ] User registration skickar email
- [ ] Magic link i email pekar till Railway URL
- [ ] Magic link fungerar

---

## 🐛 TROUBLESHOOTING

### Problem: Service startar inte lokalt

**Symptom:**

```
Port 8081 is already in use
```

**Lösning:**

```powershell
# Hitta och stoppa processen
netstat -ano | findstr :8081
taskkill /PID [process_id] /F
```

### Problem: MySQL connection error

**Symptom:**

```
Access denied for user 'root'@'localhost'
```

**Lösning:**

1. Testa MySQL-anslutning: `mysql -u root -p`
2. Om det fungerar, uppdatera `DB_PASSWORD` i alla .env-filer
3. Starta om affected services

### Problem: Services syns inte i Eureka

**Lösning:**

1. Vänta 30-60 sekunder (registration tar tid)
2. Kontrollera service-loggen för errors
3. Verifiera att `EUREKA_URL=http://localhost:8761/eureka/` finns i .env
4. Starta om service

### Problem: JWT signature does not match

**Lösning:**
Kontrollera att `JWT_SECRET` är **EXAKT samma** i alla .env-filer:

- api-gateway/.env
- userService/.env
- adminService/.env
- examService/.env
- quizService/.env

### Problem: Railway admin login ger Connection Refused

**Lösning:**

1. Kontrollera att `SPRING_PROFILES_ACTIVE=railway` finns för api-gateway
2. Kontrollera api-gateway logs i Railway
3. Leta efter: `🚂 [Railway Gateway Config] Initializing`
4. Om du INTE ser det → Restart api-gateway

### Problem: Railway email pekar till localhost

**Lösning:**

1. Kontrollera att `MAGIC_LINK_BASE_URL` är korrekt i userService
2. Det ska peka till Railway frontend URL, INTE localhost
3. Restart userService efter ändring

---

## 📊 PORT ÖVERSIKT

### Lokal utveckling:

| Service       | Port |
| ------------- | ---- |
| Eureka Server | 8761 |
| User Service  | 8081 |
| Quiz Service  | 8082 |
| Exam Service  | 8083 |
| Admin Service | 8084 |
| Payment Svc   | 8085 |
| API Gateway   | 8080 |
| Frontend      | 5173 |

---

## 🎉 KLART!

Om alla steg är ✅ har du:

1. ✅ Fullt fungerande lokal utvecklingsmiljö
2. ✅ Railway deployment som fungerar korrekt
3. ✅ Email-funktionalitet (SendGrid)
4. ✅ Admin och User autentisering
5. ✅ Service-to-service kommunikation

**Lycka till med vidareutveckling! 🚗📚**
