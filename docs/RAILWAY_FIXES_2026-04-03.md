# 🔧 RAILWAY DEPLOYMENT - KRITISKA FIXES

**Datum:** 2026-04-03  
**Status:** FIXAT - Deployment problem identifierade och lösta

---

## ❌ PROBLEM 1: Admin kan inte logga in

### **Root Cause:**

API Gateway använde Eureka service discovery (`lb://admin-service`) men Eureka fungerar inte korrekt i Railway's privata nätverk. Gateway fick fel service-adresser och kunde inte ansluta.

**Error från loggen:**

```
Connection refused: adminservice.railway.internal:8082
```

### **✅ LÖSNING:**

**Skapad ny fil:** `api-gateway/src/main/java/com/example/api_gateway/Config/RailwayGatewayConfig.java`

Detta är en Railway-specifik Gateway-konfiguration som:

- Är aktiv ENDAST när `SPRING_PROFILES_ACTIVE=railway`
- Använder direkta service URLs till Railway's privata nätverk (.railway.internal)
- INTE använder Eureka load balancing

**Uppdaterad:** `api-gateway/src/main/resources/application-railway.properties`

Lade till direkta service URLs:

```properties
services.user-service.url=http://userservice.railway.internal:8081
services.admin-service.url=http://adminservice.railway.internal:8084
services.payment-service.url=http://paymentservice.railway.internal:8085
services.quiz-service.url=http://quizservice.railway.internal:8082
services.exam-service.url=http://examservice.railway.internal:8083
```

**Uppdaterad:** `api-gateway/src/main/java/com/example/api_gateway/Config/GatewayConfig.java`

Lade till `@Profile("!railway")` så att den ENDAST är aktiv för lokal utveckling.

### **🚀 DEPLOYMENT STEG:**

1. **Committa och pusha ändringarna:**

```bash
git add .
git commit -m "Fix: Railway Gateway routing - use direct service URLs instead of Eureka"
git push origin main
```

2. **Railway kommer automatiskt redeploya API Gateway**
   - Vänta 2-3 minuter för rebuild
   - Kontrollera logs: Du ska se `🚂 [Railway Gateway Config] Initializing with direct service URLs`

3. **Verifiera att `SPRING_PROFILES_ACTIVE=railway` är satt:**
   - Railway Dashboard → api-gateway → Variables
   - Kontrollera att `SPRING_PROFILES_ACTIVE=railway` finns

---

## ❌ PROBLEM 2: Användare får inte email-länk

### **Root Cause:**

**TWO ISSUES:**

1. **SendGrid API Key är en dummy key:**

   ```
   SENDGRID_API_KEY = dummy_key_for_testing
   ```

   Detta är INTE en giltig SendGrid API key!

2. **MAGIC_LINK_BASE_URL saknas:**
   Miljövariabeln för frontend URL är inte satt, så magic links pekar till http://localhost:5173

### **✅ LÖSNING:**

#### **STEG 1: Skaffa en riktig SendGrid API Key**

1. Gå till https://sendgrid.com
2. Logga in eller skapa konto (gratis plan: 100 emails/dag)
3. Gå till **Settings → API Keys**
4. Klicka **Create API Key**
5. Namn: `TrafficSchool-Railway-Production`
6. Permissions: **Full Access** eller **Mail Send** (rekommenderat)
7. **KOPIERA NYCKELN** (visas bara EN gång!)

#### **STEG 2: Uppdatera Railway Environment Variables för userService**

Railway Dashboard → **userService** → **Variables**

**Uppdatera/lägg till dessa 3 variabler:**

```
SENDGRID_API_KEY = SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
(Klistra in din riktiga SendGrid API key!)

SENDGRID_FROM_EMAIL = noreply@trafficschool.com
(Eller din verifierade sender email)

MAGIC_LINK_BASE_URL = https://[DIN-FRONTEND-DOMAIN].up.railway.app
(Exempel: https://frontend-production-a1b2.up.railway.app)
```

