-- 1. Создание пользователей для VPD
CREATE USER IF NOT EXISTS 'vpd_admin'@'%' IDENTIFIED BY 'vpd_admin_pass';
CREATE USER IF NOT EXISTS 'vpd_user1'@'%' IDENTIFIED BY 'vpd_user1_pass';
CREATE USER IF NOT EXISTS 'vpd_user2'@'%' IDENTIFIED BY 'vpd_user2_pass';
CREATE USER IF NOT EXISTS 'auditor'@'%' IDENTIFIED BY 'auditor_pass';

-- 2. Создание таблицы для управления доступом пользователей к книгам
CREATE TABLE IF NOT EXISTS user_books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(100) NOT NULL,
    book_id INT,
    access_type ENUM('read', 'write', 'admin') NOT NULL,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by VARCHAR(100) DEFAULT NULL,
    FOREIGN KEY (book_id) REFERENCES book(id)
);

-- Создание таблицы для аудита операций
CREATE TABLE IF NOT EXISTS audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    operation_type ENUM('SELECT', 'INSERT', 'UPDATE', 'DELETE') NOT NULL,
    record_id INT,
    old_values JSON,
    new_values JSON,
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    session_id VARCHAR(100)
);

-- 3. Заполнение таблицы доступа тестовыми данными
INSERT INTO user_books (user_id, book_id, access_type, granted_by) VALUES
('vpd_user1', 1, 'read', 'vpd_admin'),
('vpd_user1', 2, 'write', 'vpd_admin'),
('vpd_user1', 3, 'read', 'vpd_admin'),
('vpd_user1', 4, 'read', 'vpd_admin'),
('vpd_user1', 5, 'write', 'vpd_admin'),
('vpd_user2', 1, 'read', 'vpd_admin'),
('vpd_user2', 4, 'write', 'vpd_admin'),
('vpd_user2', 5, 'admin', 'vpd_admin'),
('vpd_user2', 6, 'read', 'vpd_admin'),
('vpd_user2', 7, 'write', 'vpd_admin');

-- 4. Создание VIEW для эмуляции VPD
-- VIEW для пользователей - показывает только доступные им записи
CREATE OR REPLACE VIEW vpd_user_books AS
SELECT ub.* FROM user_books ub
WHERE ub.user_id = SUBSTRING_INDEX(USER(), '@', 1)
   OR SUBSTRING_INDEX(USER(), '@', 1) = 'vpd_admin'
   OR SUBSTRING_INDEX(USER(), '@', 1) = 'root';

-- VIEW для книг с ограничениями доступа
CREATE OR REPLACE VIEW vpd_books AS
SELECT b.* FROM book b
WHERE EXISTS (
    SELECT 1 FROM user_books ub
    WHERE ub.book_id = b.id
      AND ub.user_id = SUBSTRING_INDEX(USER(), '@', 1)
      AND ub.access_type IN ('read', 'write', 'admin')
) OR SUBSTRING_INDEX(USER(), '@', 1) IN ('vpd_admin', 'root');

-- VIEW для авторов (только если есть доступ к хотя бы одной книге автора)
CREATE OR REPLACE VIEW vpd_authors AS
SELECT DISTINCT a.* FROM author a
    JOIN book_author ba ON a.id = ba.author_id
    JOIN book b ON ba.book_id = b.id
WHERE EXISTS (
    SELECT 1 FROM user_books ub
    WHERE ub.book_id = b.id
      AND ub.user_id = SUBSTRING_INDEX(USER(), '@', 1)
      AND ub.access_type IN ('read', 'write', 'admin')
) OR SUBSTRING_INDEX(USER(), '@', 1) IN ('vpd_admin', 'root');

-- VIEW для связей книга-автор
CREATE OR REPLACE VIEW vpd_book_authors AS
SELECT ba.* FROM book_author ba
WHERE EXISTS (
    SELECT 1 FROM user_books ub
    WHERE ub.book_id = ba.book_id
      AND ub.user_id = SUBSTRING_INDEX(USER(), '@', 1)
      AND ub.access_type IN ('read', 'write', 'admin')
) OR SUBSTRING_INDEX(USER(), '@', 1) IN ('vpd_admin', 'root');

