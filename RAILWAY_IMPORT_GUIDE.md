# Railway Database Import - Med Payment Expiry

## Steg 1: Importera lokal databas till Railway

### Alternativ A: Via Railway Dashboard (Rekommenderat)

1. **Öppna Railway Dashboard**
   - Gå till https://railway.app
   - Välj ditt projekt

2. **Öppna MySQL Database**
   - Klicka på MySQL service
   - Gå till "Data" tab (eller liknande)
   - Eller använd "Connect" för att öppna terminal

3. **Importera SQL-filen**
   ```bash
   # Om Railway har en "Import" knapp, använd den och välj railway-backup.sql
   # Annars använd Connect > MySQL CLI
   ```

### Alternativ B: Via Railway CLI (Snabbast)

```bash
# 1. Installera Railway CLI (om inte redan gjort)
# https://docs.railway.app/develop/cli

# 2. Logga in
railway login

# 3. Länka till ditt projekt
railway link

# 4. Importera databasen
railway run mysql -h <MYSQL_HOST> -P <MYSQL_PORT> -u <MYSQL_USER> -p<MYSQL_PASSWORD> trafficschool < railway-backup.sql
```

### Alternativ C: Via lokal MySQL client

```powershell
# Hämta Railway MySQL credentials från dashboard:
# - MYSQL_HOST
# - MYSQL_PORT
# - MYSQL_USER
# - MYSQL_PASSWORD

# Kör från PowerShell (där railway-backup.sql finns)
Get-Content railway-backup.sql | mysql -h <RAILWAY_HOST> -P <RAILWAY_PORT> -u <RAILWAY_USER> -p<RAILWAY_PASSWORD> trafficschool
```

## Steg 2: Lägg till Payment Expiry-funktionen

**VIKTIGT:** Efter import måste du köra dessa migrations för att lägga till nya kolumner:

```sql
-- 1. Lägg till expires_at kolumn
ALTER TABLE payments
ADD COLUMN expires_at DATETIME DEFAULT NULL
AFTER updated_at;

-- 2. Uppdatera status ENUM för att inkludera EXPIRED
ALTER TABLE payments
MODIFY COLUMN status
ENUM('CANCELLED','CREATED','DECLINED','ERROR','PAID','PENDING','EXPIRED')
NOT NULL;

-- 3. Backfill befintliga betalningar med expiry-tid
UPDATE payments
SET expires_at = DATE_ADD(created_at, INTERVAL 5 MINUTE)
WHERE status IN ('PENDING', 'CREATED')
AND expires_at IS NULL;
```

### Hur köra migrations:

**Via Railway Dashboard:**

1. Gå till MySQL service
2. Klicka "Query" eller "Connect"
3. Kör SQL-kommandona ovan (ett i taget)

**Via Railway CLI:**

```bash
railway connect mysql

# Sedan i MySQL-prompten:
USE trafficschool;

-- Kör de 3 SQL-kommandona...
```

## Steg 3: Verifiera Import

```sql
-- Kolla att tabellerna finns
SHOW TABLES;

-- Kolla användare med aktiva prenumerationer
SELECT u.id, u.email, u.first_name, u.last_name,
       s.package_name, s.start_date, s.end_date
FROM users u
JOIN subscriptions s ON u.id = s.user_id
WHERE s.cancelled = 0 AND s.end_date > NOW()
ORDER BY u.id;

-- Kolla payments (inklusive EXPIRED)
SELECT id, status, amount, created_at, expires_at,
       CASE WHEN expires_at < NOW() THEN 'SHOULD_BE_EXPIRED' ELSE 'OK' END as should_expire
FROM payments
ORDER BY created_at DESC
LIMIT 10;

-- Kolla att expires_at kolumnen finns
DESCRIBE payments;

-- Kolla att EXPIRED finns i status ENUM
SHOW COLUMNS FROM payments WHERE Field='status';
```

## Steg 4: Redeploy Services på Railway

Railway kommer auto-deploya när du pushat till GitHub (redan gjort), men om inte:

1. Gå till Railway Dashboard
2. För varje service (payment-service, frontend):
   - Klicka "Deploy"
   - Eller vänta på auto-deploy från GitHub

## Vad finns i databasen?

Din export innehåller:

- ✅ **2 användare med aktiva prenumerationer** (dina testkonton)
- ✅ **Alla betalningar** (PENDING kommer bli EXPIRED efter 5 min)
- ✅ **Quiz, Exam, Admin-data**
- ✅ **Seeders är avstängda** (ingen dubbel-data)

## Efter Import

När services startar kommer de:

1. ✅ Ansluta till Railway MySQL
2. ✅ Hibernate upptäcker existerande tabeller (gör INGET med `ddl-auto=update`)
3. ✅ PaymentExpiryScheduler börjar köra var 60:e sekund
4. ✅ PENDING betalningar > 5 min gamla blir EXPIRED automatiskt

## Troubleshooting

### Fel: "Unknown column 'expires_at'"

- Du glömde köra Migration Steg 2.1
- Kör: `ALTER TABLE payments ADD COLUMN expires_at DATETIME DEFAULT NULL AFTER updated_at;`

### Fel: "Data truncated for column 'status'"

- Du glömde köra Migration Steg 2.2
- Kör: `ALTER TABLE payments MODIFY COLUMN status ENUM(...,'EXPIRED') NOT NULL;`

### Fel: "Table already exists"

- Databasen har redan tabeller
- Antingen: DROP DATABASE trafficschool; CREATE DATABASE trafficschool;
- Eller: Importera selektiv data

## Nästa Steg

1. ✅ Importera railway-backup.sql till Railway
2. ✅ Köra 3 migrations för payment expiry
3. ✅ Verifiera att data finns
4. ✅ Testa inloggning med de 2 testkontona
5. ✅ Testa skapa betalning → vänta 5 min → se EXPIRED status

## Konton för Kund-Test

När kunden loggar in kan de använda de 2 konton du skapat lokalt:

- Alla quiz-svar
- Alla exam-resultat
- Alla aktiva prenumerationer
- Alla betalningar (inklusive EXPIRED efter 5 min)
