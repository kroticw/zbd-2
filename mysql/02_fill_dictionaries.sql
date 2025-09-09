-- Заполнение справочников базовыми данными

-- Жанры книг
INSERT INTO genre (name, description) VALUES ('Роман', 'Крупное эпическое произведение');
INSERT INTO genre (name, description) VALUES ('Детектив', 'Произведение о расследовании преступления');
INSERT INTO genre (name, description) VALUES ('Фантастика', 'Произведение, основанное на фантастических допущениях');
INSERT INTO genre (name, description) VALUES ('Фэнтези', 'Произведение с элементами сказочного и мифологического');
INSERT INTO genre (name, description) VALUES ('Научно-популярная литература', 'Литература о науке для широкого круга читателей');
INSERT INTO genre (name, description) VALUES ('Учебная литература', 'Учебники и пособия');
INSERT INTO genre (name, description) VALUES ('Поэзия', 'Стихотворные произведения');
INSERT INTO genre (name, description) VALUES ('Биография', 'Описание жизни известной личности');
INSERT INTO genre (name, description) VALUES ('Историческая проза', 'Художественное произведение на историческую тему');
INSERT INTO genre (name, description) VALUES ('Приключения', 'Произведение о приключениях и путешествиях');

-- Издательства
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('Эксмо', 'Москва', 'Россия', 1991);
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('АСТ', 'Москва', 'Россия', 1990);
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('Азбука', 'Санкт-Петербург', 'Россия', 1995);
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('Росмэн', 'Москва', 'Россия', 1992);
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('Альпина Паблишер', 'Москва', 'Россия', 1998);
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('Питер', 'Санкт-Петербург', 'Россия', 1991);
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('Penguin Books', 'Лондон', 'Великобритания', 1935);
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('HarperCollins', 'Нью-Йорк', 'США', 1989);
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('Random House', 'Нью-Йорк', 'США', 1927);
INSERT INTO publisher (name, city, country, foundation_year) VALUES ('Macmillan Publishers', 'Лондон', 'Великобритания', 1843);

-- Языки
INSERT INTO language (name, iso_code) VALUES ('Русский', 'ru');
INSERT INTO language (name, iso_code) VALUES ('Английский', 'en');
INSERT INTO language (name, iso_code) VALUES ('Французский', 'fr');
INSERT INTO language (name, iso_code) VALUES ('Немецкий', 'de');
INSERT INTO language (name, iso_code) VALUES ('Испанский', 'es');
INSERT INTO language (name, iso_code) VALUES ('Итальянский', 'it');
INSERT INTO language (name, iso_code) VALUES ('Китайский', 'zh');
INSERT INTO language (name, iso_code) VALUES ('Японский', 'ja');

-- Типы обложек
INSERT INTO cover_type (name, description) VALUES ('Твердая', 'Твердый переплет');
INSERT INTO cover_type (name, description) VALUES ('Мягкая', 'Мягкий переплет');
INSERT INTO cover_type (name, description) VALUES ('Кожаная', 'Переплет из кожи или кожзаменителя');