-- VIEW для читателей (только связанных с доступными книгами)
CREATE OR REPLACE VIEW vpd_readers AS
SELECT r.* FROM reader r
WHERE r.book_id IS NULL OR EXISTS (
    SELECT 1 FROM user_books ub
    WHERE ub.book_id = r.book_id
      AND ub.user_id = SUBSTRING_INDEX(USER(), '@', 1)
      AND ub.access_type IN ('read', 'write', 'admin')
) OR SUBSTRING_INDEX(USER(), '@', 1) IN ('vpd_admin', 'root');

-- 5. Создание триггеров для аудита
DELIMITER //

-- Триггер для аудита вставок в таблицу book
CREATE TRIGGER book_insert_audit
    AFTER INSERT ON book
    FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        user_name, table_name, operation_type, record_id,
        new_values, ip_address, session_id
    ) VALUES (
     USER(), 'book', 'INSERT', NEW.id,
     JSON_OBJECT(
         'id', NEW.id,
         'title', NEW.title,
         'isbn', NEW.isbn,
         'publisher_id', NEW.publisher_id,
         'publication_year', NEW.publication_year,
         'pages', NEW.pages,
         'language_id', NEW.language_id,
         'genre_id', NEW.genre_id,
         'cover_type_id', NEW.cover_type_id,
         'quantity', NEW.quantity,
         'available_quantity', NEW.available_quantity
     ),
     CONNECTION_ID(), CONNECTION_ID()
    );
END//

-- Триггер для аудита обновлений в таблице book
CREATE TRIGGER book_update_audit
    AFTER UPDATE ON book
    FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        user_name, table_name, operation_type, record_id,
        old_values, new_values, ip_address, session_id
    ) VALUES (
         USER(), 'book', 'UPDATE', NEW.id,
         JSON_OBJECT(
             'id', OLD.id,
             'title', OLD.title,
             'isbn', OLD.isbn,
             'publisher_id', OLD.publisher_id,
             'publication_year', OLD.publication_year,
             'pages', OLD.pages,
             'language_id', OLD.language_id,
             'genre_id', OLD.genre_id,
             'cover_type_id', OLD.cover_type_id,
             'quantity', OLD.quantity,
             'available_quantity', OLD.available_quantity
         ),
         JSON_OBJECT(
             'id', NEW.id,
             'title', NEW.title,
             'isbn', NEW.isbn,
             'publisher_id', NEW.publisher_id,
             'publication_year', NEW.publication_year,
             'pages', NEW.pages,
             'language_id', NEW.language_id,
             'genre_id', NEW.genre_id,
             'cover_type_id', NEW.cover_type_id,
             'quantity', NEW.quantity,
             'available_quantity', NEW.available_quantity
         ),
         CONNECTION_ID(), CONNECTION_ID()
     );
END//

-- Триггер для аудита удалений из таблицы book
CREATE TRIGGER book_delete_audit
    AFTER DELETE ON book
    FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        user_name, table_name, operation_type, record_id,
        old_values, ip_address, session_id
    ) VALUES (
    USER(), 'book', 'DELETE', OLD.id,
    JSON_OBJECT(
        'id', OLD.id,
        'title', OLD.title,
        'isbn', OLD.isbn,
        'publisher_id', OLD.publisher_id,
        'publication_year', OLD.publication_year,
        'pages', OLD.pages,
        'language_id', OLD.language_id,
        'genre_id', OLD.genre_id,
        'cover_type_id', OLD.cover_type_id,
        'quantity', OLD.quantity,
        'available_quantity', OLD.available_quantity
        ),
    CONNECTION_ID(), CONNECTION_ID()
);
END//

