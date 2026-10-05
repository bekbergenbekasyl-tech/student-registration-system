-- =============================================================================
-- ДЕРЕКТЕР ҚОРЫНЫҢ СХЕМАСЫ ЖӘНЕ БАСТАПҚЫ МӘЛІМЕТТЕР (DDL & DML)
-- Жоба: Университеттің студенттерді тіркеу ақпараттық жүйесі
-- Автор: Бекберген Бекасыл
-- =============================================================================

-- =============================================================================
-- 1. CREATE TABLE (Кестелерді, Primary Key, Foreign Key және шектеулерді құру)
-- =============================================================================

-- 1.1 Пайдаланушылар кестесі (users)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('student', 'advisor', 'teacher', 'admin')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.2 Эдвайзерлер кестесі (advisors)
CREATE TABLE advisors (
    advisor_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    department VARCHAR(100) NOT NULL,
    CONSTRAINT fk_advisor_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 1.3 Студенттер кестесі (students)
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    student_code VARCHAR(20) UNIQUE NOT NULL,
    major VARCHAR(100) NOT NULL,
    course_year INT CHECK (course_year BETWEEN 1 AND 5),
    advisor_id INT,
    gpa NUMERIC(3, 2) DEFAULT 0.00 CHECK (gpa BETWEEN 0.00 AND 4.00),
    CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_student_advisor FOREIGN KEY (advisor_id) REFERENCES advisors(advisor_id) ON DELETE SET NULL
);

-- 1.4 Пәндер кестесі (courses)
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(150) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0 AND credits <= 10),
    max_capacity INT NOT NULL DEFAULT 30,
    current_enrolled INT DEFAULT 0 CHECK (current_enrolled <= max_capacity)
);

-- 1.5 Тіркеулер кестесі (registrations - Many-to-Many)
CREATE TABLE registrations (
    registration_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'dropped')),
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reg_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_reg_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    CONSTRAINT unique_student_course UNIQUE (student_id, course_id)
);

-- =============================================================================
-- 2. INSERT OPERATORS (Мәліметтер енгізу)
-- =============================================================================

-- Пайдаланушыларды қосу
INSERT INTO users (full_name, email, password_hash, role) VALUES
('Асан Әлібеков', 'a.alibekov@univ.kz', 'hash_pass_123', 'advisor'),
('Бекасыл Бекберген', 'b.bekbergen@univ.kz', 'hash_pass_456', 'student'),
('Айгерім Серікова', 'a.serikova@univ.kz', 'hash_pass_789', 'student');

-- Эдвайзерді қосу
INSERT INTO advisors (user_id, department) VALUES
(1, 'Information Systems');

-- Студенттерді қосу
INSERT INTO students (user_id, student_code, major, course_year, advisor_id, gpa) VALUES
(2, '22BD010203', 'Information Systems', 3, 1, 3.75),
(3, '22BD010204', 'Computer Science', 3, 1, 3.50);

-- Пәндерді қосу
INSERT INTO courses (course_code, course_name, credits, max_capacity) VALUES
('IS301', 'Ақпараттық жүйелерді жобалау мен әзірлеу', 5, 30),
('CS202', 'Деректер қорлары және SQL', 5, 25),
('NET101', 'Компьютерлік желілер', 4, 20);

-- Тіркелу өтінімдерін қосу
INSERT INTO registrations (student_id, course_id, status) VALUES
(1, 1, 'pending'),
(1, 2, 'approved'),
(2, 1, 'pending');

-- =============================================================================
-- 3. UPDATE OPERATORS (Мәліметтерді жаңарту)
-- =============================================================================

-- Студенттің GPA көрсеткішін жаңарту
UPDATE students 
SET gpa = 3.85 
WHERE student_code = '22BD010203';

-- Тіркеу статусын эдвайзер мақұлдады деп өзгерту
UPDATE registrations 
SET status = 'approved' 
WHERE student_id = 1 AND course_id = 1;

-- Пәнге тіркелген студенттер санын арттыру
UPDATE courses 
SET current_enrolled = current_enrolled + 1 
WHERE course_id = 1;

-- =============================================================================
-- 4. DELETE OPERATORS (Мәліметтерді жою)
-- =============================================================================

-- Қабылданбаған тіркеу өтінімдерін жою
DELETE FROM registrations 
WHERE status = 'rejected';

-- Белгілі бір пәнге тіркелуді жою (Drop)
DELETE FROM registrations 
WHERE student_id = 2 AND course_id = 1;