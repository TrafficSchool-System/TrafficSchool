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