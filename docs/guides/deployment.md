# Deployment — Azure Container Apps

Hur TrafficSchool driftsätts i produktion med GitHub Actions och Azure Container Apps.

---

## Infrastruktur-översikt

| Resurs                     | Namn                                           |
| -------------------------- | ---------------------------------------------- |
| Resource Group             | `trafficschool-rg`                             |
| Container Apps Environment | `trafficschool-env` (West US 2)                |
| Azure Container Registry   | `trafficschoolacr.azurecr.io`                  |
| Azure Database for MySQL   | `trafficschool-mysql.mysql.database.azure.com` |

---

## CI/CD-flöde

Varje tjänst har ett eget GitHub-repo med en identisk pipeline-struktur:

```
push till main
  └── GitHub Actions (.github/workflows/deploy.yml)
        ├── 1. Checkout kod
        ├── 2. Logga in på Azure (Service Principal)
        ├── 3. Logga in på ACR
        ├── 4. docker build + push → ACR
        └── 5. az containerapp up → Azure Container Apps
```

Deployments sker **oberoende per tjänst** — en push till `userService/main`
driftsätter bara userService, inte övriga.

---

## GitHub Secrets

Dessa secrets måste sättas i varje repos GitHub-inställningar
(**Settings → Secrets and variables → Actions**).

### Alla repos

| Secret                  | Beskrivning                    |
| ----------------------- | ------------------------------ |
| `AZURE_CLIENT_ID`       | Service Principal-klientens ID |
| `AZURE_CLIENT_SECRET`   | Service Principal-hemlighet    |
| `AZURE_SUBSCRIPTION_ID` | Azure-prenumerations-ID        |
| `AZURE_TENANT_ID`       | Azure AD-klientens ID          |
| `ACR_LOGIN_SERVER`      | `trafficschoolacr.azurecr.io`  |
| `ACR_USERNAME`          | ACR-användarnamn               |
| `ACR_PASSWORD`          | ACR-lösenord                   |

### Tjänster med MySQL

| Secret           | Beskrivning                                    |
| ---------------- | ---------------------------------------------- |
| `MYSQL_HOST`     | `trafficschool-mysql.mysql.database.azure.com` |
| `MYSQL_USER`     | MySQL-användarnamn                             |
| `MYSQL_PASSWORD` | MySQL-lösenord                                 |

### Tjänster med JWT / API-nyckel

| Secret            | Repos                                  |
| ----------------- | -------------------------------------- |
| `JWT_SECRET`      | api-gateway, userService, adminService |
| `SERVICE_API_KEY` | alla utom eureka-server                |

### userService-specifika secrets

| Secret                | Beskrivning                                                        |
| --------------------- | ------------------------------------------------------------------ |
| `SENDGRID_API_KEY`    | SendGrid API-nyckel                                                |
| `SENDGRID_FROM_EMAIL` | Avsändaradress                                                     |
| `SENDGRID_FROM_NAME`  | Avsändarnamn                                                       |
| `FRONTEND_URL`        | `https://frontend.redriver-3645ccf7.westus2.azurecontainerapps.io` |

### api-gateway-specifika secrets

| Secret         | Beskrivning                           |
| -------------- | ------------------------------------- |
| `FRONTEND_URL` | Frontend-URL (för CORS-konfiguration) |

---

## Container Apps — ingress per tjänst

| Tjänst            | Ingress      | Port | Publik URL                                                            |
| ----------------- | ------------ | ---- | --------------------------------------------------------------------- |
| `eureka-server`   | internal     | 8761 | —                                                                     |
| `user-service`    | internal     | 8081 | —                                                                     |
| `admin-service`   | internal     | 8082 | —                                                                     |
| `payment-service` | internal     | 8083 | —                                                                     |
| `exam-service`    | internal     | 8084 | —                                                                     |
| `quiz-service`    | internal     | 8085 | —                                                                     |
| `api-gateway`     | **external** | 8080 | `https://api-gateway.redriver-3645ccf7.westus2.azurecontainerapps.io` |
| `frontend`        | **external** | 80   | `https://frontend.redriver-3645ccf7.westus2.azurecontainerapps.io`    |

