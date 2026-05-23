# eureka-server

Netflix Eureka-server som fungerar som tjänsteregister för hela systemet.
Alla microservices registrerar sig vid uppstart och löser upp varandras
adresser via Eureka i stället för hårdkodade URLs.

- **Port:** 8761
- **Dashboard:** `http://localhost:8761`
- **Ingen databas**
- **Ingen autentisering**

---

## Ansvar

- Ta emot registreringar från microservices vid uppstart
- Svara på frågor om var en namngiven tjänst kan nås
- Visa ett webb-dashboard med registrerade tjänster och deras status
- Ingen affärslogik — ren infrastruktur

---

## Registrerade tjänster

| Eureka-namn       | Tjänst         | Port |
| ----------------- | -------------- | ---- |
| `api-gateway`     | API Gateway    | 8080 |
| `user-service`    | userService    | 8081 |
| `admin-service`   | adminService   | 8082 |
| `payment-service` | paymentService | 8083 |
| `exam-service`    | examService    | 8084 |
| `quiz-service`    | quizService    | 8085 |

---

## Konfiguration

```properties
eureka.client.registerWithEureka=false  # Registrerar inte sig själv
eureka.client.fetchRegistry=false       # Hämtar inte eget register
server.port=8761
```

Eureka-servern är inte en Eureka-klient — den registrerar inte sig själv.

---

## Hur tjänster ansluter

**Lokalt** — varje tjänsts `application-local.properties`:

```properties
eureka.client.service-url.defaultZone=http://localhost:8761/eureka/
```

**Produktion** — varje tjänsts `application-prod.properties`:

```properties
eureka.client.service-url.defaultZone=${EUREKA_URL:http://eureka-server:8761/eureka/}
```

I produktion (Docker / Azure Container Apps) används `eureka-server` som
hostname — Docker-nätverket löser upp det till rätt container.

---

## Startordning

Eureka-servern **måste startas först** — övriga tjänster misslyckas med
registrering om Eureka inte är uppe.

```
1. eureka-server   (port 8761)
2. userService     (port 8081)
3. adminService    (port 8082)
4. paymentService  (port 8083)
5. quizService     (port 8085)
6. examService     (port 8084)
7. api-gateway     (port 8080)  ← sist, behöver alla tjänster registrerade
```

---

## Miljövariabler

| Variabel                 | Beskrivning                      | Krävs |
| ------------------------ | -------------------------------- | ----- |
| `SPRING_PROFILES_ACTIVE` | Aktiv profil (`prod`)            | Ja    |
| `EUREKA_URL`             | Override för Eureka-URL (valfri) | Nej   |

Eureka-servern har **ingen** databas och **inga** hemligheter utöver ovanstående.

---

## Hälsokontroll

Spring Actuator är aktiverat:

```
GET http://localhost:8761/actuator/health
GET http://localhost:8761/actuator/info
```

---

## Beroenden

- **Inga** — eureka-server är den enda tjänsten utan beroenden till övriga
