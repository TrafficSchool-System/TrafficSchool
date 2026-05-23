-- ==========================================
-- INITIALIZE ALL MICROSERVICE DATABASES
-- ==========================================
-- This script runs when MySQL container starts for the first time
-- Creates separate databases for each microservice (Database per Service Pattern)

CREATE DATABASE IF NOT EXISTS userServiceDb;
CREATE DATABASE IF NOT EXISTS paymentServiceDb;
CREATE DATABASE IF NOT EXISTS adminServiceDb;
CREATE DATABASE IF NOT EXISTS quizServiceDb;
CREATE DATABASE IF NOT EXISTS examservicedb;

-- Grant all privileges to root user (already has access, but being explicit)
GRANT ALL PRIVILEGES ON userServiceDb.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON paymentServiceDb.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON adminServiceDb.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON quizServiceDb.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON examservicedb.* TO 'root'@'%';

FLUSH PRIVILEGES;

-- Show created databases
SHOW DATABASES;
