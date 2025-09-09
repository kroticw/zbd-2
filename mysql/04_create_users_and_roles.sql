-- Создание 3 ролей
CREATE ROLE 'admin_role';
CREATE ROLE 'librarian_role';
CREATE ROLE 'reader_role';

-- Назначение привилегий ролям
GRANT ALL PRIVILEGES ON *.* TO 'admin_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'librarian_role';
GRANT SELECT ON *.* TO 'reader_role';

-- Создание 3 пользователей
CREATE USER 'admin_user'@'%' IDENTIFIED BY 'admin_password123';
CREATE USER 'librarian_user'@'%' IDENTIFIED BY 'librarian_password123';
CREATE USER 'reader_user'@'%' IDENTIFIED BY 'reader_password123';

-- Назначение ролей пользователям
GRANT 'admin_role' TO 'admin_user'@'%';
GRANT 'librarian_role' TO 'librarian_user'@'%';
GRANT 'reader_role' TO 'reader_user'@'%';

-- Установка ролей по умолчанию
SET DEFAULT ROLE 'admin_role' TO 'admin_user'@'%';
SET DEFAULT ROLE 'librarian_role' TO 'librarian_user'@'%';
SET DEFAULT ROLE 'reader_role' TO 'reader_user'@'%';

-- Применение изменений
FLUSH PRIVILEGES;