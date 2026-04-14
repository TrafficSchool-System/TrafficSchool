# 🚀 RAILWAY DEPLOYMENT GUIDE - TrafficSchool

**Datum:** 2026-04-02  
**Plattform:** Railway.app  
**Projekt:** TrafficSchool

## ⚠️ VIKTIGT - MySQL CONNECTION FIX

**ANVÄND RAILWAY SERVICE REFERENCES!**

För alla backend-tjänster, använd DENNA syntax för MySQL-variabler:

```
SPRING_DATASOURCE_URL = jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}
SPRING_DATASOURCE_USERNAME = ${{MySQL.MYSQLUSER}}
SPRING_DATASOURCE_PASSWORD = ${{MySQL.MYSQLPASSWORD}}
```

❌ **ANVÄND INTE:** `mysql.railway.internal` eller hårdkodade värden!  
✅ **ANVÄND:** `${{MySQL.VARIABELNAMN}}` - Railway löser referenser automatiskt!

---

## 📋 ÖVERSIKT - Deployment Order

1. ✅ MySQL Database (KLAR)
2. ✅ Eureka Server (KLAR)
3. ⏳ userService
4. ⏳ adminService
5. ⏳ paymentService
6. ⏳ examService
7. ⏳ quizService
8. ⏳ API Gateway
9. ⏳ Frontend

---

## 🔐 MYSQL CONNECTION (Railway Service References)

⚠️ **VIKTIGT:** Använd Railway's service reference syntax `${{MySQL.VARIABELNAMN}}`

Railway löser automatiskt referenser mellan tjänster i samma projekt.

**Syntax för alla backend-tjänster:**

```
SPRING_DATASOURCE_URL = jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}
SPRING_DATASOURCE_USERNAME = ${{MySQL.MYSQLUSER}}
SPRING_DATASOURCE_PASSWORD = ${{MySQL.MYSQLPASSWORD}}
```

---

## 🔑 SHARED SECRETS (måste vara EXAKT samma på alla tjänster!)

```
JWT_SECRET: TrafficSchool2024SecureJWTKeyForProductionUseOnly123456789

SERVICE_API_KEY: TrafficSchool2024InternalServiceAPIKey987654321
```

---

## 📡 EUREKA SERVER URL

```
https://eureka-server-production-c8a1.up.railway.app/eureka/
```

---

# STEG 1: DEPLOY userService

## A. Lägg till GitHub Repo

1. Railway dashboard → **TrafficSchool** project
2. Klicka **"+ New"**
3. Välj **"GitHub Repo"**
4. Välj **"TrafficSchool-System/userService"**

## B. Generera Domain

1. Klicka på **userService** (när den visas)
2. Gå till **Settings**
3. Klicka **"Generate Domain"**

## C. Lägg till Environment Variables

Gå till **"Variables"** tab och lägg till **8 variabler**:

### Kopiera dessa (en variabel i taget):

**Variable 1:**

```
Name: SPRING_PROFILES_ACTIVE
Value: railway
```

**Variable 2:**

```
Name: SPRING_DATASOURCE_URL
Value: jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}
```

**Variable 3:**

```
Name: SPRING_DATASOURCE_USERNAME
Value: ${{MySQL.MYSQLUSER}}
```

**Variable 4:**

```
Name: SPRING_DATASOURCE_PASSWORD
Value: ${{MySQL.MYSQLPASSWORD}}
```

**Variable 5:**

```
Name: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE
Value: https://eureka-server-production-c8a1.up.railway.app/eureka/
```

**Variable 6:**

```
Name: JWT_SECRET
Value: TrafficSchool2024SecureJWTKeyForProductionUseOnly123456789
```

**Variable 7:**

```
Name: SERVICE_API_KEY
Value: TrafficSchool2024InternalServiceAPIKey987654321
```

**Variable 8:**

```
Name: SENDGRID_API_KEY
Value: dummy_key_for_testing
```

## D. Vänta på Deployment

- Status ska bli **"Active"** (2-3 minuter)
- Kontrollera att inga fel visas i logs

---

# STEG 2: DEPLOY adminService

## A. Lägg till GitHub Repo

1. **"+ New"** → **"GitHub Repo"**
2. Välj **"TrafficSchool-System/adminService"**