Alla interna tjänster kommunicerar via Container Apps-nätverket med
DNS-namn som matchar Container App-namnet (t.ex. `http://eureka-server`).

---

## Första deployment (ny miljö)

### 1. Skapa Azure-resurser

```bash
# Resource group
az group create --name trafficschool-rg --location westus2

# Container Registry
az acr create \
  --resource-group trafficschool-rg \
  --name trafficschoolacr \
  --sku Basic \
  --admin-enabled true

# Container Apps Environment
az containerapp env create \
  --name trafficschool-env \
  --resource-group trafficschool-rg \
  --location westus2
```

### 2. Skapa Service Principal för GitHub Actions

```bash
az ad sp create-for-rbac \
  --name "trafficschool-github-actions" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/trafficschool-rg \
  --sdk-auth
```

Fyll in `clientId`, `clientSecret`, `subscriptionId`, `tenantId` som GitHub Secrets.

### 3. Hämta ACR-credentials

```bash
az acr credential show --name trafficschoolacr
```

Sätt `ACR_LOGIN_SERVER`, `ACR_USERNAME`, `ACR_PASSWORD` som GitHub Secrets.

### 4. Driftsätt i rätt ordning

Pusha till `main` i denna ordning (vänta på att varje deployment är klar):

1. `eureka-server` — måste vara `Running` innan övriga kan registrera sig
2. `user-service`, `admin-service`, `payment-service`, `exam-service`, `quiz-service` — i valfri ordning
3. `api-gateway` — sist, efter att alla tjänster är registrerade i Eureka

---

## Löpande uppdateringar

En push till `main` i ett tjänsterepo triggar automatiskt ny deployment.
Inga manuella steg krävs.

Pipeline-steget `az containerapp up` uppdaterar befintlig Container App
(eller skapar den om den inte finns) med den nya imagen.

---

## Frontend

Frontend (`frontend/`) saknar i nuläget Dockerfile och GitHub Actions-workflow.
Den driftsätts manuellt eller via separat process.

**Manuell deployment:**

```bash
cd frontend
npm run build

# Bygg nginx-container (kräver att Dockerfile skapas)
docker build -t trafficschoolacr.azurecr.io/frontend:latest .
docker push trafficschoolacr.azurecr.io/frontend:latest

az containerapp up \
  --name frontend \
  --resource-group trafficschool-rg \
  --environment trafficschool-env \
  --image trafficschoolacr.azurecr.io/frontend:latest \
  --target-port 80 \
  --ingress external
```

---

## Loggar och felsökning

```bash
# Visa loggar för en Container App
az containerapp logs show \
  --name <app-name> \
  --resource-group trafficschool-rg \
  --follow

# Lista alla Container Apps och status
az containerapp list \
  --resource-group trafficschool-rg \
  --output table

# Visa detaljer om en specifik app
az containerapp show \
  --name <app-name> \
  --resource-group trafficschool-rg
```

### Vanliga problem

| Problem                               | Lösning                                                                                  |
| ------------------------------------- | ---------------------------------------------------------------------------------------- |
| Tjänst visas inte i Eureka            | Kontrollera `EUREKA_URL=http://eureka-server/eureka/` och att eureka-server är `Running` |
| `401 Unauthorized` från Gateway       | `JWT_SECRET` matchar inte mellan gateway och userService                                 |
| Swish-webhook når inte paymentService | `SWISH_CALLBACK_URL` måste peka på api-gatewayens publika URL                            |
| Image push misslyckas                 | Verifiera `ACR_LOGIN_SERVER`, `ACR_USERNAME`, `ACR_PASSWORD` i GitHub Secrets            |
