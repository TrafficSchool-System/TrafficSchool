# Git-arbetsflöde

Hur man arbetar med kod i TrafficSchool-projektet.

---

## Repo-struktur

Projektet består av **9 separata git-repos** under organisationen [TrafficSchool-System](https://github.com/TrafficSchool-System):

| Repo | Innehåll |
|------|----------|
| `TrafficSchool` | Docs, docker-compose, scripts |
| `frontend` | React-app |
| `api-gateway` | Spring Cloud Gateway |
| `eureka-server` | Service discovery |
| `userService` | Auth, profiler, prenumerationer |
| `adminService` | Admin-login, användarhantering |
| `paymentService` | Paket, Swish-betalningar |
| `examService` | Teoriprov |
| `quizService` | Quiz och frågebank |

Varje tjänst har sin **egna** `main`-branch och sin **egna** GitHub Actions-pipeline som triggas vid push till `main`.

---

## Branching-strategi

Vi använder **feature branches** — aldrig direkt commit till `main`.

```
main          ──────●──────────────────────●──────
                    │                      │
feature/X           └──●──●──●─────────────┘
```

### Namngivning

```
feature/kort-beskrivning       # ny funktionalitet
fix/vad-som-fixas              # buggfix
chore/vad-som-görs             # underhåll (deps, config, refactor)
docs/vad-som-dokumenteras      # dokumentation
```

**Exempel:**
```
feature/add-quiz-timer
fix/admin-login-503
chore/update-dependencies
docs/add-api-reference
```

---

## Dagligt arbetsflöde

### 1. Starta en ny uppgift

Gå alltid till rätt tjänst-mapp och skapa en ny branch från `main`:

```bash
cd adminService          # eller whichever service you're working on
git checkout main
git pull origin main     # se till att du har senaste versionen
git checkout -b feature/min-feature
```

### 2. Jobba och committa

Gör täta, beskrivande commits. Följ [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git add .
git commit -m "feat: add password reset endpoint"
```

**Commit-typer:**

| Typ | Används för |
|-----|-------------|
| `feat:` | Ny funktionalitet |
| `fix:` | Buggfix |
| `chore:` | Underhåll, refactor, config |
| `docs:` | Dokumentation |
| `test:` | Tester |

### 3. Pusha branchen

```bash
git push origin feature/min-feature
```

### 4. Slå ihop till main

När funktionen är klar, slå ihop till `main` lokalt (eller via GitHub PR):

```bash
git checkout main
git pull origin main
git merge feature/min-feature
git push origin main      # ← triggar automatisk deploy till Azure
```

> **OBS:** Push till `main` triggar GitHub Actions och deployar till Azure Container Apps.  
> Se till att koden är testad innan du pushar.

### 5. Städa upp

```bash
git branch -d feature/min-feature           # ta bort lokalt
git push origin --delete feature/min-feature  # ta bort på GitHub
```

---

## Arbeta med flera tjänster samtidigt

Om en feature kräver ändringar i t.ex. `frontend` **och** `adminService`:

1. Skapa branch med **samma namn** i varje berörd tjänst
2. Jobba parallellt
3. Slå ihop till `main` i varje repo när allt är klart

```bash
# I frontend/
git checkout -b feature/admin-user-export

# I adminService/
git checkout -b feature/admin-user-export
```

---

## Snabbreferens

```bash
# Ny branch
git checkout main && git pull && git checkout -b feature/namn

# Se vad som ändrats
git status
git diff

# Committa
git add -A && git commit -m "feat: beskrivning"

# Pusha och deploya
git checkout main && git merge feature/namn && git push origin main

# Städa upp
git branch -d feature/namn
```
