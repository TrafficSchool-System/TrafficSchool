
===========================================
# 🏗 ARKITEKTUR - HUR SYSTEMET HÄNGER IHOP
===========================================

## Services
- Eureka Server (8761)
- API Gateway (8080)
- UserService (8081)
- AdminService (8084)
- PaymentService
----------------------------------

## Kommunikation
- Gateway → Services
- JWT för user
- Intern API-key mellan services
----------------------------------

## Viktigt
❗ Gateway är enda publika entry point
----------------------------------