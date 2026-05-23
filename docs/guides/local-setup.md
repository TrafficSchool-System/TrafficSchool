# Lokal miljö — setup-guide

Hur du kör hela TrafficSchool-systemet lokalt med Docker Compose.

---

## Förutsättningar

| Verktyg        | Version | Länk                                           |
| -------------- | ------- | ---------------------------------------------- |
| Docker Desktop | ≥ 4.x   | https://www.docker.com/products/docker-desktop |
| Git            | valfri  | https://git-scm.com                            |

Inget Java, Maven eller Node.js behövs lokalt — allt byggs i Docker.

---

## 1. Klona repona

```bash
git clone https://github.com/TrafficSchool-System/TrafficSchool.git
cd TrafficSchool

git clone https://github.com/TrafficSchool-System/eureka-server.git
git clone https://github.com/TrafficSchool-System/api-gateway.git
git clone https://github.com/TrafficSchool-System/userService.git
git clone https://github.com/TrafficSchool-System/adminService.git
git clone https://github.com/TrafficSchool-System/paymentService.git
git clone https://github.com/TrafficSchool-System/examService.git
git clone https://github.com/TrafficSchool-System/quizService.git
git clone https://github.com/TrafficSchool-System/frontend.git
```

Alla kataloger ska ligga bredvid varandra (inte inuti varandra):

```
TrafficSchool/
├── docker-compose.yml
├── eureka-server/
├── api-gateway/
├── userService/
├── adminService/
├── paymentService/
├── examService/
├── quizService/
└── frontend/
```

---

## 2. Skapa `.env`-fil

Skapa en fil som heter `.env` i roten av `TrafficSchool/` med följande innehåll.
Fyll i dina egna värden:

```env
# ── MySQL ──────────────────────────────────────────────
DOCKER_MYSQL_ROOT_PASSWORD=ditt-mysql-lösenord
DOCKER_MYSQL_DATABASE=trafficschool
DOCKER_MYSQL_PORT=3306

# ── JWT ────────────────────────────────────────────────
# Minst 32 tecken lång slumpsträng — måste vara identisk i alla tjänster
JWT_SECRET=din-hemliga-jwt-nyckel-minst-32-tecken

# ── Intern API-nyckel ──────────────────────────────────
# Används för service-to-service kommunikation
SERVICE_API_KEY=din-interna-api-nyckel

# ── SendGrid (e-post för magic links) ──────────────────
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@dindomän.se
SENDGRID_FROM_NAME=TrafficSchool

# ── Frontend URL (CORS) ────────────────────────────────
FRONTEND_URL=http://localhost:5173

# ── Swish ──────────────────────────────────────────────
# Lämna tom eller sätt till test-URL om du inte testar betalningar
SWISH_CALLBACK_URL=https://din-publik-url.ngrok.io/api/webhooks/swish
```

> `.env` är listad i `.gitignore` — den committas aldrig.

---

## 3. Starta systemet

```bash
cd TrafficSchool
docker compose up --build
```

Första gången tar det 3–5 minuter (Maven bygger alla JARs inuti Docker).

**Starta utan att bygga om (efter första gången):**

```bash
docker compose up
```

**Starta i bakgrunden:**

```bash
docker compose up -d
```

---

## 4. Verifiera att allt är uppe

| Tjänst           | URL                   |
| ---------------- | --------------------- |
| Eureka Dashboard | http://localhost:8761 |
| API Gateway      | http://localhost:8080 |
| userService      | http://localhost:8081 |
| adminService     | http://localhost:8082 |
| paymentService   | http://localhost:8083 |
| examService      | http://localhost:8084 |
| quizService      | http://localhost:8085 |

Kontrollera att alla 6 tjänster visas som `UP` i Eureka Dashboard innan du
börjar anropa API Gateway.

---

## 5. Kör frontend separat (valfritt)

Frontend ingår inte i Docker Compose — kör den separat i en terminal:

```bash
cd frontend
npm install
npm run dev
```

Frontend startar på **http://localhost:5173** och pekar på API Gateway
på `http://localhost:8080`.

---

## Startordning (hanteras automatiskt av Docker)

Docker Compose-konfigurationen säkerställer rätt ordning via `depends_on`:

```
mysql (healthcheck)
  └── eureka-server (healthcheck)
        ├── user-service
        ├── admin-service
        ├── payment-service
        ├── quiz-service
        ├── exam-service
        └── api-gateway  ← startar sist
```

---

## Databaser

MySQL-containern skapar automatiskt alla databaser vid första start via
`scripts/init-databases.sql`:

| Databas            | Tjänst         |
| ------------------ | -------------- |
| `userServiceDb`    | userService    |
| `adminServiceDb`   | adminService   |
| `paymentServiceDb` | paymentService |
| `quizServiceDb`    | quizService    |
| `examservicedb`    | examService    |

Tabeller skapas automatiskt av Spring (Hibernate `ddl-auto`).

---

## Stanna och rensa

```bash
# Stoppa alla containrar
docker compose down

# Stoppa och radera volymer (återställer MySQL-data)
docker compose down -v
```

---

## Vanliga problem

| Problem                  | Lösning                                                                                       |
| ------------------------ | --------------------------------------------------------------------------------------------- |
| Tjänst startar om i loop | Vänta på Eureka (`service_healthy`) — kontrollera loggar: `docker compose logs eureka-server` |
| `JWT_SECRET` fel         | Kontrollera att `.env` finns och att värdet är ≥ 32 tecken                                    |
| MySQL ansluter inte      | Kör `docker compose down -v` och starta om för att återinitiera databaser                     |
| Port redan används       | Ändra portmappning i `docker-compose.yml` eller stäng conflicting process                     |
| Magic link fungerar inte | `SENDGRID_API_KEY` saknas eller är ogiltig                                                    |
