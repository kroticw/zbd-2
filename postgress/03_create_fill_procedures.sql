-- Общий объем: ~60000 записей
-- Распределение: 5000 авторов, 30000 книг, 20000 связей книга-автор, 5000 читателей

-- Процедура для заполнения таблицы authors (5000 записей)
CREATE OR REPLACE FUNCTION fill_authors() RETURNS VOID AS $$
DECLARE
    i INT;
    first_names TEXT[] := ARRAY['Александр','Владимир','Николай','Сергей','Дмитрий','Андрей','Михаил','Алексей','Максим','Артем','Иван','Евгений','Павел','Роман','Константин','Юрий','Олег','Антон','Валентин','Денис','Анна','Елена','Татьяна','Ольга','Ирина','Наталья','Екатерина','Светлана','Людмила','Галина','Мария','Виктория','Любовь','Надежда','Вера'];
    last_names TEXT[] := ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Васильев','Соколов','Михайлов','Новиков','Федоров','Морозов','Волков','Алексеев','Лебедев','Семенов','Егоров','Павлов','Козлов','Степанов','Николаев','Орлов','Андреев','Макаров','Никитин','Захаров','Зайцев','Соловьев','Борисов','Яковлев','Григорьев','Романов','Воробьев','Сергеев','Абрамов'];
    middle_names TEXT[] := ARRAY['Александрович','Владимирович','Николаевич','Сергеевич','Дмитриевич','Андреевич','Михайлович','Алексеевич','Максимович','Артемович','Иванович','Евгеньевич','Павлович','Романович','Константинович','Александровна','Владимировна','Николаевна','Сергеевна','Дмитриевна','Андреевна','Михайловна','Алексеевна','Максимовна','Артемовна','Ивановна','Евгеньевна','Павловна','Романовна','Константиновна'];
    countries TEXT[] := ARRAY['Россия','США','Великобритания','Франция','Германия','Италия','Испания','Китай','Япония','Канада','Австралия','Бразилия','Аргентина','Мексика','Индия','Южная Корея','Швеция','Норвегия','Финляндия','Дания'];
