# Step 2 — Database Schema Design

**Database name:** `adaptive_learning`
**Engine:** InnoDB (needed for FOREIGN KEYs) · **Charset:** utf8mb4

Six tables, exactly as specified. Every column added beyond the specification is
listed in section 6 with the reason it exists — nothing is added "just in case".

---

## 1. ER Diagram

```
        ┌──────────────┐                         ┌──────────────┐
        │   teachers   │                         │    topics    │
        ├──────────────┤                         ├──────────────┤
        │ teacher_id PK│                         │ topic_id  PK │
        │ name         │                         │ title        │
        │ email  UNIQUE│                         │ description  │
        │ password     │                         │ notes        │
        └──────────────┘                         │ difficulty   │
        (manages content,                        │ topic_order  │
         no FK — teachers are                    └──────┬───────┘
         not tied to a topic)                           │ 1
                                                        │
                          ┌─────────────────────────────┼─────────────────────┐
                          │ N                           │ N                   │ N
                   ┌──────┴───────┐             ┌───────┴──────┐      ┌───────┴─────────┐
                   │  questions   │             │   attempts   │      │ recommendations │
                   ├──────────────┤             ├──────────────┤      ├─────────────────┤
                   │ question_id  │             │ attempt_id   │      │recommendation_id│
                   │ topic_id  FK │             │ student_id FK│      │ student_id   FK │
                   │ question     │             │ topic_id   FK│      │ topic_id     FK │
                   │ option_a..d  │             │ attempt_type │      │ recommendation  │
                   │ correct_answ.│             │ score        │      │ recomm._type    │
                   │ difficulty   │             │ correct_ans. │      │ status          │
                   │ question_type│             │ total_ques.  │      │ created_date    │
                   └──────────────┘             │ attempt_date │      └───────┬─────────┘
                                                └───────┬──────┘              │
                                                        │ N                   │ N
                                                        │                     │
                                                    ┌───┴─────────────────────┴───┐
                                                    │          students           │
                                                    ├─────────────────────────────┤
                                                    │ student_id PK               │
                                                    │ name / email UNIQUE / passwd│
                                                    └─────────────────────────────┘
```

**Relationships**

