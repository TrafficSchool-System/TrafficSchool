# 🔐 .ENV FILER ÅTERSTÄLLDA

**Datum:** 2026-04-03  
**Status:** ✅ Alla .env-filer har återskapats

---

## 📁 SKAPADE FILER:

✅ `.env` (root)  
✅ `userService/.env`  
✅ `adminService/.env`  
✅ `api-gateway/.env`  
✅ `paymentService/.env`  
✅ `examService/.env`  
✅ `quizService/.env`

---

## ⚙️ STANDARD KONFIGURATION

Alla .env-filer har konfigurerats med **förnuftiga standardvärden för lokal utveckling**:

### **Delade värden (samma i alla services):**

```bash
JWT_SECRET=TrafficSchool2024SecureJWTKeyForProductionUseOnly123456789
SERVICE_API_KEY=TrafficSchool-Internal-Key-2026-Dev
DB_PASSWORD=root
EUREKA_URL=http://localhost:8761/eureka/
```

### **MySQL Databaser:**

- userServiceDb (port 8081)
- adminServiceDb (port 8084)
- paymentServiceDb (port 8085)
- quizServiceDb (port 8082)
- examservicedb (port 8083)

---

## ⚠️ VIKTIGT - MÅSTE ÄNDRAS!

### **1. SendGrid API Key (userService/.env)**

```bash
SENDGRID_API_KEY=ÄNDRA_TILL_DIN_SENDGRID_API_KEY
```

**Hur skaffar jag en SendGrid API Key?**

1. Gå till https://sendgrid.com
2. Skapa konto (gratis: 100 emails/dag)
3. Settings → API Keys → Create API Key
4. Kopiera nyckeln och uppdatera userService/.env

**Alternative för lokal utveckling:**
Använd SMTP istället (lägg till i userService/.env):

```bash
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=din.email@gmail.com
MAIL_PASSWORD=ditt_gmail_app_lösenord
```

### **2. MySQL Root Password**

Om ditt MySQL root-lösenord INTE är `root`, uppdatera `DB_PASSWORD` i alla .env-filer:

```bash
# I varje service/.env
DB_PASSWORD=ditt_riktiga_lösenord
```

---

## 🗄️ DATABAS SETUP

Innan du startar services måste databaserna skapas:

```sql
CREATE DATABASE userServiceDb;
CREATE DATABASE adminServiceDb;
CREATE DATABASE paymentServiceDb;
CREATE DATABASE quizServiceDb;
CREATE DATABASE examservicedb;
```

**Eller kör SQL-skripten:**

```bash
mysql -u root -p < SQL/userServiceDb.sql
mysql -u root -p < SQL/adminServiceDb.sql
mysql -u root -p < SQL/paymentServiceDb.sql
mysql -u root -p < SQL/quizServiceDb.sql
mysql -u root -p < SQL/examServiceDb.sql
```

---

## 🚀 STARTA SERVICES

### **1. Starta Eureka Server först:**

```bash
cd eureka-server
./mvnw spring-boot:run
```

Vänta tills den är uppe (http://localhost:8761)

### **2. Starta backend services (öppna 5 terminals):**

**Terminal 1 - User Service:**

```bash
cd userService
./mvnw spring-boot:run
```

**Terminal 2 - Admin Service:**

```bash
cd adminService
./mvnw spring-boot:run
```

**Terminal 3 - Payment Service:**

```bash
cd paymentService
./mvnw spring-boot:run
```

**Terminal 4 - Quiz Service:**

```bash
cd quizService
./mvnw spring-boot:run
```

**Terminal 5 - Exam Service:**

```bash
cd examService
./mvnw spring-boot:run
```

### **3. Starta API Gateway:**

```bash
cd api-gateway
./mvnw spring-boot:run
```

### **4. Starta Frontend:**

```bash
cd frontend
npm install
npm run dev
```

---

## 🔍 VERIFIERA ATT ALLT FUNGERAR

### **Test 1: Eureka Dashboard**

Öppna: http://localhost:8761

Du ska se **5 registrerade services:**

- USER-SERVICE
- ADMIN-SERVICE
- PAYMENT-SERVICE
- QUIZ-SERVICE
- EXAM-SERVICE

### **Test 2: API Gateway Health**

Öppna: http://localhost:8080/actuator/health

Förväntat svar:

```json
{ "status": "UP" }
```

### **Test 3: User Service Health**

Öppna: http://localhost:8081/actuator/health

Förväntat svar:

```json
{ "status": "UP" }
```

### **Test 4: Frontend**

Öppna: http://localhost:5173

Du ska se Traffic School frontend.

---

## 🐛 TROUBLESHOOTING

### **Problem: Service kan inte ansluta till MySQL**

**Symptom:**

```
Access denied for user 'root'@'localhost'
```

**Lösning:**

1. Kontrollera att MySQL är igång
2. Verifiera användarnamn/lösenord i .env-filerna
3. Test: `mysql -u root -p`

### **Problem: JWT token validation fails**

**Symptom:**

```
JWT signature does not match
```

**Lösning:**
Kontrollera att `JWT_SECRET` är **EXAKT samma** i:

- api-gateway/.env
- userService/.env
- adminService/.env
- examService/.env
- quizService/.env

### **Problem: Services kan inte hitta varandra**

**Symptom:**

```
Connection refused: localhost:8081
```

**Lösning:**

1. Kontrollera att Eureka Server är igång
2. Vänta 30 sekunder för service registration
3. Kontrollera Eureka dashboard (http://localhost:8761)

### **Problem: Email skickas inte**

**Symptom:**

```
SendGrid API error: 401 Unauthorized
```

**Lösning:**

1. Uppdatera `SENDGRID_API_KEY` i userService/.env
2. Verifiera att API-nyckeln är giltig på SendGrid
3. Kontrollera att `SENDGRID_FROM_EMAIL` är verifierad i SendGrid

---

## 📝 NÄSTA STEG

### **För Produktion (Railway):**

När du deployar till Railway måste du ändra vissa värden:

1. **JWT_SECRET:** Generera en ny, stark nyckel för produktion
2. **SERVICE_API_KEY:** Ändra till en produktionsvärde
3. **DB_PASSWORD:** Använd Railway's MySQL-instans
4. **SENDGRID_API_KEY:** Använd din riktiga SendGrid-nyckel
5. **MAGIC_LINK_BASE_URL:** Sätt till din Railway frontend URL

Se [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md) för detaljer.

---

## ✅ CHECKLISTA

- [ ] Alla .env-filer skapade
- [ ] MySQL är igång
- [ ] Databaser skapade
- [ ] SendGrid API key uppdaterad (eller SMTP konfigurerad)
- [ ] MySQL lösenord korrigerat (om behövs)
- [ ] Eureka Server startat
- [ ] Alla 5 backend services startade
- [ ] API Gateway startat
- [ ] Frontend startat
- [ ] Testat registrering + email
- [ ] Testat inloggning

---

**🎉 Lycka till med utvecklingen!**
