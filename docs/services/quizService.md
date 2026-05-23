# quizService

Hanterar fragebankens frågor och levererar dem till användare och examService.
Admin kan importera frågor från Excel-filer och redigera dem i efterhand.

- **Port:** 8085
- **Åtkomst:** Intern (nås via API Gateway)
- **Databas:** `quizServiceDb`
- **Eureka-namn:** `quiz-service`

---

## Ansvar

- Leverera 70 slumpmässiga frågor för tentamen (14 per ämne × 5 ämnen)
- Leverera övningsfrågor filtrerade på ämne(n)
- Tillhandahålla CRUD för frågor via admin-panel
- Importera frågor från Excel- och ZIP-filer
- Spåra vilka frågor som kom från vilken import

---

## Endpoints

### Quiz — Användare (`/api/quizzes`)

| Metod | Path                      | Auth            | Beskrivning            |
| ----- | ------------------------- | --------------- | ---------------------- |
| GET   | `/api/quizzes/final-exam` | USER / INTERNAL | 70 frågor för tentamen |
| GET   | `/api/quizzes/sessions`   | USER            | Övningsfrågor per ämne |

**Query-parametrar för `/sessions`:**

| Parameter  | Typ             | Krävs            | Beskrivning                                  |
| ---------- | --------------- | ---------------- | -------------------------------------------- |
| `subjects` | `List<Integer>` | Ja               | Ämnen att inkludera, t.ex. `?subjects=1,2,3` |
| `limit`    | `Integer`       | Nej (default 10) | Totalt antal frågor                          |

Frågorna fördelas jämnt per ämne och blandas sedan slumpmässigt.

### Quiz — Admin (`/api/admin/quizzes`)

Alla endpoints kräver `ADMIN`-roll.

| Metod  | Path                            | Auth  | Beskrivning                     |
| ------ | ------------------------------- | ----- | ------------------------------- |
| GET    | `/api/admin/quizzes`            | ADMIN | Lista alla frågor               |
| GET    | `/api/admin/quizzes/{id}`       | ADMIN | Hämta specifik fråga            |
| PUT    | `/api/admin/quizzes/{id}`       | ADMIN | Uppdatera fråga                 |
| POST   | `/api/admin/quizzes/imports`    | ADMIN | Importera frågor från Excel/ZIP |
| GET    | `/api/admin/quizzes/files`      | ADMIN | Lista tidigare importer         |
| DELETE | `/api/admin/quizzes/files/{id}` | ADMIN | Ta bort importpost              |

---

## Tentamen — frågeurval

`GET /api/quizzes/final-exam` returnerar alltid **70 frågor**:

| Ämne       | Antal frågor |
| ---------- | ------------ |
| Subject 1  | 14           |
| Subject 2  | 14           |
| Subject 3  | 14           |
| Subject 4  | 14           |
| Subject 5  | 14           |
| **Totalt** | **70**       |

Frågorna blandas slumpmässigt innan de returneras.

---

## Intern åtkomst (examService)

examService anropar quizService direkt med intern API-nyckel:

```
Header: X-Internal-API-Key: <SERVICE_API_KEY>
GET /api/quizzes/final-exam
```

Rollen `INTERNAL_SERVICE` ger samma åtkomst som `USER` för detta endpoint.

---

## Excel-import

Admin kan ladda upp Excel- eller ZIP-filer med frågor via admin-panelen.
Varje fråga kopplas till sin importfil (`ExcelImportFile`) för spårbarhet.

- `dryRun = true` → validering utan att spara frågor
- Frågor kan kopplas loss från sin importfil innan filen raderas

---

## Databas

### Tabell: `question`

| Kolumn                                     | Typ         | Beskrivning                               |
| ------------------------------------------ | ----------- | ----------------------------------------- |
| `id`                                       | BIGINT (PK) | Auto-increment                            |
| `excel_id`                                 | INT         | Rad-ID i ursprunglig Excel-fil            |
| `question`                                 | VARCHAR     | Frågetext (svenska)                       |
| `sfi`                                      | VARCHAR     | Förenklad frågetext (SFI)                 |
| `correct_answer`                           | VARCHAR     | Rätt svar                                 |
| `wrong_answer1`                            | VARCHAR     | Fel svar 1                                |
| `wrong_answer2`                            | VARCHAR     | Fel svar 2                                |
| `wrong_answer3`                            | VARCHAR     | Fel svar 3                                |
| `explanation_for_student`                  | TEXT        | Förklaring som visas efter svar           |
| `image`                                    | VARCHAR     | URL till extern bild (om frågan har bild) |
| `subject`                                  | INT         | Ämne (1–5)                                |
| `lang`                                     | VARCHAR     | Språkkod (`sv`, `en`, etc.)               |
| `a`, `am`, `b`, `be`, `c`, `ce`, `d`, `de` | INT         | Körkortstyp (1 = gäller, 0 = gäller ej)   |
| `ykb_c`, `ykb_d`, `adr`, `vtl`, etc.       | INT         | Yrkesrelaterade kategorier                |
| `excel_import_file_id`                     | BIGINT (FK) | Koppling till `excel_imports`             |

> Svarsalternativen blandas slumpmässigt i DTO:n — frontend vet inte vilket som är rätt.

### Tabell: `excel_imports`

| Kolumn        | Typ         | Beskrivning                       |
| ------------- | ----------- | --------------------------------- |
| `id`          | BIGINT (PK) | Auto-increment                    |
| `file_name`   | VARCHAR     | Originalfilnamn                   |
| `uploaded_at` | DATETIME    | Uppladdningstidpunkt              |
| `dry_run`     | BOOLEAN     | `true` = validering utan sparande |

---

## Miljövariabler

| Variabel                 | Beskrivning                                   | Krävs |
| ------------------------ | --------------------------------------------- | ----- |
| `MYSQLHOST`              | Databasadress                                 | Ja    |
| `MYSQLPORT`              | Databasport (default 3306)                    | Ja    |
| `MYSQLDATABASE`          | Databasnamn (`quizServiceDb`)                 | Ja    |
| `MYSQLUSER`              | Databasanvändare                              | Ja    |
| `MYSQLPASSWORD`          | Databaslösenord                               | Ja    |
| `JWT_SECRET`             | Signeringsnyckel — måste matcha api-gateway   | Ja    |
| `SERVICE_API_KEY`        | Intern API-nyckel (valideras mot examService) | Ja    |
| `SPRING_PROFILES_ACTIVE` | Aktiv profil (`prod`)                         | Ja    |

---

## Beroenden

- **Eureka Server** — registrerar sig vid uppstart
- **MySQL** — `quizServiceDb`
- **examService** — anropar `/api/quizzes/final-exam` vid varje ny tentamen
- **api-gateway** — JWT_SECRET måste vara identisk
