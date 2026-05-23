# Miljövariabler

Komplett referens för alla miljövariabler i TrafficSchool-systemet.
Inga faktiska värden anges här — se din `.env`-fil eller secrets-hanteraren.

---

## Gemensamma variabler (används i flera tjänster)

| Variabel                 | Används i                                                                        | Beskrivning                                                                                  |
| ------------------------ | -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `JWT_SECRET`             | api-gateway, userService, adminService                                           | Signerings-nyckel för JWT-token. Minst 32 tecken. Måste vara identisk i alla tjänster.       |
| `SERVICE_API_KEY`        | api-gateway, userService, adminService, paymentService, examService, quizService | Intern API-nyckel för service-to-service kommunikation (skickas som `X-API-Key`-header).     |
| `MYSQLHOST`              | userService, adminService, paymentService, examService, quizService              | Hostname för MySQL-server. Lokalt: `mysql` (Docker-tjänstnamn).                              |
| `MYSQLPORT`              | alla DB-tjänster                                                                 | MySQL-port. Standard: `3306`.                                                                |
| `MYSQLDATABASE`          | alla DB-tjänster                                                                 | Databasnamn per tjänst (se tabell nedan).                                                    |
| `MYSQLUSER`              | alla DB-tjänster                                                                 | MySQL-användarnamn. Standard: `root`.                                                        |
| `MYSQLPASSWORD`          | alla DB-tjänster                                                                 | MySQL-lösenord.                                                                              |
| `EUREKA_URL`             | alla tjänster utom eureka-server                                                 | URL till Eureka. Lokalt: `http://eureka-server:8761/eureka/`.                                |
| `SERVICE_NAME`           | alla tjänster                                                                    | Eureka-instansnamn. Används sällan — defaults är hårdkodade i `application-prod.properties`. |
| `PORT`                   | alla tjänster                                                                    | HTTP-port. Standard per tjänst (se nedan). Sätts av Railway/Azure automatiskt.               |
| `SPRING_PROFILES_ACTIVE` | alla tjänster                                                                    | Spring-profil. Sätts till `prod` i Docker Compose och produktion.                            |

### Databasnamn per tjänst

| Tjänst         | `MYSQLDATABASE` standardvärde |
| -------------- | ----------------------------- |
| userService    | `userServiceDb`               |
| adminService   | `adminServiceDb`              |
| paymentService | `paymentServiceDb`            |
| examService    | `examservicedb`               |
| quizService    | `quizServiceDb`               |

---

## userService

| Variabel                | Krävs | Standardvärde                       | Beskrivning                                                    |
| ----------------------- | ----- | ----------------------------------- | -------------------------------------------------------------- |
| `MYSQLHOST`             | Ja    | `mysql-user`                        | MySQL-host                                                     |
| `MYSQLPORT`             | Nej   | `3306`                              | MySQL-port                                                     |
| `MYSQLDATABASE`         | Nej   | `userServiceDb`                     | Databasnamn                                                    |
| `MYSQLUSER`             | Nej   | `root`                              | MySQL-användare                                                |
| `MYSQLPASSWORD`         | Ja    | —                                   | MySQL-lösenord                                                 |
| `JWT_SECRET`            | Ja    | —                                   | JWT-signeringsnyckel                                           |
| `SERVICE_API_KEY`       | Ja    | —                                   | Intern API-nyckel                                              |
| `SENDGRID_API_KEY`      | Ja    | —                                   | SendGrid-nyckel för e-post                                     |
| `SENDGRID_FROM_EMAIL`   | Nej   | `noreply@trafficschool.com`         | Avsändaradress                                                 |
| `SENDGRID_FROM_NAME`    | Nej   | `Traffic School`                    | Avsändarnamn                                                   |
| `FRONTEND_URL`          | Ja    | —                                   | Frontend-URL, används för magic link: `${FRONTEND_URL}/verify` |
| `MAGIC_LINK_EXPIRATION` | Nej   | `300000`                            | Magic link-giltighetstid i millisekunder (5 min)               |
| `EUREKA_URL`            | Nej   | `http://eureka-server:8761/eureka/` | Eureka-URL                                                     |
| `PORT`                  | Nej   | `8081`                              | HTTP-port                                                      |

---

## adminService

| Variabel          | Krävs | Standardvärde                       | Beskrivning          |
| ----------------- | ----- | ----------------------------------- | -------------------- |
| `MYSQLHOST`       | Ja    | `mysql-admin`                       | MySQL-host           |
| `MYSQLPORT`       | Nej   | `3306`                              | MySQL-port           |
| `MYSQLDATABASE`   | Nej   | `adminServiceDb`                    | Databasnamn          |
| `MYSQLUSER`       | Nej   | `root`                              | MySQL-användare      |
| `MYSQLPASSWORD`   | Ja    | —                                   | MySQL-lösenord       |
| `JWT_SECRET`      | Ja    | —                                   | JWT-signeringsnyckel |
| `SERVICE_API_KEY` | Ja    | —                                   | Intern API-nyckel    |
| `EUREKA_URL`      | Nej   | `http://eureka-server:8761/eureka/` | Eureka-URL           |
| `PORT`            | Nej   | `8082`                              | HTTP-port            |

---

## paymentService

