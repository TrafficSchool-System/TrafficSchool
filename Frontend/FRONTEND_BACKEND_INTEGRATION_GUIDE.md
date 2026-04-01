# 🚀 TRAFFICSCHOOL - KOMPLETT FRONTEND → BACKEND INTEGRATION GUIDE

## 📋 VAD JAG HAR FIXAT:

### ✅ 1. API Endpoints (apiEndpoints.js)

- ❌ Tog bort `/user-service/api`, `/payment-service/api` etc
- ✅ Använder nu direkt `/api/**` (via Gateway på port 8080)
- ✅ Alla requests går genom API Gateway → Gateway routar till rätt service

### ✅ 2. Auth Service (authService.js)

- ❌ Fixade `verifyTokenWithJwt()` från POST → GET med query parameter
- ✅ Backend förväntar: `GET /api/auth/verify-jwt?token=XXX`

### ✅ 3. Payment Service (paymentService.js)

- ✅ Uppdaterade subscription endpoints att matcha backend
- ❌ Tog bort endpoints som inte finns i backend
- ✅ La till `checkSubscriptionValid()` för att kolla aktiv subscription

---

## 🎯 KOMPLETT ANVÄNDARFLÖDE (Frontend → Backend)

### **STEG 1: Registrera Konto (GRATIS, INGEN BETALNING)**

```javascript
// Frontend: RegisterPage.jsx
import { registerUser } from "@features/user-dashboard/services/userService";

const handleRegister = async (formData) => {
  try {
    // POST http://localhost:8080/api/users/register
    const response = await registerUser({
      firstName: "Erik",
      lastName: "Svensson",
      email: "erik@example.com",
      personalNumber: "199001011234",
      phoneNumber: "0701234567",
    });

    // ✅ Konto skapat! Användaren har INGET paket ännu
    console.log("✅ Registrerad:", response);

    // Skicka användaren till login-sidan
    navigate("/login");
  } catch (error) {
    // Visa felmeddelande (email/personnummer finns redan etc)
    console.error("❌ Registrering misslyckades:", error.response.data);
  }
};
```

**Backend Flow:**

```
Frontend POST /api/users/register
  ↓
Gateway :8080 → UserService :8081
  ↓
UserController.register()
  ↓
UserService.registerUser()
  ↓
✅ User skapad i databas
❌ INGEN subscription skapad (det sker efter betalning)
```

---

### **STEG 2: Logga in via Magic Link**

```javascript
// Frontend: LoginPage.jsx
import authService from "@features/auth/services/authService";

// 2A: Användaren anger email
const handleRequestMagicLink = async (email) => {
  try {
    // POST http://localhost:8080/api/auth/login
    await authService.sendMagicLink(email);

    // ✅ Magic link skickat till email
    setMessage("Magic link skickat! Kolla din email.");
  } catch (error) {
    console.error("❌ Kunde inte skicka magic link:", error);
  }
};

// 2B: Användaren klickar på länk i email
// URL: http://localhost:3000/verify?token=ABC123XYZ...

// VerifyPage.jsx
const handleVerifyToken = async (token) => {
  try {
    // GET http://localhost:8080/api/auth/verify-jwt?token=ABC123...
    const response = await authService.verifyTokenWithJwt(token);

    // ✅ response = { token: "JWT...", user: { id, email, firstName, ... } }

    // Token och user sparas automatiskt i localStorage av authService
    console.log("✅ Inloggad som:", response.user);

    // Navigera till dashboard
    navigate("/dashboard");
  } catch (error) {
    console.error("❌ Token ogiltig eller utgången:", error);
    setError("Länken är ogiltig eller har gått ut. Begär en ny länk.");
  }
};
```

**Backend Flow:**

```
Frontend GET /api/auth/verify-jwt?token=XXX
  ↓
Gateway → UserService
  ↓
AuthController.verifyTokenWithJwt()
  ↓
✅ Validerar magic link token
✅ Skapar JWT token med userId, email, roles
✅ Returnerar { token, user }
```

---

### **STEG 3: Kolla om användare har Subscription**

```javascript
// App.jsx - Körs när app startar
import { checkSubscriptionValid } from "@features/payment/services/paymentService";

useEffect(() => {
  if (user?.id) {
    checkUserSubscription();
  }
}, [user]);

const checkUserSubscription = async () => {
  try {
    // GET http://localhost:8080/api/subscriptions/user/1/active
    const hasValidSubscription = await checkSubscriptionValid(user.id);

    setHasSubscription(hasValidSubscription);

    if (!hasValidSubscription) {
      // Visa Paywall - användaren måste köpa paket
      navigate("/payment/paywall");
    }
  } catch (error) {
    console.error("❌ Kunde inte kolla subscription:", error);
  }
};
```

**Backend Flow:**