-- Триггер для автоматического заполнения granted_by
CREATE TRIGGER user_books_before_insert
    BEFORE INSERT ON user_books
    FOR EACH ROW
BEGIN
    IF NEW.granted_by IS NULL THEN
        SET NEW.granted_by = USER();
    END IF;
END//

DELIMITER ;

-- 6. Выдача прав пользователям
-- Права для vpd_user1 и vpd_user2
GRANT SELECT ON library.vpd_user_books TO 'vpd_user1'@'%', 'vpd_user2'@'%';
GRANT SELECT ON library.vpd_books TO 'vpd_user1'@'%', 'vpd_user2'@'%';
GRANT SELECT ON library.vpd_authors TO 'vpd_user1'@'%', 'vpd_user2'@'%';
GRANT SELECT ON library.vpd_book_authors TO 'vpd_user1'@'%', 'vpd_user2'@'%';
GRANT SELECT ON library.vpd_readers TO 'vpd_user1'@'%', 'vpd_user2'@'%';

-- Права для vpd_admin
GRANT ALL PRIVILEGES ON library.* TO 'vpd_admin'@'%';

-- Права для auditor (только чтение логов)
GRANT SELECT ON library.audit_log TO 'auditor'@'%';
GRANT SELECT ON library.* TO 'auditor'@'%';

-- 7. Создание процедур для управления доступом
DELIMITER //

-- Процедура для предоставления доступа к книге
CREATE PROCEDURE grant_book_access(
    IN p_user_id VARCHAR(100),
    IN p_book_id INT,
    IN p_access_type ENUM('read', 'write', 'admin')
)
BEGIN
    DECLARE current_user_name VARCHAR(100);
    SET current_user_name = SUBSTRING_INDEX(USER(), '@', 1);

    -- Проверяем, что текущий пользователь имеет право предоставлять доступ
    IF current_user_name NOT IN ('vpd_admin', 'root') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access denied: insufficient privileges to grant access';
    END IF;

    INSERT INTO user_books (user_id, book_id, access_type, granted_by)
    VALUES (p_user_id, p_book_id, p_access_type, current_user_name)
    ON DUPLICATE KEY UPDATE
        access_type = p_access_type,
        granted_at = CURRENT_TIMESTAMP,
        granted_by = current_user_name;
END//

-- Процедура для отзыва доступа к книге
CREATE PROCEDURE revoke_book_access(
    IN p_user_id VARCHAR(100),
    IN p_book_id INT
)
BEGIN
    DECLARE current_user_name VARCHAR(100);
    SET current_user_name = SUBSTRING_INDEX(USER(), '@', 1);

    -- Проверяем, что текущий пользователь имеет право отзывать доступ
    IF current_user_name NOT IN ('vpd_admin', 'root') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access denied: insufficient privileges to revoke access';
    END IF;

    DELETE FROM user_books
    WHERE user_id = p_user_id AND book_id = p_book_id;
END//

-- Процедура для просмотра журнала аудита
CREATE PROCEDURE view_audit_log(
    IN p_table_name VARCHAR(100),
    IN p_operation_type VARCHAR(10),
    IN p_date_from DATE,
    IN p_date_to DATE
)
BEGIN
    DECLARE current_user_name VARCHAR(100);
    SET current_user_name = SUBSTRING_INDEX(USER(), '@', 1);

    -- Проверяем права доступа к аудиту
    IF current_user_name NOT IN ('auditor', 'vpd_admin', 'root') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access denied: insufficient privileges to view audit log';
    END IF;

    SELECT * FROM audit_log
    WHERE (p_table_name IS NULL OR table_name = p_table_name)
      AND (p_operation_type IS NULL OR operation_type = p_operation_type)
      AND (p_date_from IS NULL OR DATE(operation_time) >= p_date_from)
      AND (p_date_to IS NULL OR DATE(operation_time) <= p_date_to)
    ORDER BY operation_time DESC
    LIMIT 100;
END//

DELIMITER ;

-- Применение изменений
FLUSH PRIVILEGES;