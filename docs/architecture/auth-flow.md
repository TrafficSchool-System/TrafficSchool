# Auth-flöde

Systemet har två separata autentiseringsflöden:

- **Användare** — lösenordsfri inloggning via Magic Link + JWT
- **Admins** — email + lösenord + JWT

---

## 1. Användarinloggning (Magic Link)

Ingen lösenordsdatabas. En engångslänk skickas till användarens e-post.

```
1. Användaren anger sin e-postadress
        │
        ▼
   POST /api/auth/login
   { "email": "user@example.com" }
        │
        ▼
2. userService skapar en tidsbegränsad token och skickar e-post via SendGrid
   Länken ser ut som: https://frontend.../verify?token=<uuid>
        │
        ▼
3. Användaren klickar på länken i sin e-post
        │
        ▼
   POST /api/auth/tokens
   { "token": "<uuid>" }
        │
        ▼
4. userService verifierar token (korrekt + ej utgånget)
   Returnerar JWT
   { "token": "eyJhbGci..." }
        │
        ▼
5. Frontend sparar JWT (localStorage / memory)
   Alla efterföljande requests skickar:
   Authorization: Bearer <jwt>
```

**Token-livstid:** Magic link är engångs och tidsbegränsad.  
**JWT-livstid:** Konfigureras via `JWT_SECRET` — samma nyckel i userService och api-gateway.

---

## 2. Admin-inloggning (Email + Lösenord)

Admins autentiseras via adminService med traditionellt email/lösenord.

```
1. Admin anger email + lösenord
        │
        ▼
   POST /api/admin/auth/login
   { "email": "admin@example.com", "password": "..." }
        │
        ▼
2. adminService verifierar mot adminServiceDb
   Returnerar JWT med role: ADMIN
   { "token": "eyJhbGci..." }
        │
        ▼
3. Admin-frontend skickar JWT vid alla efterföljande requests
   Authorization: Bearer <jwt>
```

---

## 3. JWT-validering i API Gateway

Alla inkommande requests (utom publika endpoints) passerar JWT-filtret i Gateway.

```
Inkommande request med Authorization: Bearer <token>
        │
        ▼
JwtAuthenticationGlobalFilter (körs FÖRST, Ordered.HIGHEST_PRECEDENCE)
        │
        ├── Är det en publik endpoint? → Skicka vidare utan validering
        │
        ├── Validera JWT (signatur + expiration)
        │       └── Ogiltigt? → 401 Unauthorized
        │
        ▼
Extrahera från token:
  - userId
  - email
  - role (USER eller ADMIN)
        │
        ▼
Ta bort inkommande X-User-* headers (förhindrar header injection)
Sätt nya headers för downstream:
  - X-User-Id: 42
  - X-User-Email: user@example.com
  - X-User-Role: USER
        │
        ▼
Skicka vidare till rätt tjänst (utan Authorization header)
```

### Publika endpoints (kräver inte JWT)

| Path                    | Metod | Beskrivning             |
| ----------------------- | ----- | ----------------------- |
| `/api/auth/login`       | POST  | Begär magic link        |
| `/api/auth/verify`      | POST  | Verifiera token (basic) |
| `/api/auth/tokens`      | POST  | Logga in, få JWT        |
| `/api/users`            | POST  | Registrera ny användare |
| `/api/admin/auth/login` | POST  | Admin-inloggning        |
| `/api/webhooks/swish`   | POST  | Swish callback          |

---

## 4. Hur tjänster läser användarinfo

Tjänsterna litar **100% på Gateway-headerna** — de validerar aldrig JWT själva.

```java
// Exempel från userService
@GetMapping("/me")
@PreAuthorize("hasAnyRole('USER', 'ADMIN')")
public ResponseEntity<UserResponseDTO> getCurrentUser(
        @AuthenticationPrincipal CustomUserAuthentication auth) {
    Long userId = auth.getUserId(); // Kommer från X-User-Id header
    return ResponseEntity.ok(getUserService.findById(userId));
}
```

`GatewayHeaderAuthenticationFilter` (i varje tjänst) läser headerna och
skapar ett `CustomUserAuthentication`-objekt som läggs i Spring SecurityContext.

---

## 5. Service-till-service (intern API-nyckel)

När en tjänst kallar en annan (t.ex. examService → quizService) används
en intern API-nyckel — inte JWT.

```
examService
    │
    │  GET /api/quizzes/final-exam
    │  X-Internal-API-Key: <SERVICE_API_KEY>
    ▼
quizService
    │
    └── Verifierar API-nyckeln → role INTERNAL_SERVICE
        @PreAuthorize("hasRole('USER') or hasRole('INTERNAL_SERVICE')")
```

**Varför?** Interna tjänster har ingen användare att representera med JWT.
API-nyckeln är en delad hemlighet som aldrig exponeras externt.

---

## Säkerhetssammanfattning

| Hot                                     | Skydd                                                  |
| --------------------------------------- | ------------------------------------------------------ |
| Header injection (X-User-Id förfalskas) | Gateway tar bort alla inkommande X-User-\* headers     |
| Utgångna tokens                         | JWT valideras på expiration i varje request            |
| Magic link återanvändning               | Token är engångsanvändning och tas bort efter verify   |
| Intern trafik utan auth                 | SERVICE_API_KEY krävs för service-till-service calls   |
| JWT secret exponeras                    | Lagras som GitHub Secret + Azure env-var, aldrig i kod |
