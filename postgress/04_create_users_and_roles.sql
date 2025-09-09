-- Создание 3 ролей
CREATE ROLE admin_role;
CREATE ROLE librarian_role;
CREATE ROLE reader_role;

-- Назначение привилегий ролям
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON SCHEMA public TO admin_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO librarian_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO librarian_role;
GRANT USAGE ON SCHEMA public TO librarian_role;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO reader_role;
GRANT USAGE ON SCHEMA public TO reader_role;

-- Создание 2 пользователей
CREATE USER admin_user WITH PASSWORD 'admin_password123';
CREATE USER librarian_user WITH PASSWORD 'librarian_password123';
CREATE USER reader_user WITH PASSWORD 'reader_password123';

-- Назначение ролей пользователям
GRANT admin_role TO admin_user;
GRANT librarian_role TO librarian_user;
GRANT reader_role TO reader_user;
