-- =====================================================================
--  Adaptive Personalised Learning Path Recommender
--  Step 3(a) : DATABASE SCHEMA
--
--  How to run :   mysql -u root -p < 01_schema.sql
--  Then run   :   mysql -u root -p < 02_seed_data.sql
--
--  Design notes are in SCHEMA_DESIGN.md
-- =====================================================================

DROP DATABASE IF EXISTS adaptive_learning;
CREATE DATABASE adaptive_learning
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE adaptive_learning;


-- ---------------------------------------------------------------------
-- 1. students
--    A student registers through register.jsp. The password is stored
--    as a SHA-256 hex string (64 characters) produced by PasswordUtil.
-- ---------------------------------------------------------------------
CREATE TABLE students (
    student_id     INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    email          VARCHAR(100) NOT NULL,
    password       CHAR(64)     NOT NULL,
    registered_on  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_students_email UNIQUE (email)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 2. teachers
--    Teachers are created by the seed script - there is no public
--    teacher registration page.
-- ---------------------------------------------------------------------
CREATE TABLE teachers (
    teacher_id  INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL,
    password    CHAR(64)     NOT NULL,

    CONSTRAINT uq_teachers_email UNIQUE (email)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 3. topics
--    One row per module of the Python course.
--    topic_order  = position in the learning path (1..8)
--    difficulty   = BASIC or ADVANCED. An ADVANCED topic can only be
--                   unlocked by passing a Golden Assessment.
--    notes        = the study material rendered on topic.jsp
-- ---------------------------------------------------------------------
CREATE TABLE topics (
    topic_id     INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(100) NOT NULL,
    description  VARCHAR(255) NOT NULL,
    notes        TEXT,
    difficulty   ENUM('BASIC','ADVANCED') NOT NULL DEFAULT 'BASIC',
    topic_order  INT NOT NULL,

    CONSTRAINT uq_topics_title UNIQUE (title),
    CONSTRAINT uq_topics_order UNIQUE (topic_order)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 4. questions
--    question_type decides which screen the question appears on:
--       PRACTICE -> practice section (not scored)
--       QUIZ     -> the 10 question topic quiz
--       GOLDEN   -> the 5 challenging Golden Assessment questions
-- ---------------------------------------------------------------------
CREATE TABLE questions (
    question_id     INT AUTO_INCREMENT PRIMARY KEY,
    topic_id        INT           NOT NULL,
    question        VARCHAR(500)  NOT NULL,
    option_a        VARCHAR(255)  NOT NULL,
    option_b        VARCHAR(255)  NOT NULL,
    option_c        VARCHAR(255)  NOT NULL,
    option_d        VARCHAR(255)  NOT NULL,
    correct_answer  ENUM('A','B','C','D')            NOT NULL,
    difficulty      ENUM('EASY','MEDIUM','HARD')     NOT NULL DEFAULT 'EASY',
    question_type   ENUM('PRACTICE','QUIZ','GOLDEN') NOT NULL DEFAULT 'QUIZ',

    CONSTRAINT fk_questions_topic
        FOREIGN KEY (topic_id) REFERENCES topics (topic_id)
        ON DELETE CASCADE,

    INDEX idx_questions_topic_type (topic_id, question_type)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 5. attempts
--    One row per completed quiz or Golden Assessment.
--    Rows are only INSERTed - a retake creates a new row so that the
--    student's full history is preserved.
--    score is stored as a percentage (0..100).
-- ---------------------------------------------------------------------
CREATE TABLE attempts (
    attempt_id       INT AUTO_INCREMENT PRIMARY KEY,
    student_id       INT NOT NULL,
    topic_id         INT NOT NULL,
    attempt_type     ENUM('QUIZ','GOLDEN') NOT NULL DEFAULT 'QUIZ',
    score            INT NOT NULL,
    correct_answers  INT NOT NULL,
    total_questions  INT NOT NULL,
    attempt_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_attempts_student
        FOREIGN KEY (student_id) REFERENCES students (student_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_attempts_topic
        FOREIGN KEY (topic_id) REFERENCES topics (topic_id),

    INDEX idx_attempts_student_topic (student_id, topic_id)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 6. recommendations
--    Written by the Recommendation Engine after every attempt.
--    recommendation_type lets recommendation.jsp draw the correct
--    action button without having to read the message text.
-- ---------------------------------------------------------------------
CREATE TABLE recommendations (
    recommendation_id    INT AUTO_INCREMENT PRIMARY KEY,
    student_id           INT NOT NULL,
    topic_id             INT NOT NULL,
    recommendation_type  ENUM('REVISION','PRACTICE','RETAKE_QUIZ','NEXT_TOPIC',
                              'GOLDEN_ASSESSMENT','UNLOCK_ADVANCED',
                              'ADVANCED_PRACTICE') NOT NULL,
    recommendation       TEXT NOT NULL,
    status               ENUM('PENDING','COMPLETED') NOT NULL DEFAULT 'PENDING',
    created_date         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reco_student
        FOREIGN KEY (student_id) REFERENCES students (student_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_reco_topic
        FOREIGN KEY (topic_id) REFERENCES topics (topic_id)
        ON DELETE CASCADE,

    INDEX idx_reco_student (student_id, created_date)
) ENGINE = InnoDB;
