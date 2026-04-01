============================
# 🔌 ENDPOINTS - CHECKLISTA
============================

Används varje gång en ny endpoint skapas.

## ✅ Steg

1. Skapa endpoint i rätt Service Controller  
2. Lägg till `@PreAuthorize` om behövs (`USER` / `ADMIN`)  
3. Konfigurera i Service `SecurityConfig`  
4. Om **PUBLIC** → lägg till i Gateway:
    - `PUBLIC_PATHS` eller  
    - `PUBLIC_GET_PATHS`
5. Starta om Gateway (vid ändring där)  
6. Testa med Postman
----------------------------------