| Variabel                  | Krävs | Standardvärde                       | Beskrivning                                                                |
| ------------------------- | ----- | ----------------------------------- | -------------------------------------------------------------------------- |
| `MYSQLHOST`               | Ja    | `mysql-payment`                     | MySQL-host                                                                 |
| `MYSQLPORT`               | Nej   | `3306`                              | MySQL-port                                                                 |
| `MYSQLDATABASE`           | Nej   | `paymentServiceDb`                  | Databasnamn                                                                |
| `MYSQLUSER`               | Nej   | `root`                              | MySQL-användare                                                            |
| `MYSQLPASSWORD`           | Ja    | —                                   | MySQL-lösenord                                                             |
| `SERVICE_API_KEY`         | Ja    | —                                   | Intern API-nyckel                                                          |
| `SWISH_BASE_URL`          | Nej   | `https://cpc.getswish.net`          | Swish API-endpoint (byt till test-URL för sandlåda)                        |
| `SWISH_MERCHANT_NUMBER`   | Ja    | —                                   | Swish-handlarnummer                                                        |
| `SWISH_CALLBACK_URL`      | Ja    | —                                   | Publik URL dit Swish skickar webhooks: `https://<host>/api/webhooks/swish` |
| `SWISH_KEYSTORE_PATH`     | Ja    | —                                   | Sökväg till Swish TLS-keystore (`.p12`-fil)                                |
| `SWISH_KEYSTORE_PASSWORD` | Ja    | —                                   | Lösenord till keystoren                                                    |
| `SWISH_CA_CERT_PATH`      | Ja    | —                                   | Sökväg till Swish CA-certifikat                                            |
| `EUREKA_URL`              | Nej   | `http://eureka-server:8761/eureka/` | Eureka-URL                                                                 |
| `PORT`                    | Nej   | `8083`                              | HTTP-port                                                                  |

---

## examService

| Variabel          | Krävs | Standardvärde                       | Beskrivning       |
| ----------------- | ----- | ----------------------------------- | ----------------- |
| `MYSQLHOST`       | Ja    | `mysql-exam`                        | MySQL-host        |
| `MYSQLPORT`       | Nej   | `3306`                              | MySQL-port        |
| `MYSQLDATABASE`   | Nej   | `examservicedb`                     | Databasnamn       |
| `MYSQLUSER`       | Nej   | `root`                              | MySQL-användare   |
| `MYSQLPASSWORD`   | Ja    | —                                   | MySQL-lösenord    |
| `SERVICE_API_KEY` | Ja    | —                                   | Intern API-nyckel |
| `EUREKA_URL`      | Nej   | `http://eureka-server:8761/eureka/` | Eureka-URL        |
| `PORT`            | Nej   | `8084`                              | HTTP-port         |

---

## quizService

| Variabel          | Krävs | Standardvärde                       | Beskrivning       |
| ----------------- | ----- | ----------------------------------- | ----------------- |
| `MYSQLHOST`       | Ja    | `mysql-quiz`                        | MySQL-host        |
| `MYSQLPORT`       | Nej   | `3306`                              | MySQL-port        |
| `MYSQLDATABASE`   | Nej   | `quizServiceDb`                     | Databasnamn       |
| `MYSQLUSER`       | Nej   | `root`                              | MySQL-användare   |
| `MYSQLPASSWORD`   | Ja    | —                                   | MySQL-lösenord    |
| `SERVICE_API_KEY` | Ja    | —                                   | Intern API-nyckel |
| `EUREKA_URL`      | Nej   | `http://eureka-server:8761/eureka/` | Eureka-URL        |
| `PORT`            | Nej   | `8085`                              | HTTP-port         |

---

## api-gateway

| Variabel                 | Krävs | Standardvärde                       | Beskrivning                                                   |
| ------------------------ | ----- | ----------------------------------- | ------------------------------------------------------------- |
| `JWT_SECRET`             | Ja    | —                                   | JWT-signeringsnyckel — måste matcha userService               |
| `SERVICE_API_KEY`        | Ja    | —                                   | Intern API-nyckel som injiceras i upstream-anrop              |
| `EUREKA_URL`             | Nej   | `http://eureka-server:8761/eureka/` | Eureka-URL                                                    |
| `SPRING_PROFILES_ACTIVE` | Ja    | —                                   | Sätts till `prod` för att aktivera produktionskonfigurationen |

---

## eureka-server

Eureka-servern har inga känsliga miljövariabler. Konfigurationen är statisk i
`application.properties`. Port är hårdkodad till `8761`.

---

## Docker Compose — `.env`-mallsfil

Kopiera och fyll i:

```env
# MySQL
DOCKER_MYSQL_ROOT_PASSWORD=
DOCKER_MYSQL_DATABASE=trafficschool
DOCKER_MYSQL_PORT=3306

# JWT (minst 32 tecken)
JWT_SECRET=

# Intern service-nyckel
SERVICE_API_KEY=

# SendGrid
SENDGRID_API_KEY=
SENDGRID_FROM_EMAIL=noreply@dindomän.se
SENDGRID_FROM_NAME=TrafficSchool

# Frontend
FRONTEND_URL=http://localhost:5173

# Swish (lämna tom om du inte testar betalningar)
SWISH_CALLBACK_URL=
```

---

## Produktion (Azure Container Apps)

I Azure Container Apps sätts miljövariabler under
**Container Apps → Environment → Secrets** (känsliga)
och **Environment variables** (icke-känsliga).

Alla `MYSQL*`-variabler pekar på Azure Database for MySQL:
`trafficschool-mysql.mysql.database.azure.com`.

Se [deployment.md](deployment.md) för detaljer om Azure-konfigurationen.
