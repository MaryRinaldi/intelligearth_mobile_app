-- Drop Tables
DROP TABLE IF EXISTS users;

-- Set foreign key checks
SET foreign_key_checks = 0;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user'
);

-- Set foreign key checks
SET foreign_key_checks = 1;