## B. Generera Domain

Settings → **"Generate Domain"**

## C. Lägg till Environment Variables

Lägg till **7 variabler** (en mindre än userService):

**Variable 1:**

```
Name: SPRING_PROFILES_ACTIVE
Value: railway
```

**Variable 2:**

```
Name: SPRING_DATASOURCE_URL
Value: jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}
```

**Variable 3:**

```
Name: SPRING_DATASOURCE_USERNAME
Value: ${{MySQL.MYSQLUSER}}
```

**Variable 4:**

```
Name: SPRING_DATASOURCE_PASSWORD
Value: ${{MySQL.MYSQLPASSWORD}}
```

**Variable 5:**

```
Name: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE
Value: https://eureka-server-production-c8a1.up.railway.app/eureka/
```

**Variable 6:**

```
Name: JWT_SECRET
Value: TrafficSchool2024SecureJWTKeyForProductionUseOnly123456789
```

**Variable 7:**

```
Name: SERVICE_API_KEY
Value: TrafficSchool2024InternalServiceAPIKey987654321
```

## D. Vänta på Active Status

---

# STEG 3: DEPLOY paymentService

## A. Lägg till GitHub Repo

**"+ New"** → **"GitHub Repo"** → **"TrafficSchool-System/paymentService"**

## B. Generera Domain

Settings → **"Generate Domain"**

## C. Lägg till Environment Variables

**Exakt samma 7 variabler som adminService:**

```
SPRING_PROFILES_ACTIVE = railway
SPRING_DATASOURCE_URL = jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}
SPRING_DATASOURCE_USERNAME = ${{MySQL.MYSQLUSER}}
SPRING_DATASOURCE_PASSWORD = ${{MySQL.MYSQLPASSWORD}}
EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = https://eureka-server-production-c8a1.up.railway.app/eureka/
JWT_SECRET = TrafficSchool2024SecureJWTKeyForProductionUseOnly123456789
SERVICE_API_KEY = TrafficSchool2024InternalServiceAPIKey987654321
```

## D. Vänta på Active Status

---

# STEG 4: DEPLOY examService

## A. Lägg till GitHub Repo

**"+ New"** → **"GitHub Repo"** → **"TrafficSchool-System/examService"**

## B. Generera Domain

Settings → **"Generate Domain"**

## C. Lägg till Environment Variables

**Samma 7 variabler:**

```
SPRING_PROFILES_ACTIVE = railway
SPRING_DATASOURCE_URL = jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}
SPRING_DATASOURCE_USERNAME = ${{MySQL.MYSQLUSER}}
SPRING_DATASOURCE_PASSWORD = ${{MySQL.MYSQLPASSWORD}}
EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = https://eureka-server-production-c8a1.up.railway.app/eureka/
JWT_SECRET = TrafficSchool2024SecureJWTKeyForProductionUseOnly123456789
SERVICE_API_KEY = TrafficSchool2024InternalServiceAPIKey987654321
```

## D. Vänta på Active Status

---

# STEG 5: DEPLOY quizService

## A. Lägg till GitHub Repo

**"+ New"** → **"GitHub Repo"** → **"TrafficSchool-System/quizService"**

## B. Generera Domain

Settings → **"Generate Domain"**

## C. Lägg till Environment Variables

**Samma 7 variabler:**

```
SPRING_PROFILES_ACTIVE = railway
SPRING_DATASOURCE_URL = jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}
SPRING_DATASOURCE_USERNAME = ${{MySQL.MYSQLUSER}}
SPRING_DATASOURCE_PASSWORD = ${{MySQL.MYSQLPASSWORD}}
EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = https://eureka-server-production-c8a1.up.railway.app/eureka/
JWT_SECRET = TrafficSchool2024SecureJWTKeyForProductionUseOnly123456789
SERVICE_API_KEY = TrafficSchool2024InternalServiceAPIKey987654321
```

## D. Vänta på Active Status

---

# STEG 6: VERIFIERA I EUREKA

⚠️ **VIKTIGT! Innan du deployar API Gateway:**

1. Öppna: **https://eureka-server-production-c8a1.up.railway.app**
2. Kontrollera att du ser **ALLA 5 tjänster registrerade:**
   - USER-SERVICE
   - ADMIN-SERVICE
   - PAYMENT-SERVICE
   - EXAM-SERVICE
   - QUIZ-SERVICE

