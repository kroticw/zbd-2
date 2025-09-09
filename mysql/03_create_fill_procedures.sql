-- Общий объем: ~60000 записей
-- Распределение: 5000 авторов, 30000 книг, 20000 связей книга-автор, 5000 читателей

DELIMITER //

-- Процедура для заполнения таблицы authors (5000 записей)
DROP PROCEDURE IF EXISTS fill_authors//
CREATE PROCEDURE fill_authors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE first_names TEXT DEFAULT 'Александр,Владимир,Николай,Сергей,Дмитрий,Андрей,Михаил,Алексей,Максим,Артем,Иван,Евгений,Павел,Роман,Константин,Юрий,Олег,Антон,Валентин,Денис,Анна,Елена,Татьяна,Ольга,Ирина,Наталья,Екатерина,Светлана,Людмила,Галина,Мария,Виктория,Любовь,Надежда,Вера';
    DECLARE last_names TEXT DEFAULT 'Иванов,Петров,Сидоров,Смирнов,Кузнецов,Попов,Васильев,Соколов,Михайлов,Новиков,Федоров,Морозов,Волков,Алексеев,Лебедев,Семенов,Егоров,Павлов,Козлов,Степанов,Николаев,Орлов,Андреев,Макаров,Никитин,Захаров,Зайцев,Соловьев,Борисов,Яковлев,Григорьев,Романов,Воробьев,Сергеев,Абрамов';
    DECLARE middle_names TEXT DEFAULT 'Александрович,Владимирович,Николаевич,Сергеевич,Дмитриевич,Андреевич,Михайлович,Алексеевич,Максимович,Артемович,Иванович,Евгеньевич,Павлович,Романович,Константинович,Александровна,Владимировна,Николаевна,Сергеевна,Дмитриевна,Андреевна,Михайловна,Алексеевна,Максимовна,Артемовна,Ивановна,Евгеньевна,Павловна,Романовна,Константиновна';
    DECLARE countries TEXT DEFAULT 'Россия,США,Великобритания,Франция,Германия,Италия,Испания,Китай,Япония,Канада,Австралия,Бразилия,Аргентина,Мексика,Индия,Южная Корея,Швеция,Норвегия,Финляндия,Дания';
    
    WHILE i <= 5000 DO
        INSERT INTO author (
            last_name,
            first_name,
            middle_name,
            birth_date,
            death_date,
            country,
            bio
        ) VALUES (
            TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(last_names, ',', FLOOR(1 + RAND() * 35)), ',', -1)),
            TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(first_names, ',', FLOOR(1 + RAND() * 35)), ',', -1)),
            IF(RAND() > 0.3, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(middle_names, ',', FLOOR(1 + RAND() * 30)), ',', -1)), NULL),
            DATE_SUB(CURDATE(), INTERVAL FLOOR(20 + RAND() * 80) YEAR),
            IF(RAND() > 0.8, DATE_SUB(CURDATE(), INTERVAL FLOOR(1 + RAND() * 10) YEAR), NULL),
            TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(countries, ',', FLOOR(1 + RAND() * 20)), ',', -1)),
            CONCAT('Биография автора №', i, '. Известный писатель современности.')
        );
        SET i = i + 1;
    END WHILE;
END//

-- Процедура для заполнения таблицы books (30000 записей)
DROP PROCEDURE IF EXISTS fill_books//
CREATE PROCEDURE fill_books()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE book_titles TEXT DEFAULT 'Тайна,История,Жизнь,Путешествие,Приключения,Война,Мир,Любовь,Время,Память,Судьба,Дорога,Дом,Город,Страна,Мечта,Надежда,Свобода,Правда,Тайна,Загадка,Секрет,Открытие,Поиск,Встреча,Расставание,Возвращение,Победа,Поражение,Счастье,Горе,Радость,Печаль,Солнце,Луна,Звезды,Море,Река,Лес,Гора';
    DECLARE book_suffixes TEXT DEFAULT 'древнего мира,будущего,прошлого,настоящего,забытых дней,новой эры,старого времени,золотого века,серебряного века,бронзового века,каменного века,космической эры,цифрового мира,виртуальной реальности,параллельной вселенной,далекой галактики,неизвестной планеты,потерянного континента,забытого королевства,скрытой империи';
    
    WHILE i <= 30000 DO
        INSERT INTO book (
            title,
            isbn,
            publisher_id,
            publication_year,
            pages,
            language_id,
            genre_id,
            cover_type_id,
            quantity,
            available_quantity,
            description
        ) VALUES (
            CONCAT(
                TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(book_titles, ',', FLOOR(1 + RAND() * 40)), ',', -1)),
                ' ',
                TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(book_suffixes, ',', FLOOR(1 + RAND() * 20)), ',', -1))
            ),
            CONCAT('978-', LPAD(FLOOR(RAND() * 10000000000), 10, '0')),
            FLOOR(1 + RAND() * 10),
            FLOOR(1950 + RAND() * 74),
            FLOOR(100 + RAND() * 900),
            FLOOR(1 + RAND() * 8),
            FLOOR(1 + RAND() * 10),
            FLOOR(1 + RAND() * 3),
            FLOOR(1 + RAND() * 10),
            FLOOR(1 + RAND() * 8),
            CONCAT('Описание книги №', i, '. Увлекательное произведение для широкого круга читателей.')
        );
        SET i = i + 1;
    END WHILE;
