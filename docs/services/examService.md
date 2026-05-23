# examService

Hanterar tentamenstillfällen för användare. Hämtar frågor från quizService,
spårar svar i realtid och beräknar resultat vid inlämning.

- **Port:** 8084
- **Åtkomst:** Intern (nås via API Gateway)
- **Databas:** `examservicedb`
- **Eureka-namn:** `exam-service`

---

## Ansvar

- Starta tentamenssessioner (70 frågor hämtas från quizService)
- Spara svar löpande under tentamen (kan ändras innan inlämning)
- Beräkna och spara resultat vid inlämning (godkänt ≥ 70 %, dvs. 49/70)
- Lagra frågor som JSON-snapshot (oföränderliga även om quizService uppdateras)
- Tillhandahålla användar- och systemstatistik

---

## Endpoints

### Tentamen — Användare (`/api/exams`)

Alla endpoints kräver `USER`-roll.

| Metod | Path                           | Auth | Beskrivning                                  |
| ----- | ------------------------------ | ---- | -------------------------------------------- |
| POST  | `/api/exams`                   | USER | Starta ny tentamen (stänger eventuell aktiv) |
| GET   | `/api/exams/active`            | USER | Hämta pågående tentamen                      |
| POST  | `/api/exams/active/answers`    | USER | Skicka in svar på en fråga                   |
| POST  | `/api/exams/active/submission` | USER | Lämna in och avsluta tentamen                |
| GET   | `/api/exams/latest/result`     | USER | Hämta senaste tentamensresultat              |
| GET   | `/api/exams`                   | USER | Lista alla tentamenstillfällen               |
| GET   | `/api/exams/statistics`        | USER | Hämta personlig statistik                    |

### Tentamen — Admin (`/api/admin/exams`)

Alla endpoints kräver `ADMIN`-roll.

| Metod | Path                                    | Auth  | Beskrivning                               |
| ----- | --------------------------------------- | ----- | ----------------------------------------- |
| GET   | `/api/admin/exams/statistics`           | ADMIN | Systemövergripande statistik              |
| GET   | `/api/admin/exams/users/{userId}/exams` | ADMIN | Alla tentamenstillfällen för en användare |

---

## Tentamensflöde

```
1. POST /api/exams
   examService anropar quizService:
   GET /api/quizzes/final-exam  (70 frågor, 14 per ämne × 5 ämnen)
   Sparar frågorna som JSON-snapshot i ExamSession.questionsJson
   Returnerar: ExamSessionDTO med frågor och sessions-ID
        ↓
2. POST /api/exams/active/answers  (upprepas per fråga)
   { "questionId": 42, "selectedAnswer": "A" }
   Svar valideras mot snapshot, sparas i Answer-entity
   Kan ändras hur många gånger som helst innan inlämning
        ↓
3. POST /api/exams/active/submission
   Räknar korrekta svar, skapar Result-entity
   passed = (score >= 49)  → 70 % av 70 frågor
   Sätter ExamSession.finished = true
        ↓
4. GET /api/exams/latest/result
   Returnerar: { score, passed, finishedAt, ... }
```

---

## Kommunikation med quizService

examService anropar quizService via WebClient med intern API-nyckel:

```
Header: X-Internal-API-Key: <SERVICE_API_KEY>
GET http://quiz-service/api/quizzes/final-exam     (lokal / Eureka)
GET http://quizservice:8085/api/quizzes/final-exam  (prod)
```

Konfiguration:

| Miljö | URL                                             |
| ----- | ----------------------------------------------- |
| Lokal | `quiz.service.url=http://quiz-service` (Eureka) |
| Prod  | `quiz.service.url=http://quizservice:8085`      |

---

## Godkändgräns

| Totalt frågor | Godkänt krav  | Procent |
| ------------- | ------------- | ------- |
| 70            | ≥ 49 korrekta | 70 %    |

---

## Databas

### Tabell: `exam_session`

| Kolumn           | Typ         | Beskrivning                |
| ---------------- | ----------- | -------------------------- |
| `id`             | BIGINT (PK) | Auto-increment             |
| `user_id`        | BIGINT      | Koppling till användare    |
| `starts_at`      | DATETIME    | Starttid (UTC)             |
| `expires_at`     | DATETIME    | Utgångstid (UTC)           |
| `finished`       | BOOLEAN     | `true` = inlämnad          |
| `questions_json` | TEXT        | JSON-snapshot av 70 frågor |

### Tabell: `result`

| Kolumn            | Typ         | Beskrivning                  |
| ----------------- | ----------- | ---------------------------- |
| `id`              | BIGINT (PK) | Auto-increment               |
| `score`           | INT         | Antal korrekta svar          |
| `passed`          | BOOLEAN     | `true` = godkänt (≥ 49/70)   |
| `finished_at`     | DATETIME    | Inlämningstid (UTC)          |
| `exam_session_id` | BIGINT (FK) | Koppling till `exam_session` |

### Tabell: `answer`

| Kolumn            | Typ         | Beskrivning                  |
| ----------------- | ----------- | ---------------------------- |
| `id`              | BIGINT (PK) | Auto-increment               |
| `user_id`         | BIGINT      | Koppling till användare      |
| `question_id`     | BIGINT      | Fråge-ID från quizService    |
| `selected_answer` | VARCHAR     | Valt svarsalternativ         |
| `correct`         | BOOLEAN     | Om svaret är rätt            |
| `exam_session_id` | BIGINT (FK) | Koppling till `exam_session` |

---

## Miljövariabler

| Variabel                 | Beskrivning                                  | Krävs |
| ------------------------ | -------------------------------------------- | ----- |
| `MYSQLHOST`              | Databasadress                                | Ja    |
| `MYSQLPORT`              | Databasport (default 3306)                   | Ja    |
| `MYSQLDATABASE`          | Databasnamn (`examservicedb`)                | Ja    |
| `MYSQLUSER`              | Databasanvändare                             | Ja    |
| `MYSQLPASSWORD`          | Databaslösenord                              | Ja    |
| `JWT_SECRET`             | Signeringsnyckel — måste matcha api-gateway  | Ja    |
| `SERVICE_API_KEY`        | Intern API-nyckel (skickas till quizService) | Ja    |
| `QUIZ_SERVICE_URL`       | URL till quizService                         | Ja    |
| `SPRING_PROFILES_ACTIVE` | Aktiv profil (`prod`)                        | Ja    |

---

## Beroenden

- **Eureka Server** — registrerar sig vid uppstart
- **MySQL** — `examservicedb`
- **quizService** — hämtar 70 frågor via intern WebClient-anrop vid varje ny tentamen
- **api-gateway** — JWT_SECRET måste vara identisk
