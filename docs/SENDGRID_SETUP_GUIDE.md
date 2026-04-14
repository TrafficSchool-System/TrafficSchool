# SendGrid Setup Guide 📧

## 🚀 Snabbstart (Lokal Utveckling)

### Steg 1: Verifiera din email i SendGrid

1. **Logga in på SendGrid:**
   - Gå till: https://app.sendgrid.com/
   - Logga in med ditt konto

2. **Verifiera Single Sender:**

   ```
   Settings → Sender Authentication → Single Sender Verification
   ```

3. **Skapa ny sender:**
   - Klicka **"Create New Sender"**
   - Fyll i formuläret:

     ```
     From Name: Traffic School
     From Email: Fahrikuzey@hotmail.com  (DIN email!)
     Reply To: Fahrikuzey@hotmail.com

     Address: Din adress
     City: Din stad
     Country: Sweden
     ```

4. **Verifiera:**
   - Klicka **"Create"**
   - Kolla din inbox (Fahrikuzey@hotmail.com)
   - **Klicka på verifieringslänken** i mailet från SendGrid
   - ✅ Nu är din email verifierad!

### Steg 2: Uppdatera .env (OM BEHÖVS)

`.env` är redan uppdaterad med:

```env
SENDGRID_FROM_EMAIL=Fahrikuzey@hotmail.com
```

**Om du vill använda annan email:**

```env
SENDGRID_FROM_EMAIL=din-verifierade@email.com
```

### Steg 3: Bygg om user-service

```powershell
# Navigera till projektroten
cd C:\src\projects\TrafficSchool

# Bygg om user-service med nya .env värden
docker compose build --no-cache user-service

# Starta om user-service
docker compose up -d --force-recreate user-service

# Verifiera att det fungerar
docker logs user-service -f
```

### Steg 4: Testa email-funktionen

1. **Registrera ny användare:**
   - Gå till http://localhost:5173
   - Registrera med DIN email (t.ex. Fahrikuzey@hotmail.com)

2. **Kolla inbox:**
   - Du bör få ett welcome email
   - Magic link för inloggning

3. **Kolla logs om problem:**
   ```powershell
   docker logs user-service | Select-String "SendGrid|Email|Magic"
   ```

---

## 🏢 Produktion Setup (Railway)

### Alternativ A: Använda samma personliga email (ENKLAST)

✅ **Fördelar:**

- Inga DNS-ändringar behövs
- Fungerar direkt
- Bra för MVP/testing

❌ **Nackdelar:**

- Ser inte professionellt ut
- "From: Fahrikuzey@hotmail.com" istället för "From: noreply@trafficschool.com"

**Railway Configuration:**

```bash
# Railway Dashboard → user-service → Variables
SENDGRID_API_KEY=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
SENDGRID_FROM_EMAIL=Fahrikuzey@hotmail.com
SENDGRID_FROM_NAME=Traffic School
```

### Alternativ B: Domain Authentication (PROFESSIONELLT)

✅ **Fördelar:**

- Professionellt: "From: noreply@trafficschool.com"
- Bättre deliverability
- Kan skicka från vilket @trafficschool.com email som helst

❌ **Nackdelar:**

- Kräver att du äger domänen trafficschool.com
- Kräver DNS-ändringar (CNAME records)

**Steg:**

1. **SendGrid Dashboard:**

   ```
   Settings → Sender Authentication → Domain Authentication
   ```

2. **Lägg till domän:**
   - Domain: `trafficschool.com`
   - Följ instruktionerna
   - Kopiera DNS-records (CNAME)

3. **Uppdatera DNS hos din domain provider:**
   - Logga in där du köpte trafficschool.com
   - Lägg till CNAME records som SendGrid visar
   - Vänta 24-48 timmar för DNS propagation

4. **Verifiera i SendGrid:**
   - Gå tillbaka till SendGrid
   - Klicka "Verify"
   - ✅ Domain verifierad!

5. **Railway Configuration:**
   ```bash
   SENDGRID_FROM_EMAIL=noreply@trafficschool.com
   SENDGRID_FROM_EMAIL=Traffic School
   ```