BEGIN
    FOR i IN 1..5000 LOOP
        INSERT INTO author (
            last_name,
            first_name,
            middle_name,
            birth_date,
            death_date,
            country,
            bio
        ) VALUES (
            last_names[FLOOR(RANDOM() * array_length(last_names, 1) + 1)::INT],
            first_names[FLOOR(RANDOM() * array_length(first_names, 1) + 1)::INT],
            CASE WHEN RANDOM() > 0.3 THEN middle_names[FLOOR(RANDOM() * array_length(middle_names, 1) + 1)::INT] ELSE NULL END,
            CURRENT_DATE - INTERVAL '1 year' * FLOOR(20 + RANDOM() * 80)::INT,
            CASE WHEN RANDOM() > 0.8 THEN CURRENT_DATE - INTERVAL '1 year' * FLOOR(1 + RANDOM() * 10)::INT ELSE NULL END,
            countries[FLOOR(RANDOM() * array_length(countries, 1) + 1)::INT],
            'Биография автора №' || i || '. Известный писатель современности.'
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Процедура для заполнения таблицы books (30000 записей)
CREATE OR REPLACE FUNCTION fill_books() RETURNS VOID AS $$
DECLARE
    i INT;
    book_titles TEXT[] := ARRAY['Тайна','История','Жизнь','Путешествие','Приключения','Война','Мир','Любовь','Время','Память','Судьба','Дорога','Дом','Город','Страна','Мечта','Надежда','Свобода','Правда','Тайна','Загадка','Секрет','Открытие','Поиск','Встреча','Расставание','Возвращение','Победа','Поражение','Счастье','Горе','Радость','Печаль','Солнце','Луна','Звезды','Море','Река','Лес','Гора'];
    book_suffixes TEXT[] := ARRAY['древнего мира','будущего','прошлого','настоящего','забытых дней','новой эры','старого времени','золотого века','серебряного века','бронзового века','каменного века','космической эры','цифрового мира','виртуальной реальности','параллельной вселенной','далекой галактики','неизвестной планеты','потерянного континента','забытого королевства','скрытой империи'];
BEGIN
    FOR i IN 1..30000 LOOP
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
            book_titles[FLOOR(RANDOM() * array_length(book_titles, 1) + 1)::INT] || ' ' || 
            book_suffixes[FLOOR(RANDOM() * array_length(book_suffixes, 1) + 1)::INT],
            '978-' || LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0'),
            FLOOR(1 + RANDOM() * 10)::INT,
            FLOOR(1950 + RANDOM() * 74)::INT,
            FLOOR(100 + RANDOM() * 900)::INT,
            FLOOR(1 + RANDOM() * 8)::INT,
            FLOOR(1 + RANDOM() * 10)::INT,
            FLOOR(1 + RANDOM() * 3)::INT,
            FLOOR(1 + RANDOM() * 10)::INT,
            FLOOR(1 + RANDOM() * 8)::INT,
            'Описание книги №' || i || '. Увлекательное произведение для широкого круга читателей.'
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Процедура для заполнения таблицы book_author (20000 записей)
CREATE OR REPLACE FUNCTION fill_book_authors() RETURNS VOID AS $$
DECLARE
    i INT := 1;
    book_id_val INT;
    author_id_val INT;
    max_book_id INT;
    max_author_id INT;
    attempts INT;
BEGIN
    SELECT MAX(id) INTO max_book_id FROM book;
    SELECT MAX(id) INTO max_author_id FROM author;
    
    WHILE i <= 20000 LOOP
        attempts := 0;
        LOOP
            book_id_val := FLOOR(1 + RANDOM() * max_book_id)::INT;
            author_id_val := FLOOR(1 + RANDOM() * max_author_id)::INT;
            attempts := attempts + 1;
            
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
                i := i + 1;
                EXIT;
            END IF;
            
            -- Предотвращаем бесконечный цикл
            IF attempts > 100 THEN
                EXIT;
            END IF;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Процедура для заполнения таблицы readers (5000 записей)
CREATE OR REPLACE FUNCTION fill_readers() RETURNS VOID AS $$
DECLARE
    i INT;
    reader_names TEXT[] := ARRAY['Александр Иванов','Мария Петрова','Сергей Сидоров','Елена Смирнова','Дмитрий Кузнецов','Анна Попова','Михаил Васильев','Ольга Соколова','Алексей Михайлов','Татьяна Новикова','Максим Федоров','Ирина Морозова','Артем Волков','Наталья Алексеева','Иван Лебедев','Екатерина Семенова','Евгений Егоров','Светлана Павлова','Павел Козлов','Людмила Степанова','Роман Николаев','Галина Орлова','Константин Андреев','Виктория Макарова','Юрий Никитин','Любовь Захарова','Олег Зайцев','Надежда Соловьева','Антон Борисов','Вера Яковлева'];
    max_book_id INT;
BEGIN
    SELECT MAX(id) INTO max_book_id FROM book;
    
    FOR i IN 1..5000 LOOP
        INSERT INTO reader (
            name,
            phone,
            book_id
        ) VALUES (
            reader_names[FLOOR(RANDOM() * array_length(reader_names, 1) + 1)::INT],
            '+7' || LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0'),
            CASE WHEN RANDOM() > 0.3 THEN FLOOR(1 + RANDOM() * max_book_id)::INT ELSE NULL END
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Главная процедура для заполнения всех таблиц
CREATE OR REPLACE FUNCTION fill_all_tables() RETURNS VOID AS $$
BEGIN
    -- Начинаем транзакцию
    BEGIN
        RAISE NOTICE 'Заполнение таблицы авторов...';
        PERFORM fill_authors();
        
        RAISE NOTICE 'Заполнение таблицы книг...';
        PERFORM fill_books();
        
        RAISE NOTICE 'Заполнение связей книга-автор...';
        PERFORM fill_book_authors();
        
        RAISE NOTICE 'Заполнение таблицы читателей...';
        PERFORM fill_readers();
        
        RAISE NOTICE 'Заполнение завершено!';
        RAISE NOTICE 'Статистика:';
        RAISE NOTICE 'Авторы: %', (SELECT COUNT(*) FROM author);
        RAISE NOTICE 'Книги: %', (SELECT COUNT(*) FROM book);
        RAISE NOTICE 'Связи книга-автор: %', (SELECT COUNT(*) FROM book_author);
        RAISE NOTICE 'Читатели: %', (SELECT COUNT(*) FROM reader);
        RAISE NOTICE 'Всего записей: %', 
            (SELECT COUNT(*) FROM author) + 
            (SELECT COUNT(*) FROM book) + 
            (SELECT COUNT(*) FROM book_author) + 
            (SELECT COUNT(*) FROM reader);
            
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Ошибка при заполнении таблиц: %', SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- Для запуска всех процедур используйте:
-- SELECT fill_all_tables();