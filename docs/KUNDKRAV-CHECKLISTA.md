# 📋 CHECKLISTA FÖR KUND - Innan Production Launch

**Datum:** 2026-03-17  
**Projekt:** Traffic School System  
**Deployment Target:** Microsoft Azure

---

## 🎯 VAD BEHÖVER KUNDEN ORDNA?

Denna checklista innehåller allt som **KUNDEN** måste fixa innan vi kan lansera systemet i produktion.

---

## 1️⃣ DOMÄNNAMN (KRITISKT)

### ❓ Har kunden redan en domän?

**JA - Jag har redan en domän:**

```
Exempel: korhjalpen.se, trafikskola.com, etc.

Vi behöver:
✅ Domännamnet (t.ex. korhjalpen.se)
✅ Tillgång till DNS-inställningar (Loopia, Binero, GoDaddy, etc.)

   ALTERNATIVT:
✅ Inloggningsuppgifter till domän-panelen så vi kan konfigurera DNS

Kostnad: 0 kr (redan betald)
Tid: 5 minuter för DNS-konfiguration
```

**NEJ - Jag behöver köpa en domän:**

```
Vi rekommenderar att köpa en .se-domän (trovärdigt för svenska kunder)

Var köper man:
- Loopia.se:     ~100 SEK/år
- Binero.se:     ~150 SEK/år
- Namecheap.com: ~$10/år (~100 SEK/år)

Efter köp:
✅ Ge oss inloggningsuppgifter till DNS-panelen
✅ ELLER vi guidar dig att lägga till 3 DNS-poster

Kostnad: ~100-150 SEK/år
Tid: 10 minuter för köp + 5 minuter DNS-setup
```

**Vill INTE köpa domän just nu (test/demo):**

```
Vi kan lansera med Azure's gratis subdomäner:

Frontend: trafficschool-app.azurestaticapps.net
Backend:  trafficschool-api.azurewebsites.net

✅ Fungerar direkt (ingen kostnad)
⚠️ Ser oprofessionellt ut
⚠️ Rekommenderas INTE för produktion

Senare:
När kunden köper riktig domän kan vi byta på 5 minuter.

Kostnad: 0 kr
```

---

## 2️⃣ SWISH PRODUKTION (KRITISKT för betalningar)

### ❓ Har kunden Swish Handel?

**JA - Jag har redan Swish Handel:**

```
Perfekt! Vi behöver från banken:

✅ Produktions-certifikat (.p12 fil)
   Exempel: Swish_Merchant_PROD_1234567890.p12

✅ Certifikatets lösenord

✅ Merchant Number (Betalningsmottagarnummer)
   Exempel: 1234567890

✅ Swish produktion base URL
   (Brukar vara: https://cpc.getswish.net/swish-cpcapi/api/v2/)

Hur får man detta:
1. Kontakta din bank (Swedbank, Handelsbanken, SEB, etc.)
2. Säg: "Jag behöver produktions-credentials för Swish Handel"
3. Banken skickar certifikat + info via säker kanal

Kostnad: Inkluderat i Swish Handel-abonnemanget
Tid: 1-2 dagar (banken hanterar)
```

**NEJ - Jag behöver ansöka om Swish Handel:**

```
Swish Handel krävs för att ta betalt via Swish.

Så här ansöker du:
1. Kontakta din bank
   - Swedbank: Ring 0771-22 22 22
   - Handelsbanken: Kontakta kontorschefen
   - SEB: Ring 0771-365 365
   - Nordea: Ring 0771-22 44 88

2. Säg: "Jag vill ansöka om Swish Handel för mitt företag"

3. Banken frågar efter:
   ✅ Organisationsnummer
   ✅ Företagsnamn
   ✅ Kontaktperson (namn + telefon)
   ✅ Förväntat transaktionsvolym per månad
   ✅ Hemsida/affärsidé beskrivning

4. Handläggningstid: 1-2 veckor

5. Efter godkännande: Be om produktions-credentials (se ovan)

Kostnad:
- Setup: 0-500 kr (beror på bank)
- Månadskostnad: 0-500 kr/månad
- Per transaktion: ~1-3 kr

Tid: 1-2 veckor handläggning
```

**Vill INTE använda Swish just nu:**