---

## 🔐 Säkerhet Best Practices

### Lokal Utveckling (.env)

✅ **GÖR:**

- Använd `.env` för API-nycklar lokalt
- Verifiera att `.env` finns i `.gitignore`
- Använd samma API-nyckel lokalt och i produktion (om du vill)

❌ **GÖR INTE:**

- Committa `.env` till Git
- Dela API-nycklar i chat/email
- Hårdkoda nycklar i källkod

### Produktion (Railway)

✅ **GÖR:**

- Sätt environment variables i Railway Dashboard
- Använd separata API-nycklar för dev/prod (rekommenderas)
- Rotera nycklar regelbundet

❌ **GÖR INTE:**

- Sätt secrets i application.properties eller application-railway.properties
- Använd samma nyckel om dev-nyckeln läcker

### Skapa separata API-nycklar (REKOMMENDERAS)

**SendGrid Dashboard:**

```
Settings → API Keys → Create API Key
```

**Skapa TWO keys:**

1. **Development Key:**
   - Name: `TrafficSchool-Dev`
   - Permissions: Full Access
   - Använd i `.env` lokalt

2. **Production Key:**
   - Name: `TrafficSchool-Production`
   - Permissions: Full Access (eller restricted)
   - Använd i Railway environment variables

**Fördel:** Om dev-key läcker kan du revoke den utan att påverka produktion!

---

## 📊 Verifiera att det fungerar

### Checklista:

- [ ] SendGrid email är verifierad (Single Sender eller Domain)
- [ ] `.env` har rätt `SENDGRID_FROM_EMAIL`
- [ ] user-service är rebuildd med nya .env
- [ ] user-service är igång: `docker ps | findstr user-service`
- [ ] Registrera testanvändare med riktig email
- [ ] Email kommer fram i inbox
- [ ] Magic link fungerar och loggar in
- [ ] Inga SendGrid errors i logs: `docker logs user-service`

### Vanliga problem:

**Problem:** "SendGrid 401 Unauthorized"

```
Lösning: API-nyckel är fel eller revoked
→ Skapa ny API-nyckel i SendGrid
→ Uppdatera .env
→ Rebuild user-service
```

**Problem:** "SendGrid 403 Forbidden - sender not verified"

```
Lösning: Email-adressen är inte verifierad
→ Gå till SendGrid → Sender Authentication
→ Verifiera emailen
→ Eller uppdatera SENDGRID_FROM_EMAIL till verifierad email
```

**Problem:** "Email kommer inte fram"

```
Lösning: Kolla spam-mapp först
→ Kolla SendGrid Activity: https://app.sendgrid.com/email_activity
→ Sök på mottagarens email
→ Se status (Delivered, Bounced, Dropped)
```

**Problem:** "500 Internal Server Error vid registration"

```
Lösning: user-service kan inte ansluta till SendGrid
→ Kolla logs: docker logs user-service
→ Verifiera API_KEY är rätt
→ Verifiera FROM_EMAIL är rätt
```

---

## 🎯 Sammanfattning

**För att komma igång NU:**

1. Gå till SendGrid → Verify single sender (Fahrikuzey@hotmail.com)
2. Klicka på verifieringslänk i din inbox
3. Rebuild user-service: `docker compose build --no-cache user-service`
4. Starta om: `docker compose up -d --force-recreate user-service`
5. Testa registrera användare med riktig email

**För produktion senare:**

- Sätt SendGrid keys som Railway environment variables
- Överväg domain authentication om du äger trafficschool.com
- Skapa separata API-keys för dev/prod

---

## 🆘 Support

**SendGrid Dokumentation:**

- Single Sender: https://docs.sendgrid.com/ui/sending-email/sender-verification
- Domain Auth: https://docs.sendgrid.com/ui/account-and-settings/how-to-set-up-domain-authentication
- API Keys: https://docs.sendgrid.com/ui/account-and-settings/api-keys

**Frågor?**

- Kolla SendGrid Activity för email status
- Kolla user-service logs för errors
- Verify API key har rätt permissions