```
Frontend GET /api/subscriptions/user/1/active
  ↓
Gateway → UserService :8081
  ↓
SubscriptionController.getActiveUserSubscriptions()
  ↓
Kollar userId från JWT (säkerhet!)
  ↓
Om userId i JWT !== userId i URL → 403 Forbidden
Om userId matchar → Returnerar aktiva subscriptions
  ↓
Frontend: Om array.length > 0 → användaren har subscription
```

---

### **STEG 4: Köpa Paket (Paywall)**

```javascript
// PaywallPage.jsx
import {
  getActivePackages,
  initiatePayment,
} from "@features/payment/services/paymentService";

// 4A: Visa tillgängliga paket
useEffect(() => {
  loadPackages();
}, []);

const loadPackages = async () => {
  try {
    // GET http://localhost:8080/api/packages
    const packages = await getActivePackages();

    setPackages(packages);
    // packages = [
    //   { id: 1, name: "Körkortsteori - 30 dagar", price: 299.00, validityDays: 30 },
    //   { id: 2, name: "Körkortsteori - 90 dagar", price: 499.00, validityDays: 90 }
    // ]
  } catch (error) {
    console.error("❌ Kunde inte hämta paket:", error);
  }
};

// 4B: Initiera betalning när användare väljer paket
const handleBuyPackage = async (packageId) => {
  try {
    // POST http://localhost:8080/api/payments/initiate
    const response = await initiatePayment({
      userId: user.id,
      payerAlias: userPhoneNumber, // Swish-telefonnummer
      packageId: packageId,
    });

    // response = { paymentId: "ABC123..." }

    // Spara paymentId för att kolla status
    setPaymentId(response.paymentId);

    // Visa instruktioner: "Öppna Swish och betala..."
    setShowSwishInstructions(true);

    // Starta polling för att kolla betalningsstatus
    startPaymentStatusPolling(response.paymentId);
  } catch (error) {
    console.error("❌ Kunde inte initiera betalning:", error);
  }
};
```

**Backend Flow:**

```
Frontend POST /api/payments/initiate
  ↓
Gateway → PaymentService :8085
  ↓
PaymentController.initiatePayment()
  ↓
PaymentService:
  1. Skapar Payment entity (status: CREATED)
  2. Anropar Swish API
  3. Uppdaterar status till PENDING
  ↓
Returnerar paymentId till frontend
```

---

### **STEG 5: Polling - Vänta på Swish-betalning**

```javascript
// PaywallPage.jsx
const startPaymentStatusPolling = (paymentId) => {
  const pollInterval = setInterval(async () => {
    try {
      // GET http://localhost:8080/api/payments/{paymentId}
      const paymentStatus = await getPaymentStatus(paymentId);

      console.log("Betalningsstatus:", paymentStatus.status);

      if (paymentStatus.status === "PAID") {
        clearInterval(pollInterval);

        // ✅ BETALNING KLAR!
        console.log("✅ Betalning genomförd!");

        // Subscription skapas AUTOMATISKT av backend
        // Vänta lite och uppdatera subscription-status
        setTimeout(() => {
          handleSubscriptionActive(); // Från App.jsx
        }, 1000);
      }

      if (
        paymentStatus.status === "ERROR" ||
        paymentStatus.status === "DECLINED"
      ) {
        clearInterval(pollInterval);
        setError("Betalningen misslyckades. Försök igen.");
      }
    } catch (error) {
      console.error("❌ Kunde inte hämta betalningsstatus:", error);
    }
  }, 2000); // Kolla var 2:a sekund
};
```

**Backend Flow:**

```
Användare betalar i Swish-appen
  ↓
Swish API → PaymentService /api/swish/callback
  ↓
PaymentService.handleSwishCallback():
  1. Uppdaterar payment.status = PAID
  2. Anropar activateSubscriptionForUser()
  ↓
PaymentService → UserService (MED API KEY!)
POST http://localhost:8081/api/subscriptions
Headers: X-Internal-API-Key: TrafficSchool-Internal-Key...
  ↓
UserService SubscriptionController:
  - Kollar @PreAuthorize("hasAnyRole('INTERNAL_SERVICE', 'ADMIN')")
  - API key ger ROLE_INTERNAL_SERVICE
  - ✅ Access granted
  ↓
SubscriptionService.createSubscription():
  - Skapar Subscription entity
  - userId, packageId, startDate, endDate
  - active = true
  ↓
✅ Subscription sparad i databas!
```

---

### **STEG 6: Användare kan nu använda Quiz & Exam**

```javascript
// App.jsx
const handleSubscriptionActive = async () => {
  console.log("✅ Betalning genomförd!");

  // Uppdatera state
  setHasSubscription(true);

  // Navigera till dashboard
  navigate("/dashboard");
};

// Dashboard.jsx
if (hasSubscription) {
  return (
    <div>
      <h1>Välkommen till TrafficSchool!</h1>
      <button onClick={() => navigate("/quiz")}>Starta Quiz</button>
      <button onClick={() => navigate("/exam")}>Starta Prov</button>
    </div>
  );
} else {
  return <Paywall />;
}
```