```
Vi kan lansera utan betalningar först, eller använda alternativ:

Alternativ 1: Lansera utan betalningar
- Kommentera ut betalning-funktionen
- Kunden betalar manuellt (faktura, banköverföring)
- Lägger till Swish senare

Alternativ 2: Använd annan betalmetod
- Stripe (kreditkort): Enklare, inget bank-krav
- Klarna Checkout
- PayPal

Alternativ 3: Vänta med lansering
- Först fixa Swish, sedan lansera med allt

Vi rekommenderar: Alternativ 1 (lansera, lägg till Swish senare)

Kostnad: 0 kr
Tid: 0 dagar
```

---

## 3️⃣ MICROSOFT AZURE KONTO

### ❓ Har kunden Azure-konto?

**JA - Jag har redan Azure:**

```
Vi behöver:
✅ Tillgång till kontot (Owner eller Contributor role)
✅ Betalmetod ska vara tillagd (kreditkort)

Kostnad: ~1500-2500 SEK/månad (beroende på användning)
Tid: 5 minuter att ge oss access
```

**NEJ - Jag behöver skapa Azure-konto:**

```
Så här skapar du:
1. Gå till: https://azure.microsoft.com/
2. Klicka "Start free"
3. Logga in med Microsoft-konto (eller skapa nytt)
4. Verifiera identitet (telefonnummer)
5. Lägg till kreditkort (för framtida betalningar)

Första året:
✅ $200 gratis credits (första 30 dagarna)
✅ Många tjänster gratis i 12 månader

Efter det:
💰 ~1500-2500 SEK/månad (beroende på traffic)

Vi hjälper till att optimera kostnader.

Kostnad: 0 kr första månaden, sedan ~1500-2500 SEK/månad
Tid: 15 minuter för setup
```

---

## 4️⃣ EMAIL (SendGrid) - Redan fixat ✅

```
✅ Vi har redan konfigurerat SendGrid Free Tier
✅ Fungerar för: 100 emails/dag
✅ Inget kunden behöver göra

Om mer emails behövs senare:
- SendGrid Essentials: $19.95/månad (50,000 emails/månad)
- Uppgradering tar 2 minuater
```

---

## 5️⃣ SSL/HTTPS CERTIFIKAT - Automatiskt ✅

```
✅ Azure skapar automatiskt SSL-certifikat
✅ HTTPS aktiveras automatiskt
✅ Inget kunden behöver göra
✅ Gratis
```

---

## 📊 SAMMANFATTNING - Vad kostar det?

### **ENGÅNGSKOSTNADER:**

| Vad                 | Kostnad         | Obligatoriskt?                   |
| ------------------- | --------------- | -------------------------------- |
| Domännamn (.se)     | ~100-150 SEK/år | Rekommenderat (ej obligatoriskt) |
| Swish Handel Setup  | 0-500 kr        | Endast om betalningar behövs     |
| Azure Account Setup | 0 kr            | ✅ Obligatoriskt                 |
| **TOTALT ENGÅNGS**  | **~100-650 kr** |                                  |

### **MÅNADSKOSTNADER:**

| Vad                  | Kostnad            | Obligatoriskt?        |
| -------------------- | ------------------ | --------------------- |
| Domännamn            | ~10 kr/månad       | Rekommenderat         |
| Swish Handel         | 0-500 kr/månad     | Endast om betalningar |
| Azure Hosting        | 1500-2500 kr/månad | ✅ Obligatoriskt      |
| SendGrid (Free Tier) | 0 kr               | ✅ Inkluderat         |
| **TOTALT PER MÅNAD** | **~1500-3000 kr**  |                       |

### **BUDGET-ALTERNATIV:**

```
Minimum för lansering (utan domän, utan Swish):
- Azure: ~1500 kr/månad
- Gratis Azure subdomän
- Inga betalningar (lägg till senare)

= 1500 kr/månad för att köra systemet

Komplett production setup:
- Azure: ~1500 kr/månad
- Domän: ~10 kr/månad
- Swish: ~200 kr/månad (genomsnitt)

= ~1700 kr/månad för fullt fungerande system
```

---

## ⏰ TIDSLINJE - Hur lång tid tar det?

### **OM KUNDEN HAR ALLT KLART:**

