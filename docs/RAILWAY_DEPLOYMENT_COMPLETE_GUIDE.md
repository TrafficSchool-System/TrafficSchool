# Railway Deployment - Komplett Guide från Början

## Steg 1: Rensa Railway (börja från noll)

1. Gå till [Railway Dashboard](https://railway.app/dashboard)
2. Klicka på ditt TrafficSchool-projekt
3. **Ta bort ALLA services:**
   - Klicka på varje service (eureka-server, api-gateway, userService, osv.)
   - Settings → Danger → Delete Service
4. **Ta bort MySQL database:**
   - Klicka på MySQL service
   - Settings → Danger → Delete Service
5. **Ta bort alla Shared Variables:**
   - Settings → Shared Variables → Ta bort ALLA

**Bekräfta:** Du har en helt tom Railway-projekt nu.

---

## Steg 2: Skapa MySQL databas

1. I Railway Dashboard → **"+ New"** → **"Database"** → **"Add MySQL"**
2. Vänta tills status = **"Active"** (ca 1 minut)
3. **Verifiera MySQL Variables:**
   - Klicka på MySQL service → **"Variables"**
   - Du ska se dessa värden:
     - `MYSQLHOST` = `mysql.railway.internal`
     - `MYSQLPORT` = `3306`
     - `MYSQLUSER` = `root`
     - `MYSQLPASSWORD` = `zMAwiiINQUZcvoBVBBbRWGAMpVMGTeSV`
     - `MYSQLDATABASE` = `railway`
     - `MYSQL_PUBLIC_URL` (finns också, som backup)

**Bekräfta:** MySQL status = Active och värdena matchar ovan.

---

## Steg 3: Skapa Shared Variables (EXAKT ordning)

1. Settings → **"Shared Variables"**
2. Klicka **"+ New Variable"** för VARJE variabel nedan:

### Variabel 1: DATABASE_URL

**Variable Name:** `DATABASE_URL`  
**Variable Value:** (kopiera EXAKT, inklusive lösenordet från din MySQL):

```
jdbc:mysql://root:zMAwiiINQUZcvoBVBBbRWGAMpVMGTeSV@mysql.railway.internal:3306/railway?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
```

**OBS:** Om du får "Connection refused" senare, byt till PUBLIC URL istället:

```
jdbc:mysql://root:zMAwiiINQUZcvoBVBBbRWGAMpVMGTeSV@[DIN_PUBLIC_HOST]:[PUBLIC_PORT]/railway?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
```

### Variabel 2: SPRING_PROFILES_ACTIVE

**Variable Name:** `SPRING_PROFILES_ACTIVE`  
**Variable Value:** `railway`

### Variabel 3: JWT_SECRET

**Variable Name:** `JWT_SECRET`  
**Variable Value:** `mySecretKey123456789012345678901234567890`

### Variabel 4: SERVICE_API_KEY

**Variable Name:** `SERVICE_API_KEY`  
**Variable Value:** `TrafficSchool-Internal-Key-2026-CHANGE-IN-PROD`

### Variabel 5: SENDGRID_API_KEY

**Variable Name:** `SENDGRID_API_KEY`  
**Variable Value:** `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`

### Variabel 6: SENDGRID_FROM_EMAIL

**Variable Name:** `SENDGRID_FROM_EMAIL`  
**Variable Value:** `Fk@excetra.se`

### Variabel 7: SWISH_BASE_URL

**Variable Name:** `SWISH_BASE_URL`  
**Variable Value:** `https://mss.cpc.getswish.net`

### Variabel 8: SWISH_MERCHANT_NUMBER

**Variable Name:** `SWISH_MERCHANT_NUMBER`  
**Variable Value:** `1234679304`

### Variabel 9: SWISH_KEYSTORE_PASSWORD

**Variable Name:** `SWISH_KEYSTORE_PASSWORD`  
**Variable Value:** `swish`

**Bekräfta:** Du har exakt 9 Shared Variables.

---

## Steg 4: Deploy Eureka Server (Service 1/8)

1. Railway Dashboard → **"+ New"** → **"GitHub Repo"**
2. Välj repository: **"TrafficSchool-System/eureka-server"**
3. Railway börjar bygga automatiskt
4. **Lägg till Variables:**
   - Klicka på eureka-server service → **"Variables"**
   - **Viktigt:** De 9 Shared Variables läggs till automatiskt
   - Ingen extra konfiguration behövs!
5. Vänta tills status = **"Active"** (3-5 minuter första gången)

**Bekräfta:** Eureka-server status = Active, inga errors i logs.

---

## Steg 5: Deploy API Gateway (Service 2/8)

1. Railway Dashboard → **"+ New"** → **"GitHub Repo"**
2. Välj repository: **"TrafficSchool-System/api-gateway"**
3. Railway börjar bygga automatiskt
4. **Lägg till Service-Specific Variable:**
   - Klicka på api-gateway service → **"Variables"**
   - Klicka **"+ New Variable"**
   - **Variable Name:** `EUREKA_URL`
   - **Variable Value:** `http://eureka-server.railway.internal:8761/eureka/`
5. Vänta tills status = **"Active"** (3-5 minuter)

**Bekräfta:** API Gateway status = Active, kan nå Eureka.

---

## Steg 6: Deploy UserService (Service 3/8)

1. Railway Dashboard → **"+ New"** → **"GitHub Repo"**
2. Välj repository: **"TrafficSchool-System/userService"**
3. Railway börjar bygga automatiskt
4. **Lägg till Service-Specific Variable:**
   - Klicka på userService → **"Variables"**
   - **Variable Name:** `EUREKA_URL`
   - **Variable Value:** `http://eureka-server.railway.internal:8761/eureka/`
5. Vänta tills status = **"Active"** (3-5 minuter första gången, kan ta längre pga Hibernate setup)

**Bekräfta:** UserService status = Active, logs visar "Started UserServiceApplication".

---

## Steg 7: Deploy AdminService (Service 4/8)

1. Railway Dashboard → **"+ New"** → **"GitHub Repo"**
2. Välj repository: **"TrafficSchool-System/adminService"**
3. **Lägg till Service-Specific Variable:**
   - **Variable Name:** `EUREKA_URL`
   - **Variable Value:** `http://eureka-server.railway.internal:8761/eureka/`
4. Vänta tills status = **"Active"**

**Bekräfta:** AdminService status = Active.

---

## Steg 8: Deploy PaymentService (Service 5/8)

1. Railway Dashboard → **"+ New"** → **"GitHub Repo"**
2. Välj repository: **"TrafficSchool-System/paymentService"**
3. **Lägg till Service-Specific Variable:**
   - **Variable Name:** `EUREKA_URL`
   - **Variable Value:** `http://eureka-server.railway.internal:8761/eureka/`
4. Vänta tills status = **"Active"**
5. **Kopiera Public URL:**
   - Klicka på paymentService → **"Settings"** → **"Networking"**
   - Kopiera Public Domain (exempel: `payment-service-production-abc123.up.railway.app`)
6. **Lägg till Callback URL:**
   - Variables → **"+ New Variable"**
   - **Variable Name:** `SWISH_CALLBACK_URL`
   - **Variable Value:** `https://DITT-PUBLIC-DOMAIN/api/webhooks/swish`
   - **Exempel:** `https://payment-service-production-abc123.up.railway.app/api/webhooks/swish`

**Bekräfta:** PaymentService status = Active, SWISH_CALLBACK_URL är satt.

---

## Steg 9: Deploy ExamService (Service 6/8)

1. Railway Dashboard → **"+ New"** → **"GitHub Repo"**
2. Välj repository: **"TrafficSchool-System/examService"**
3. **Lägg till Service-Specific Variable:**
   - **Variable Name:** `EUREKA_URL`
   - **Variable Value:** `http://eureka-server.railway.internal:8761/eureka/`
4. Vänta tills status = **"Active"**

**Bekräfta:** ExamService status = Active.

---

## Steg 10: Deploy QuizService (Service 7/8)

1. Railway Dashboard → **"+ New"** → **"GitHub Repo"**
2. Välj repository: **"TrafficSchool-System/quizService"**
3. **Lägg till Service-Specific Variable:**
   - **Variable Name:** `EUREKA_URL`
   - **Variable Value:** `http://eureka-server.railway.internal:8761/eureka/`
4. Vänta tills status = **"Active"**

**Bekräfta:** QuizService status = Active.

---

## Steg 11: Deploy Frontend (Service 8/8)

1. Railway Dashboard → **"+ New"** → **"GitHub Repo"**
2. Välj repository: **"TrafficSchool-System/frontend"**
3. **Hämta API Gateway URL:**
   - Klicka på api-gateway service → Settings → **"Generate Domain"** (om inte redan gjort)
   - Kopiera Public Domain (exempel: `api-gateway-production-xyz.up.railway.app`)
4. **Lägg till Frontend Variable:**
   - Klicka på frontend service → **"Variables"**
   - **Variable Name:** `VITE_API_URL`
   - **Variable Value:** `https://DITT-API-GATEWAY-DOMAIN`
   - **Exempel:** `https://api-gateway-production-xyz.up.railway.app`
5. Vänta tills status = **"Active"** (5-10 minuter för build)
6. **Generate Public Domain:**
   - Settings → **"Generate Domain"**
   - Kopiera frontend URL

**Bekräfta:** Frontend status = Active, du har en publik URL.

---

## Steg 12: Importera Databas

1. Öppna `railway-backup.sql` i VS Code
2. **Ta bort första 2 rader:**
   ```sql
   CREATE DATABASE IF NOT EXISTS trafficschool;
   USE trafficschool;
   ```
3. **Spara filen**
4. **Importera till Railway:**
   - Railway Dashboard → MySQL service → **"Data"** tab
   - Klicka på **"Query"** eller **"Execute SQL"**
   - Kopiera HELA innehållet från `railway-backup.sql`
   - Klistra in och kör
   - Vänta på "Success" meddelande

**Bekräfta:** Query kördes utan errors.

---

## Steg 13: Kör Database Migrations

1. Railway Dashboard → MySQL service → **"Data"** → **"Query"**
2. Kör följande SQL (kopiera och klistra in):

```sql
-- Lägg till expires_at kolumn
ALTER TABLE payments
ADD COLUMN expires_at DATETIME DEFAULT NULL
AFTER updated_at;

-- Lägg till EXPIRED status
ALTER TABLE payments
MODIFY COLUMN status ENUM(
  'CANCELLED',
  'CREATED',
  'DECLINED',
  'ERROR',
  'PAID',
  'PENDING',
  'EXPIRED'
) NOT NULL;

-- Sätt expires_at för befintliga PENDING/CREATED payments
UPDATE payments
SET expires_at = DATE_ADD(created_at, INTERVAL 5 MINUTE)
WHERE expires_at IS NULL
AND status IN ('PENDING', 'CREATED');
```

**Bekräfta:** Alla 3 queries kördes utan errors.

---

## Steg 14: Verifiera Deployment

### Kontrollera Services

- [ ] MySQL - Status: Active
- [ ] eureka-server - Status: Active
- [ ] api-gateway - Status: Active (registrerad hos Eureka)
- [ ] userService - Status: Active (registrerad hos Eureka)
- [ ] adminService - Status: Active (registrerad hos Eureka)
- [ ] paymentService - Status: Active (registrerad hos Eureka)
- [ ] examService - Status: Active (registrerad hos Eureka)
- [ ] quizService - Status: Active (registrerad hos Eureka)
- [ ] frontend - Status: Active

### Test Användare (från railway-backup.sql)

Du har nu 2 test-användare i systemet:

1. **Test User 1** - Email finns i databasen
2. **Test User 2** - Email finns i databasen

### Testa Systemet

1. **Öppna Frontend URL** (från Steg 11)
2. **Login:** Använd en av test-användarna
3. **Kontrollera Dashboard:** Subscription ska vara Active
4. **Test Payment Expiry:**
   - Skapa en ny betalning
   - Vänta 5 minuter UTAN att betala
   - Betalningen ska automatiskt bli EXPIRED
   - Admin panel ska visa EXPIRED som "failed"

---

## Troubleshooting

### UserService får inte kontakt med MySQL?

**Kontrollera:** DATABASE_URL innehåller rätt MySQL-värden från Steg 2.

### API Gateway kan inte hitta Eureka?

**Kontrollera:** EUREKA_URL är exakt `http://eureka-server.railway.internal:8761/eureka/`

### Frontend kan inte nå API?

**Kontrollera:** VITE_API_URL pekar på API Gateway's publika domain.

### Service visar "Crashed"?

**Kontrollera logs:**

- Klicka på service → "Deployments" → senaste deployment → "View Logs"
- Leta efter error messages
- Vanligaste problemet: felaktiga environment variables

---

## Nästa Steg

När allt fungerar:

1. **Uppdatera Production Secrets:**
   - Generera nya JWT_SECRET och SERVICE_API_KEY
   - Använd starka random värden

2. **Konfigurera Swish Production:**
   - Se `docs/SWISH_PRODUCTION_SETUP.md`
   - Byt till riktiga Swish credentials

3. **Setup SendGrid Production:**
   - Verifiera din egen email domain
   - Uppdatera SENDGRID_FROM_EMAIL

4. **Custom Domains (optional):**
   - Railway Settings → Networking → Add Custom Domain

---

## Status Tracking

**Startdatum:** 2026-04-05  
**Status:** Redo att börja  
**Estimerad tid:** 45-60 minuter total

**Progress:**

- [ ] Steg 1: Rensa Railway
- [ ] Steg 2: MySQL databas
- [ ] Steg 3: Shared Variables (9 st)
- [ ] Steg 4: Eureka Server
- [ ] Steg 5: API Gateway
- [ ] Steg 6: UserService
- [ ] Steg 7: AdminService
- [ ] Steg 8: PaymentService
- [ ] Steg 9: ExamService
- [ ] Steg 10: QuizService
- [ ] Steg 11: Frontend
- [ ] Steg 12: Database Import
- [ ] Steg 13: Migrations
- [ ] Steg 14: Verification

**Klart när:** Alla checkboxes är markerade ✅