| Parent   | Child           | Type | On delete |
|----------|-----------------|------|-----------|
| topics   | questions       | 1:N  | CASCADE (deleting a topic removes its questions) |
| topics   | attempts        | 1:N  | RESTRICT (never lose a student's history) |
| topics   | recommendations | 1:N  | CASCADE |
| students | attempts        | 1:N  | CASCADE |
| students | recommendations | 1:N  | CASCADE |

---

## 2. Table Definitions

### 2.1 `students`

| Column        | Type          | Constraints                | Notes |
|---------------|---------------|----------------------------|-------|
| student_id    | INT           | PK, AUTO_INCREMENT         | |
| name          | VARCHAR(100)  | NOT NULL                   | |
| email         | VARCHAR(100)  | NOT NULL, **UNIQUE**       | login id |
| password      | CHAR(64)      | NOT NULL                   | SHA-256 hex — see §5 |
| registered_on | TIMESTAMP     | DEFAULT CURRENT_TIMESTAMP  | shown on dashboard |

### 2.2 `teachers`

| Column     | Type          | Constraints           |
|------------|---------------|-----------------------|
| teacher_id | INT           | PK, AUTO_INCREMENT    |
| name       | VARCHAR(100)  | NOT NULL              |
| email      | VARCHAR(100)  | NOT NULL, **UNIQUE**  |
| password   | CHAR(64)      | NOT NULL (SHA-256)    |

Teachers are seeded by the SQL script — there is no teacher registration page.

### 2.3 `topics`

| Column      | Type                        | Constraints            | Notes |
|-------------|-----------------------------|------------------------|-------|
| topic_id    | INT                         | PK, AUTO_INCREMENT     | |
| title       | VARCHAR(100)                | NOT NULL, UNIQUE       | "Loops" |
| description | VARCHAR(255)                | NOT NULL               | one line on the module card |
| notes       | TEXT                        | NULL                   | the study material shown on `topic.jsp` |
| difficulty  | ENUM('BASIC','ADVANCED')    | NOT NULL DEFAULT BASIC | drives the Golden gate |
| topic_order | INT                         | NOT NULL, UNIQUE       | 1..8 — defines the learning path |

Seed order: 1 Variables · 2 Conditions · 3 Loops · 4 Functions *(BASIC)* →
5 OOP · 6 Files · 7 Exception Handling · 8 Modules *(ADVANCED)*.

### 2.4 `questions`

| Column         | Type                                  | Constraints        | Notes |
|----------------|---------------------------------------|--------------------|-------|
| question_id    | INT                                   | PK, AUTO_INCREMENT | |
| topic_id       | INT                                   | NOT NULL, FK       | |
| question       | VARCHAR(500)                          | NOT NULL           | |
| option_a       | VARCHAR(255)                          | NOT NULL           | |
| option_b       | VARCHAR(255)                          | NOT NULL           | |
| option_c       | VARCHAR(255)                          | NOT NULL           | |
| option_d       | VARCHAR(255)                          | NOT NULL           | |
| correct_answer | ENUM('A','B','C','D')                 | NOT NULL           | ENUM = the DB itself rejects bad data |
| difficulty     | ENUM('EASY','MEDIUM','HARD')          | NOT NULL DEFAULT EASY | |
| question_type  | ENUM('PRACTICE','QUIZ','GOLDEN')      | NOT NULL DEFAULT QUIZ | which screen uses it |

Index: `idx_questions_topic_type (topic_id, question_type)` — every question lookup is
"give me the QUIZ questions for topic 3".

Seed volume per topic: 10 PRACTICE (including advanced practice) + **10 QUIZ**
+ 5 GOLDEN = 25 × 8 topics = 200 questions.

> **Why 10 quiz questions and not 5?** With 5 questions the only possible scores
> are 0/20/40/60/80/100, so the `> 80` rule would fire only on a perfect 100%.
> With 10 questions the score moves in steps of 10 and all three rule branches
> are comfortably reachable — which matters when the project is demonstrated.

### 2.5 `attempts`

| Column          | Type                      | Constraints               | Notes |
|-----------------|---------------------------|---------------------------|-------|
| attempt_id      | INT                       | PK, AUTO_INCREMENT        | |
| student_id      | INT                       | NOT NULL, FK              | |
| topic_id        | INT                       | NOT NULL, FK              | |
| attempt_type    | ENUM('QUIZ','GOLDEN')     | NOT NULL DEFAULT QUIZ     | keeps the two histories apart |
| score           | INT                       | NOT NULL                  | **percentage 0–100** |
| correct_answers | INT                       | NOT NULL                  | to display "4 / 5" |
| total_questions | INT                       | NOT NULL                  | |
| attempt_date    | TIMESTAMP                 | DEFAULT CURRENT_TIMESTAMP | |

Index: `idx_student_topic (student_id, topic_id)`.

Attempts are **never updated or deleted** — a retake inserts a new row. Progress
uses the *best* score, history shows every row.

### 2.6 `recommendations`

| Column              | Type                                | Constraints               |
|---------------------|-------------------------------------|---------------------------|
| recommendation_id   | INT                                 | PK, AUTO_INCREMENT        |
| student_id          | INT                                 | NOT NULL, FK              |
| topic_id            | INT                                 | NOT NULL, FK              |
| recommendation_type | ENUM (7 values, see §4)             | NOT NULL                  |
| recommendation      | TEXT                                | NOT NULL — the message shown to the student |
| status              | ENUM('PENDING','COMPLETED')         | NOT NULL DEFAULT PENDING  |
| created_date        | TIMESTAMP                           | DEFAULT CURRENT_TIMESTAMP |

---

## 3. How the schema supports each feature

| Feature                | Query it becomes |
|------------------------|------------------|
| Read Notes             | `topics.notes` for one topic |
| Practice               | `questions WHERE topic_id=? AND question_type='PRACTICE'` |
| Quiz                   | `questions WHERE topic_id=? AND question_type='QUIZ'` |
| Golden Assessment      | `questions WHERE topic_id=? AND question_type='GOLDEN'` (5 rows) |
| View Progress          | `MAX(score) GROUP BY topic_id` from `attempts` |
| Teacher: View Attempts | join `attempts` × `students` × `topics` |
| Topic locked/unlocked  | derived — see §4.2 (**no extra table needed**) |

---

## 4. Rules the schema has to serve

### 4.1 Recommendation rules (after a QUIZ attempt)

| Score    | recommendation_type  | Message shown |
|----------|----------------------|---------------|
| < 50     | `REVISION`           | Revise the notes, then do Practice, then retake the quiz |
| 50 – 80  | `NEXT_TOPIC`         | Good — move on to the next topic |
| > 80     | `GOLDEN_ASSESSMENT`  | Excellent — attempt the Golden Assessment |

After a GOLDEN attempt:

| Golden score | recommendation_type   | Effect |
|--------------|-----------------------|--------|
| ≥ 60 (3 of 5)| `UNLOCK_ADVANCED`     | Advanced topic unlocked |
| < 60         | `ADVANCED_PRACTICE`   | Do advanced practice and try again |

`PRACTICE` and `RETAKE_QUIZ` are the remaining two enum values, used as the
sub-steps of the `REVISION` path.

Engine constants (single place, `engine/RuleConstants.java` in Step 11):
`LOW=50 · HIGH=80 · GOLDEN_COUNT=5 · GOLDEN_PASS=60`.

### 4.2 Unlock rule (pure if/else, computed from `attempts`)

```
topic_order 1                    -> always unlocked
topic is BASIC                   -> unlocked if best QUIZ score on previous topic >= 50
topic is ADVANCED                -> unlocked if best QUIZ score on previous topic >= 50
                                    AND a GOLDEN attempt on the previous topic scored >= 60
```

This is what makes the Golden Assessment *matter*: a student who scores 65% on
Functions can keep practising basics, but the door to OOP only opens by scoring
above 80% and then passing the Golden Assessment. The recommendation engine says
so explicitly, so the student is never stuck without knowing why.

---

## 5. Security decisions

* **Passwords are stored as SHA-256 hex (64 chars)**, hashed by
  `util/PasswordUtil.java` using `java.security.MessageDigest` — part of the JDK,
  no external library, ~10 lines. Plain-text passwords in a database is the one
  thing faculty will ask about.
* Every DAO uses `PreparedStatement`, so `email` and answer values are never
  concatenated into SQL.
* `UNIQUE(email)` means duplicate registration is rejected by the database even
  if the Java check is bypassed.
* ENUM columns mean an invalid `correct_answer` or `status` can never be stored.

---

## 6. Every column added beyond the specification, and why

| Table | Added column | Why it is necessary |
|-------|--------------|---------------------|
| topics | `notes` | "Each topic contains Notes" — there was nowhere to store them |
| topics | `topic_order` | The learning path needs a sequence; "next topic" is undefined without it |
| questions | `question_type` | Practice / Quiz / Golden all read from this table and must be kept apart |
| attempts | `attempt_type` | Golden results must not pollute quiz progress |
| attempts | `correct_answers`, `total_questions` | To show "4 / 5"; recomputing it later is impossible from a percentage |
| recommendations | `recommendation_type` | The JSP renders a different button per recommendation; parsing the message text would be fragile |
| recommendations | `created_date` | "Latest recommendation" needs an ordering |
| students | `registered_on` | Dashboard / teacher view |

Two things deliberately **not** added: a `progress` table (derivable from
`attempts`) and a `topic_unlock` table (derivable from the rule in §4.2).