```
✅ Domän med DNS-access
✅ Swish produktions-credentials
✅ Azure konto med betalmetod

Deployment tid: 1-2 arbetsdagar
```

### **OM KUNDEN MÅSTE FIXA SAKER:**

```
Domän (ny): 10 minuter + DNS propagation (1-24 timmar)
Swish ansökan: 1-2 veckor handläggning
Azure konto: 15 minuter

Total tid innan vi kan lansera: 1-2 veckor (väntar på Swish)
```

### **SNABB LANSERING (Utan vänta på Swish):**

```
Vi kan lansera UTAN betalningar först:
- Dag 1: Azure setup
- Dag 2-3: Deployment
- Dag 4: Tester
- Dag 5: LANSERING! 🚀

Senare: När Swish är klart, uppdatera på 1 timme

= 1 vecka till lansering (utan betalningar)
```

---

## 📝 ACTIONS FÖR KUNDEN - Vad ska göras NU?

### **STEG 1: Fatta beslut (5 minuter)**

```
Beslut att fatta:

1. Domän:
   [ ] Jag har redan domän: ___________________
   [ ] Jag vill köpa ny domän
   [ ] Jag vill använda gratis Azure-domän (test)

2. Swish:
   [ ] Jag har redan Swish Handel (produktions-credentials finns)
   [ ] Jag vill ansöka om Swish Handel (1-2 veckor)
   [ ] Jag vill lansera UTAN betalningar först

3. Azure:
   [ ] Jag har redan Azure-konto
   [ ] Jag vill skapa Azure-konto

4. Budget:
   [ ] Jag godkänner ~1700 kr/månad för hosting + domän + Swish
   [ ] Jag vill ha billigare (endast Azure, ~1500 kr/månad)
```

### **STEG 2: Fixa vad som fattas (1-2 veckor)**

```
Baserat på beslut ovan:

Om domän saknas:
→ Köp domän på Loopia.se eller Binero.se
→ Ge oss inloggning till DNS-panel

Om Swish Handel saknas:
→ Kontakta din bank
→ Ansök om Swish Handel
→ Be om produktions-credentials när godkänd
→ Skicka till oss: Certifikat (.p12 fil) + Lösenord + Merchant Number

Om Azure saknas:
→ Gå till azure.microsoft.com
→ Skapa konto (15 minuter)
→ Lägg till kreditkort
→ Ge oss "Contributor" access till subscription
```

### **STEG 3: Vänta på deployment (1-2 dagar)**

```
När allt är klart:
→ Vi deployer systemet till Azure (1-2 arbetsdagar)
→ Vi konfigurerar domän & SSL
→ Vi testar allt
→ Vi ger dig LIVE system att testa

Du testar:
→ Registrering fungerar
→ Login fungerar
→ Quiz fungerar
→ Betalningar fungerar (om Swish klart)

→ GODKÄNT! LANSERING! 🚀
```

---

## 📞 KONTAKT

**Frågor om denna checklista?**

Email: [DIN EMAIL]  
Telefon: [DITT NUMMER]

**Bankkontakter för Swish Handel:**

- Swedbank: 0771-22 22 22
- Handelsbanken: Kontakta kontor
- SEB: 0771-365 365
- Nordea: 0771-22 44 88

---

## ✅ SNABBVERSION - För kunden som vill ha TL;DR

```
VI BEHÖVER FRÅN ER:

1. DOMÄN (100 kr/år)
   - Antingen ge oss DNS-access till er befintliga domän
   - Eller köp ny på Loopia.se

2. SWISH CREDENTIALS (från er bank)
   - Ring er bank, säg "Jag vill ha Swish Handel"
   - Ta 1-2 veckor, kostar ~200 kr/månad
   - OM NI VILL lansera snabbt: Vi kan skippa detta först

3. AZURE KONTO (~1500 kr/månad hosting)
   - Skapa på azure.microsoft.com (15 min)
   - Lägg till kreditkort
   - Ge oss access

TOTAL KOSTNAD: ~1700 kr/månad när allt är klart

DEPLOYMENT TID: 1-2 veckor (om Swish behövs), annars 1 vecka

FRÅGOR? Kontakta oss!
```

---

**Dokumentet uppdaterat:** 2026-03-17  
**Version:** 1.0