---

## 🔐 SÄKERHET I FLÖDET:

### **1. JWT Authentication (Användare)**

```javascript
// axios.js
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem("authToken");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Backend: JwtAuthenticationFilter
// Validerar token → Sätter userId och roles i request
```

### **2. Ownership Validation (Användare ser bara sina egna resurser)**

```javascript
// Frontend försöker:
GET /api/subscriptions/user/999  (user 1 försöker se user 999's subscriptions)

// Backend SubscriptionController:
userId från JWT = 1
userId i URL = 999
→ 403 Forbidden: "Du har inte behörighet att se denna användares subscriptions"
```

### **3. Service-to-Service Security (PaymentService → UserService)**

```javascript
// PaymentService WebClientConfig
return WebClient.builder()
  .baseUrl("http://user-service")
  .defaultHeader("X-Internal-API-Key", "TrafficSchool-Internal-Key...")
  .build();

// Backend UserService ServiceApiKeyFilter:
// Validerar API key → Ger ROLE_INTERNAL_SERVICE
// @PreAuthorize("hasAnyRole('INTERNAL_SERVICE', 'ADMIN')") på POST /api/subscriptions
```

---

## 🧪 TESTA FLÖDET:

### **Test 1: Registrera & Logga in**

1. Öppna `http://localhost:3000/register`
2. Fyll i formulär
3. POST /api/users/register → Användare skapad
4. Gå till /login
5. Ange email → POST /api/auth/login
6. Kolla console för magic link (om local dev)
7. Kopiera token, gå till `/verify?token=XXX`
8. GET /api/auth/verify-jwt?token=XXX
9. ✅ Du är inloggad!

### **Test 2: Kolla Subscription**

1. Efter inloggning körs `checkSubscriptionValid(user.id)`
2. GET /api/subscriptions/user/1/active
3. Eftersom det inte finns subscription → Redirect till /paywall

### **Test 3: Köp Paket**

1. På /paywall → GET /api/packages
2. Välj paket → POST /api/payments/initiate
3. Öppna Swish (dev: simulera callback)
4. POST /api/swish/callback { status: "PAID" }
5. Backend skapar subscription automatiskt
6. Frontend polling upptäcker status: PAID
7. ✅ Redirect till /dashboard
8. hasSubscription = true → Kan använda quiz/exam

---

## 📂 FRONTEND FOLDER STRUCTURE:

```
src/
├── features/
│   ├── auth/
│   │   ├── services/authService.js       ← Magic link, JWT
│   │   └── pages/UserLoginPage.jsx
│   │
│   ├── user-dashboard/
│   │   ├── services/userService.js       ← Registrering, profil
│   │   └── pages/UserDashboardPage.jsx
│   │
│   ├── payment/
│   │   ├── services/paymentService.js    ← Paket, betalningar, subscriptions
│   │   ├── pages/Paywall.jsx             ← Visa paket, initiera betalning
│   │   └── pages/SubscriptionPage.jsx    ← Visa användarens subscription
│   │
│   ├── quiz/
│   │   └── pages/ActiveQuizPage.jsx      ← Kräver subscription
│   │
│   └── exam/
│       └── pages/FinalExamPage.jsx       ← Kräver subscription
│
├── shared/
│   ├── constants/
│   │   ├── apiEndpoints.js               ← ✅ UPPDATE RAD
│   │   └── config.js                     ← BASE_URL, STORAGE_KEYS
│   │
│   └── components/
│       └── layout/ProtectedRoute.jsx     ← Kolla hasSubscription
│
├── lib/
│   └── axios.js                          ← JWT interceptor
│
└── app/
    └── App.jsx                           ← Routing, subscription check
```

---

## 🎯 SAMMANFATTNING:

### **ANVÄNDAREN:**

1. Registrerar konto (GRATIS)
2. Loggar in via Magic Link
3. Ser Paywall (ingen subscription)
4. Köper paket med Swish
5. Subscription skapas AUTOMATISKT
6. Kan nu använda quiz & exam

### **BACKEND:**

1. UserService: Användare, auth, subscriptions
2. PaymentService: Paket, betalningar
3. QuizService: Quiz-frågor
4. ExamService: Prov
5. AdminService: Admin-panel
6. Gateway: Entry point, routing

### **SÄKERHET:**

1. JWT för användare
2. API Key för service-to-service
3. Ownership validation (users ser bara sitt)
4. Gateway blockerar interna endpoints

---

**Allt är nu klart! Testa flödet i Postman först, sedan koppla frontend!** 🚀
