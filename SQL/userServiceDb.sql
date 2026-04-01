-- Skapa, ta bort och använda
Create database userServiceDb;
drop database userServiceDb;
use userServiceDb;

-- Alla tabeller
select * from subscriptions;
select * from users;
select * from login_token;


-- Kontrollera vilka tabeller som finns
SHOW TABLES;

-- Skapa testanvändare
INSERT INTO users (first_name, last_name, email, personal_number, phone_number, active, role, created_at)
VALUES 
('Anna', 'Andersson', 'anna.andersson@test.se', '199001011234', '0701234567', true, 'USER', NOW()),
('Erik', 'Eriksson', 'erik.eriksson@test.se', '198502025678', '0709876543', true, 'USER', NOW()),
('Maria', 'Svensson', 'maria.svensson@test.se', '199212123456', '0707654321', true, 'USER', NOW());
