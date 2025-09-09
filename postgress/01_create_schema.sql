-- Справочник: Жанры книг
CREATE TABLE IF NOT EXISTS genre (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500)
);

-- Справочник: Издательства
CREATE TABLE IF NOT EXISTS publisher (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100),
    foundation_year INT
);

-- Справочник: Языки
CREATE TABLE IF NOT EXISTS language (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    iso_code VARCHAR(10)
);

-- Справочник: Типы обложек
CREATE TABLE IF NOT EXISTS cover_type (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200)
);

-- Основная сущность: Авторы
CREATE TABLE IF NOT EXISTS author (
    id BIGSERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    birth_date DATE,
    death_date DATE,
    country VARCHAR(100),
    bio TEXT
);

-- Основная сущность: Книги
CREATE TABLE IF NOT EXISTS book (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(20),
    publisher_id INT,
    publication_year INT,
    pages INT,
    language_id INT,
    genre_id INT,
    cover_type_id INT,
    quantity INT DEFAULT 1,
    available_quantity INT DEFAULT 1,
    description TEXT,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publisher (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cover_type_id) REFERENCES cover_type (id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Создание индексов для таблицы book
CREATE INDEX IF NOT EXISTS idx_book_publisher_id ON book (publisher_id);
CREATE INDEX IF NOT EXISTS idx_book_language_id ON book (language_id);
CREATE INDEX IF NOT EXISTS idx_book_genre_id ON book (genre_id);
CREATE INDEX IF NOT EXISTS idx_book_cover_type_id ON book (cover_type_id);

-- Связь многие-ко-многим: Книги и Авторы
CREATE TABLE IF NOT EXISTS book_author (
    id BIGSERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT DEFAULT 1,
    UNIQUE(book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (author_id) REFERENCES author (id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Создание индексов для таблицы book_author
CREATE INDEX IF NOT EXISTS idx_book_author_book_id ON book_author (book_id);
CREATE INDEX IF NOT EXISTS idx_book_author_author_id ON book_author (author_id);

-- Основная сущность: Читатели
CREATE TABLE IF NOT EXISTS reader (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    book_id INT,
    FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Создание индекса для таблицы reader
CREATE INDEX IF NOT EXISTS idx_reader_book_id ON reader (book_id);