**VIKTIGT för SENDGRID_FROM_EMAIL:**

- Om du använder SendGrid free tier: Du måste verifiera sender email
- Gå till SendGrid → **Settings → Sender Authentication**
- Verifiera din email-adress
- Använd DEN verifierade emailen som `SENDGRID_FROM_EMAIL`

#### **STEG 3: Restart userService**

Efter att du lagt till miljövariabler:

1. Railway Dashboard → **userService**
2. **Settings → Restart Service**

---

## ✅ VERIFIERING

### **Test 1: Admin Login**

1. Öppna frontend: `https://[DIN-FRONTEND-URL]`
2. Gå till Admin Login
3. Försök logga in med admin credentials
4. **Förväntat resultat:** Login ska fungera (inga Connection Refused errors)

### **Test 2: User Registration & Email**

1. Öppna frontend: `https://[DIN-FRONTEND-URL]`
2. Registrera ny användare med RIKTIG email-adress
3. **Förväntat resultat:**
   - Registration ska lyckas
   - Du ska få ett välkomstmail med magic link
   - Magic link ska peka till din Railway frontend URL

4. Klicka på länken i emailet
5. **Förväntat resultat:** Du ska loggas in automatiskt

### **Test 3: User Login (Magic Link)**

1. Gå till Login-sidan
2. Ange email och begär login link
3. **Förväntat resultat:**
   - Du ska få ett email med login link
   - Länken ska vara giltig i 5 minuter
   - Klicka på länken → automatisk login

---

## 📋 SAMMANFATTNING AV ÄNDRINGAR

### **Nya/Uppdaterade Filer:**

1. ✅ `api-gateway/src/main/java/com/example/api_gateway/Config/RailwayGatewayConfig.java` (NY)
2. ✅ `api-gateway/src/main/resources/application-railway.properties` (UPPDATERAD)
3. ✅ `api-gateway/src/main/java/com/example/api_gateway/Config/GatewayConfig.java` (UPPDATERAD)

### **Railway Environment Variables att uppdatera:**

#### **userService:**

```
SENDGRID_API_KEY = [DIN RIKTIGA SENDGRID API KEY]
SENDGRID_FROM_EMAIL = [DIN VERIFIERADE EMAIL]
MAGIC_LINK_BASE_URL = https://[FRONTEND-DOMAIN].up.railway.app
```

#### **api-gateway:**

```
SPRING_PROFILES_ACTIVE = railway
```

(Bör redan finnas, men kontrollera!)

---

## 🐛 TROUBLESHOOTING

### **Om admin login fortfarande inte fungerar:**

1. Kontrollera API Gateway logs:

   ```
   Railway → api-gateway → Deployments → Senaste → Logs
   ```

2. Leta efter:

   ```
   🚂 [Railway Gateway Config] Initializing with direct service URLs
   ```

3. Om du INTE ser detta:
   - Kontrollera att `SPRING_PROFILES_ACTIVE=railway` är satt
   - Restart api-gateway service

### **Om emails fortfarande inte skickas:**

1. Kontrollera userService logs:

   ```
   Railway → userService → Deployments → Senaste → Logs
   ```

2. Leta efter SendGrid errors:

   ```
   ❌ Failed to send magic link email
   SendGrid API error: ...
   ```

3. Vanliga problem:
   - **403 Forbidden:** Din API key är ogiltig eller har inte rätt permissions
   - **401 Unauthorized:** API key är fel
   - **400 Bad Request:** `SENDGRID_FROM_EMAIL` är inte verifierad

4. Verifiera din sender email på SendGrid:
   - https://app.sendgrid.com/settings/sender_auth

---

## 📞 SUPPORT

Om problem kvarstår efter dessa fixes, kontrollera:

1. **Railway Service Status:**
   - Är alla services "Active"?
   - Några crash loops?

2. **Network Configuration:**
   - Kan services nå varandra via `.railway.internal`?

3. **Database Connection:**
   - Alla services anslutna till MySQL?