**Om en tjänst saknas:**

- Vänta 1-2 minuter (registrering kan ta tid)
- Kontrollera logs för tjänsten i Railway
- Se till att EUREKA_CLIENT_SERVICEURL_DEFAULTZONE är rätt

---

# STEG 7: DEPLOY API Gateway

## A. Lägg till GitHub Repo

**"+ New"** → **"GitHub Repo"** → **"TrafficSchool-System/api-gateway"**

## B. Generera Domain

Settings → **"Generate Domain"**

⚠️ **SPARA DENNA DOMAIN!** Den behövs för frontend!

```
API Gateway Domain: ________________________________
(Fyll i här när den genereras!)
```

## C. Lägg till Environment Variables

Lägg till **3 variabler** (ingen databas!):

**Variable 1:**

```
Name: SPRING_PROFILES_ACTIVE
Value: railway
```

**Variable 2:**

```
Name: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE
Value: https://eureka-server-production-c8a1.up.railway.app/eureka/
```

**Variable 3:**

```
Name: JWT_SECRET
Value: TrafficSchool2024SecureJWTKeyForProductionUseOnly123456789
```

## D. Vänta på Active Status

## E. Testa API Gateway

Öppna i browser: `https://[DIN-API-GATEWAY-DOMAIN]/actuator/health`

**Förväntat svar:**

```json
{ "status": "UP" }
```

---

# STEG 8: DEPLOY Frontend

## A. Lägg till GitHub Repo

**"+ New"** → **"GitHub Repo"** → **"TrafficSchool-System/frontend"**

## B. Generera Domain

Settings → **"Generate Domain"**

## C. Lägg till Environment Variable

Lägg till **1 variabel**:

**Variable 1:**

```
Name: VITE_API_BASE_URL
Value: https://[DIN-API-GATEWAY-DOMAIN]
```

⚠️ **Byt ut `[DIN-API-GATEWAY-DOMAIN]` med den faktiska domänen från Steg 7B!**

Exempel:

```
VITE_API_BASE_URL = https://api-gateway-production-abc123.up.railway.app
```

## D. Vänta på Active Status

## E. Öppna och Testa!

1. Klicka på frontend domain i Railway
2. Testa registrering, inloggning, quiz, etc.

---

# ✅ DEPLOYMENT CHECKLIST

- [ ] userService - Active
- [ ] adminService - Active
- [ ] paymentService - Active
- [ ] examService - Active
- [ ] quizService - Active
- [ ] Alla 5 services syns i Eureka
- [ ] API Gateway - Active
- [ ] API Gateway health check fungerar
- [ ] Frontend - Active
- [ ] Frontend kan nå API Gateway

---

# 🐛 TROUBLESHOOTING

## Problem: Tjänst startar inte

**Lösning:**

1. Kontrollera logs i Railway (klicka på tjänsten → View Logs)
2. Verifiera att alla environment variables är rätt stavade
3. Se till att JWT_SECRET är EXAKT samma på alla tjänster

## Problem: Tjänst registreras inte i Eureka

**Lösning:**

1. Kontrollera EUREKA_CLIENT_SERVICEURL_DEFAULTZONE är rätt
2. Vänta 1-2 minuter (registrering kan ta tid)
3. Kontrollera att Eureka Server är "Active"

## Problem: Frontend kan inte nå API

**Lösning:**

1. Kontrollera VITE_API_BASE_URL i frontend variables
2. Testa API Gateway health endpoint manuellt
3. Öppna browser console (F12) för fel

---

# 📊 ESTIMERAD TID

- userService: 3-4 min
- adminService: 2-3 min
- paymentService: 2-3 min
- examService: 2-3 min
- quizService: 2-3 min
- API Gateway: 2-3 min
- Frontend: 3-5 min

**TOTAL: ~15-25 minuter**

---

# 🎯 NÄSTA STEG EFTER DEPLOYMENT

1. ✅ Testa alla funktioner (registrering, quiz, betalning)
2. ✅ Ge kunden demo-URL
3. ✅ Samla feedback
4. 📋 Planera Azure-migrering (när kunden godkänt demo)

---

**Lycka till! 🚀**
