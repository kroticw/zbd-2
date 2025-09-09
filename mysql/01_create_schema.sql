-- Справочник: Жанры книг
CREATE TABLE IF NOT EXISTS genre (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500)
);

-- Справочник: Издательства
CREATE TABLE IF NOT EXISTS publisher (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100),
    foundation_year INT
);

-- Справочник: Языки
CREATE TABLE IF NOT EXISTS language (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    iso_code VARCHAR(10)
);

-- Справочник: Типы обложек
CREATE TABLE IF NOT EXISTS cover_type (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200)
);

-- Основная сущность: Авторы
CREATE TABLE IF NOT EXISTS author (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
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
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
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
    KEY idx_book_publisher_id (publisher_id),
    KEY idx_book_language_id (language_id),
    KEY idx_book_genre_id (genre_id),
    KEY idx_book_cover_type_id (cover_type_id),
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) REFERENCES publisher (id),
    CONSTRAINT fk_book_language FOREIGN KEY (language_id) REFERENCES language (id),
    CONSTRAINT fk_book_genre FOREIGN KEY (genre_id) REFERENCES genre (id),
    CONSTRAINT fk_book_cover_type FOREIGN KEY (cover_type_id) REFERENCES cover_type (id)
);

-- Связь многие-ко-многим: Книги и Авторы
CREATE TABLE IF NOT EXISTS book_author (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT DEFAULT 1,
    UNIQUE KEY uq_book_author (book_id, author_id),
    KEY idx_book_author_book_id (book_id),
    KEY idx_book_author_author_id (author_id),
    CONSTRAINT fk_book_author_book FOREIGN KEY (book_id) REFERENCES book (id),
    CONSTRAINT fk_book_author_author FOREIGN KEY (author_id) REFERENCES author (id)
);

-- Основная сущность: Читатели
CREATE TABLE IF NOT EXISTS reader (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    book_id INT,
    KEY idx_reader_book_id (book_id),
    CONSTRAINT fk_reader_book FOREIGN KEY (book_id) REFERENCES book (id)
);