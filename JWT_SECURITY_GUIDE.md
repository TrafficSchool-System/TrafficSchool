# ==========================================

# JWT SECRET SÄKERHETSGUIDE

# ==========================================

## VIKTIGT: JWT Secret Hantering

### ⚠️ SÄKERHETSKRAV:

1. **JWT_SECRET måste vara SAMMA i Gateway och UserService**
   - Gateway validerar tokens
   - UserService genererar tokens
   - Om secrets skiljer sig åt kommer validering att FAILAS

2. **Secret får ALDRIG commitas till Git**
   - Använd environment variables
   - Lägg .env i .gitignore
   - Använd secret managers i produktion (Azure Key Vault, AWS Secrets Manager)

3. **Secret måste vara minst 256 bits (32 characters)**
   - För HS256 algoritm
   - Använd starka, slumpmässiga tecken

---

## 🔧 SETUP FÖR OLIKA MILJÖER

### **UTVECKLING (Lokal Dator):**

#### Alternativ 1: Environment Variable (Rekommenderat)

```powershell
# Windows PowerShell - Sätt för nuvarande session
$env:JWT_SECRET = "mySecretKey123456789012345678901234567890"

# Eller permanent i Windows:
[System.Environment]::SetEnvironmentVariable('JWT_SECRET', 'mySecretKey123456789012345678901234567890', 'User')
```

#### Alternativ 2: .env fil (Enklast)

1. Kopiera `.env.example` till `.env`

```powershell
Copy-Item .env.example .env
```

2. Redigera `.env` och sätt din JWT_SECRET

3. Kör services med .env fil (kräver extra konfiguration)

#### Alternativ 3: Använd Default (ENDAST för lokal utveckling)

application.properties har redan en default:

```properties
jwt.secret=${JWT_SECRET:mySecretKey123456789012345678901234567890}
```

Om JWT_SECRET inte finns, används default. **Detta är OK för utveckling men ALDRIG i produktion!**

---

### **PRODUKTION:**

#### ✅ BEST PRACTICE - Azure App Service:

```bash
# Sätt environment variable i Azure
az webapp config appsettings set \
  --resource-group TrafficSchool-RG \
  --name trafficschool-gateway \
  --settings JWT_SECRET="<genererad-stark-secret>"
```

Gör samma för UserService!

#### ✅ BEST PRACTICE - Docker:

```yaml
# docker-compose.yml
services:
  api-gateway:
    environment:
      - JWT_SECRET=${JWT_SECRET}

  user-service:
    environment:
      - JWT_SECRET=${JWT_SECRET}
```

Kör med:

```bash
JWT_SECRET="<stark-secret>" docker-compose up
```

#### ✅ BEST PRACTICE - Kubernetes:

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: jwt-secret
type: Opaque
data:
  jwt-secret: <base64-encoded-secret>
```

```yaml
# deployment.yaml
env:
  - name: JWT_SECRET
    valueFrom:
      secretKeyRef:
        name: jwt-secret
        key: jwt-secret
```

---

## 🔑 GENERERA SÄKER JWT SECRET

### PowerShell (Windows):

```powershell
# Generera 32 bytes slumpmässig secret i Base64
$bytes = New-Object byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
$secret = [Convert]::ToBase64String($bytes)
Write-Host "JWT_SECRET=$secret"
```

### Online Generator:

- https://randomkeygen.com/ (välj "CodeIgniter Encryption Keys")
- https://www.grc.com/passwords.htm

### Bash (Linux/Mac):

```bash
openssl rand -base64 32
```

---

## ✅ CHECKLISTA INNAN PRODUKTION:

- [ ] JWT_SECRET är minst 256 bits (32+ tecken)
- [ ] Samma JWT_SECRET i Gateway och UserService
- [ ] JWT_SECRET läses från environment variable
- [ ] .env filer är i .gitignore
- [ ] Ingen hardkodad secret i kod
- [ ] Secret lagras i Azure Key Vault eller liknande
- [ ] Olika secrets för dev/staging/production

---

## 🧪 TESTA KONFIGURATION:

```powershell
# Starta Gateway med custom secret
$env:JWT_SECRET = "test-secret-123456789012345678"
cd api-gateway
mvnw spring-boot:run

# I annat fönster - Starta UserService med SAMMA secret
$env:JWT_SECRET = "test-secret-123456789012345678"
cd userService
mvnw spring-boot:run

# Testa login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

Om token fungerar genom Gateway → UserService, är konfigurationen korrekt! ✅

---

## 📚 NUVARANDE KONFIGURATION:

| Service        | Läser JWT_SECRET från                       | Fallback Default   |
| -------------- | ------------------------------------------- | ------------------ |
| api-gateway    | application.properties → JWT_SECRET env var | `mySecretKey12...` |
| userService    | application.properties → JWT_SECRET env var | `mySecretKey12...` |
| quizService    | ❌ Behöver EJ (läser headers)               | -                  |
| examService    | ❌ Behöver EJ (läser headers)               | -                  |
| adminService   | ❌ Behöver EJ (läser headers)               | -                  |
| paymentService | ❌ Behöver EJ (läser headers)               | -                  |

**Endast Gateway och UserService behöver JWT_SECRET!**

Övriga services läser X-User-\* headers från Gateway och behöver inte känna till JWT secret.
