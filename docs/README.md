# 📚 TrafficSchool Documentation

Välkommen till TrafficSchool systemdokumentation!

## 🚨 VIKTIGT - LÄS FÖRST

**🔴 [PRODUCTION READINESS CHECKLIST](./PRODUCTION-READINESS.md)** - KRITISKT att läsa innan deploy!

**📋 [KUNDKRAV CHECKLISTA](./KUNDKRAV-CHECKLISTA.md)** - Vad kunden måste fixa innan lansering

---

## 🚀 Deployment & Production

| Dokument                                              | Syfte                                                |
| ----------------------------------------------------- | ---------------------------------------------------- |
| **[Production Readiness](./PRODUCTION-READINESS.md)** | ⚠️ Komplett checklista + pedagogisk deployment guide |
| **[Kundkrav Checklista](./KUNDKRAV-CHECKLISTA.md)**   | 📋 Vad kunden måste fixa (domän, Swish, Azure)       |

**Deployment Guide inkluderar:**

- 🏠 **Localhost vs Domän** - Pedagogisk förklaring
- 🔄 **Development vs Production** - Hur allt hänger ihop
- 📦 **Docker + Azure** - Steg-för-steg deployment
- 💰 **Kostnadskalkyl** - Månadskostnader & budget
- 🏦 **Swish Production** - Hur får man credentials från banken
- 🌐 **DNS & Domän** - Hur kopplar man domän till Azure
- 🚨 **Troubleshooting** - Vanliga problem & lösningar

---

## 📖 Dokumentationsstruktur

### [00-Overview](./00-Overview/)

Översikt av hela systemet och projektstruktur.

### [01-Architecture](./01-Architecture/)

Systemarkitektur, microservices design, och tekniska beslut.

### [02-Security](./02-Security/)

Säkerhetsdokumentation, JWT authentication, och security best practices.

### [03-Services](./03-Services/)

Detaljerad dokumentation för varje microservice.

### [04-Endpoints](./04-Endpoints/)

API endpoints och integration guides.

### [04-Frontend](./04-Frontend/)

Frontend-specifik dokumentation och UI/UX guidelines.

---

## 🔗 Snabblänkar

| Dokument                                                                 | Beskrivning                         |
| ------------------------------------------------------------------------ | ----------------------------------- |
| **[Production Readiness](./PRODUCTION-READINESS.md)**                    | ⚠️ Checklista för produktionsdeploy |
| [Architecture Overview](./01-Architecture/Architecture.md)               | Systemarkitektur och design         |
| [Security Guide](./02-Security/Security.md)                              | Säkerhetsimplementationer           |
| [API Checklist](./04-Endpoints/Checklist.md)                             | API endpoint status                 |
| [Admin Panel Improvements](./04-Frontend/Admin-Panel-UI-Improvements.md) | Frontend förbättringar              |

---

## 🚀 Quick Start för Utvecklare

1. Läs **[Production Readiness](./PRODUCTION-READINESS.md)** för kritiska säkerhetsfrågor
2. Gå igenom [Architecture](./01-Architecture/Architecture.md) för systemförståelse
3. Kolla [Security Guide](./02-Security/Security.md) för autentisering
4. Använd [Services](./03-Services/) för service-specifik dokumentation

---

## 📝 Uppdatera Dokumentation

När du gör ändringar i systemet:

- ✅ Uppdatera relevant dokumentation
- ✅ Bocka av i Production Readiness checklist
- ✅ Commit documentation tillsammans med kod
- ✅ Håll dokumentationen uppdaterad!

---

**Senast uppdaterad:** 2026-03-13