END//

-- Процедура для заполнения таблицы book_author (20000 записей)
DROP PROCEDURE IF EXISTS fill_book_authors//
CREATE PROCEDURE fill_book_authors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE book_id_val INT;
    DECLARE author_id_val INT;
    DECLARE max_book_id INT;
    DECLARE max_author_id INT;
    
    SELECT MAX(id) INTO max_book_id FROM book;
    SELECT MAX(id) INTO max_author_id FROM author;
    
    WHILE i <= 20000 DO
        SET book_id_val = FLOOR(1 + RAND() * max_book_id);
        SET author_id_val = FLOOR(1 + RAND() * max_author_id);
        
        -- Проверяем, что такая связь еще не существует
        IF NOT EXISTS(SELECT 1 FROM book_author WHERE book_id = book_id_val AND author_id = author_id_val) THEN
            INSERT INTO book_author (
                book_id,
                author_id,
                author_order
            ) VALUES (
                book_id_val,
                author_id_val,
                1
            );
            SET i = i + 1;
        END IF;
    END WHILE;
END//

-- Процедура для заполнения таблицы readers (5000 записей)
DROP PROCEDURE IF EXISTS fill_readers//
CREATE PROCEDURE fill_readers()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE reader_names TEXT DEFAULT 'Александр Иванов,Мария Петрова,Сергей Сидоров,Елена Смирнова,Дмитрий Кузнецов,Анна Попова,Михаил Васильев,Ольга Соколова,Алексей Михайлов,Татьяна Новикова,Максим Федоров,Ирина Морозова,Артем Волков,Наталья Алексеева,Иван Лебедев,Екатерина Семенова,Евгений Егоров,Светлана Павлова,Павел Козлов,Людмила Степанова,Роман Николаев,Галина Орлова,Константин Андреев,Виктория Макарова,Юрий Никитин,Любовь Захарова,Олег Зайцев,Надежда Соловьева,Антон Борисов,Вера Яковлева';
    DECLARE max_book_id INT;
    
    SELECT MAX(id) INTO max_book_id FROM book;
    
    WHILE i <= 5000 DO
        INSERT INTO reader (
            name,
            phone,
            book_id
        ) VALUES (
            TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(reader_names, ',', FLOOR(1 + RAND() * 30)), ',', -1)),
            CONCAT('+7', LPAD(FLOOR(RAND() * 10000000000), 10, '0')),
            IF(RAND() > 0.3, FLOOR(1 + RAND() * max_book_id), NULL)
        );
        SET i = i + 1;
    END WHILE;
END//

-- Главная процедура для заполнения всех таблиц
DROP PROCEDURE IF EXISTS fill_all_tables//
CREATE PROCEDURE fill_all_tables()
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    SELECT 'Заполнение таблицы авторов...' as status;
    CALL fill_authors();
    
    SELECT 'Заполнение таблицы книг...' as status;
    CALL fill_books();
    
    SELECT 'Заполнение связей книга-автор...' as status;
    CALL fill_book_authors();
    
    SELECT 'Заполнение таблицы читателей...' as status;
    CALL fill_readers();
    
    COMMIT;
    
    SELECT 'Заполнение завершено!' as status;
    SELECT 
        (SELECT COUNT(*) FROM author) as authors_count,
        (SELECT COUNT(*) FROM book) as books_count,
        (SELECT COUNT(*) FROM book_author) as book_author_count,
        (SELECT COUNT(*) FROM reader) as readers_count,
        (SELECT COUNT(*) FROM author) + (SELECT COUNT(*) FROM book) + (SELECT COUNT(*) FROM book_author) + (SELECT COUNT(*) FROM reader) as total_records;
END//

DELIMITER ;

-- Для запуска всех процедур используйте:
-- CALL fill_all_tables();