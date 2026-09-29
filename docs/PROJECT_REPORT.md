# ADAPTIVE PERSONALISED LEARNING PATH RECOMMENDER

**Project Based Learning report — Web Technologies**

**Python Programming course demonstrator**

**Institution:** [College Name]

**Department:** [Department Name]

**Academic year:** [Academic Year]

**Submitted by:** [Student Name(s) and Roll Number(s)]

**Project guide:** [Guide Name and Designation]
**Date:** 29 September 2026

---

## Certificate

This is to certify that the project titled **Adaptive Personalised Learning Path Recommender** was carried out by [Student Name(s)] for the Web Technologies Project Based Learning course under the guidance of [Guide Name]. The application and this report describe the demonstrable minimum viable product as verified on 29 September 2026.

**Guide signature:** ____________________    **Head of department:** ____________________

## Declaration

We declare that this report describes the implementation and testing of the project named above. External libraries and platform components are identified in the technology chapter. Institution-specific names, roll numbers and signatures should be completed before submission.

**Student signature(s):** ____________________

## Acknowledgement

We thank [Guide Name], [Department Name] and [College Name] for their guidance and the opportunity to develop this Web Technologies project.

## Abstract

Many learning sites give every learner the same next lesson even when their quiz performance shows different needs. This project implements a small adaptive Python course in which a student's next action is calculated from recorded results. A quiz score below 50% recommends revision; 50–80% permits progress to the next basic topic; above 80% opens a five-question Golden Assessment. Passing that assessment with at least 60% is required before the next advanced topic unlocks. Students can study, practise, take assessments, see feedback and track progress. Teachers can maintain course content and inspect student activity.

The browser interface uses HTML, CSS, JavaScript and Bootstrap; JSP and Servlets handle pages and requests; JavaBeans and a plain Java rule engine make decisions; JDBC and MySQL preserve history; and Apache Tomcat runs the application. The adaptive behaviour comes from transparent threshold rules and an ordered path. It does not use machine learning or an external AI service. The local seeded MVP has eight topics and 200 questions. Forty-four rule checks, a transaction integration test and a live browser walkthrough were completed.

**Keywords:** adaptive learning, rule engine, JSP, Servlets, JDBC, MySQL, Web Technologies.

## Contents

1. Introduction and problem definition
2. Objectives, scope and success criteria
3. Starting point and development record
4. Requirements and use cases
5. Technology and architecture
6. Data design and learning rules
7. Module implementation
8. Verification and results
9. Demonstration plan
10. Limitations and future work
11. Conclusion
12. References and appendices

## 1. Introduction and problem definition

A fixed learning path sends all students through the same sequence regardless of whether they need revision or are ready for harder material. This project asks whether a conventional web application can recommend a useful next step after each assessment and enforce that path consistently. Introductory Python provides a clear course domain for a classroom demonstration.

The MVP solves three connected problems. It records assessments rather than relying on temporary browser scores. It explains the next action in language a learner can follow. It also checks topic access on the server, so a student cannot open a locked advanced topic by changing a URL. Dashboard, modules and progress screens use the same stored results.

“Personalised” here means a path that changes according to each student's own history. The rules are deterministic and explainable: students with the same results receive the same path state.

## 2. Objectives, scope and success criteria

The primary objective is a presentable student and teacher workflow. A student must be able to register or sign in, see modules, study a topic, take a quiz, receive advice and inspect historical progress. A teacher must be able to sign in, manage topics and questions, and inspect activity. Retakes must preserve history while the best results drive access to new topics.

The scope is one Python course, not a general learning management system. The seed course has four basic topics (Variables, Conditions, Loops and Functions) and four advanced topics (OOP, Files, Exception Handling and Modules). Each topic has ten practice, ten quiz and five Golden questions. Across eight topics that is 80 practice, 80 quiz and 40 Golden questions: 200 total. Practice is self-checking and unscored.

| Success criterion | MVP evidence |
|---|---|
| Student receives a next step after an assessment | Live assessment submission and recommendation page |
| Topic access follows the published rules | 44 rule checks and live path inspection |
| Retakes preserve history | Append-only attempts; student and teacher history screens |
| Attempt and advice stay paired | Transaction integration test for commit and rollback |
| Teacher can maintain content and inspect activity | Temporary topic/question create, edit and delete through authenticated HTTP; activity pages render |
| Local presentation can run | Tomcat served the app and both demo roles signed in |

## 3. Starting point and development record

At the start of the completion pass, the workspace already contained Java source, JSP screens, styles and scripts, SQL schema and seed data, a build script, and 37 passing rule tests. The local database held the eight-topic course and demo accounts. There is no Git metadata in this workspace, so an earlier commit-by-commit history cannot be reconstructed. This starting point is the state directly observed during the pass.

The review found gaps that mattered for a reliable demonstration. Quiz and Golden endpoints could be mixed, repeated POSTs could duplicate results, and attempt and recommendation rows could be written separately. Some high-score advice implied a basic next topic was still locked. The student dashboard could show an old optional Golden recommendation as the main action while a later topic needed revision. The home page also understated the question count.

| Area | Work completed | Effect |
|---|---|---|
| Login session | Replaced the old session after successful sign-in | Role switching begins with a clean session |
| Assessment routing | Matched each POST to the active topic and assessment type | Wrong endpoint cannot score the assessment |
| Duplicate handling | Serialized submission on the session and consumed active assessment | Repeat POST does not create duplicate rows |
| Question availability | Required all ten quiz or five Golden questions | Published score thresholds remain meaningful |
| Persistence | Wrote attempt and advice in one JDBC transaction | Both commit or both roll back |
| Advice | Corrected high-score wording for an already-open basic topic | Message agrees with unlock logic |
| Dashboard | Derived primary next step from current path state | Rahul is directed to OOP revision |
| Home page | Corrected total to 200 questions | Display matches seed data |
| Access and lifecycle | Added no-store private responses and MySQL shutdown cleanup | Reduced stale-page and reload issues |
| Database and tests | Expanded recommendation text and added checks | Longer advice persists; 44 checks pass |
| Public source preparation | Moved database settings to environment variables and excluded generated binaries | GitHub checkout contains source, documentation and a safe configuration example |

This document replaces the earlier short engineering account and is the academic report for presentation and submission.

## 4. Requirements and use cases

### 4.1 Functional requirements

The student interface supports registration, role-specific login, a dashboard, an ordered module path, notes, two levels of practice, scored quizzes, Golden Assessments, recommendations and attempt history. A student can mark advice as completed, but that personal status is separate from computed unlock state. The teacher interface shows course and activity totals, lets a teacher add or edit topics and questions, and lists all attempts and recommendations. Topics with student attempts cannot be deleted through the teacher page.

### 4.2 Non-functional requirements

The MVP runs locally in a browser with responsive layout. Server-side scoring is authoritative: correct answers remain in server-side assessment state and posted forms supply selected options. Data access uses prepared statements. A Servlet filter restricts student and teacher routes by role; authenticated responses carry no-store cache headers. The request flow remains understandable without an application framework.

### 4.3 Actors and use cases

| Actor | Entry point | Main actions | End state |
|---|---|---|---|
| Visitor | Landing page | Register or sign in | Student or teacher session |
| Student | Dashboard | Study, practise, assess, read advice, inspect progress | New attempt/advice and recalculated path |
| Teacher | Teacher dashboard | Maintain content and inspect activity | Updated course or observed learning history |

A typical student sequence is to sign in, open the current topic, read notes, practise, take the ten-question quiz, view the score and advice, then revise, continue to an open basic topic or attempt Golden. Golden is available only after a best quiz score above 80% on that topic.

## 5. Technology and architecture

Ordinary web technologies provide the complete system. HTML structures pages. CSS and Bootstrap supply layout and responsive components. JavaScript supports small browser interactions and validation. JSP renders server-prepared information. Servlets receive requests, manage sessions, validate forms and redirect after writes. JavaBeans and model objects hold data. A plain Java rule engine evaluates thresholds. DAOs use JDBC prepared statements with MySQL. Tomcat runs the Servlet/JSP application.

| Layer | Main files | Responsibility |
|---|---|---|
| Presentation | `web/*.jsp`, `web/css`, `web/js` | Show forms, learning path, scores and history |
| Controllers | `src/controller` | Receive requests, authorize and coordinate work |
| Business data | `src/beans`, `src/model` | Hold scores, topic state and page-ready values |
| Decisions | `src/engine/RecommendationEngine.java` | Select advice and topic access |
| Persistence | `src/dao`, `src/util/DBConnection.java` | SQL, transactions and connections |
| Runtime | MySQL, Apache Tomcat | Store records and serve the application |

**Request path:** Browser → Servlet and AuthFilter → JavaBeans/rule engine → DAO/JDBC → MySQL → JSP response. The browser does not decide scores or unlocks. Pages rebuild each student's path from ordered topics and recorded best quiz and Golden results. That simple server process produces personalised behaviour without training or calling a prediction model.

The project uses the `jakarta.servlet` API and targets Tomcat 10.1 or 11 with JDK 17 or newer. MySQL Connector/J belongs in `web/WEB-INF/lib`. The build script compiles 38 Java sources and can deploy the web directory.

## 6. Data design and learning rules

### 6.1 Entity design

Six tables support the MVP. `students` and `teachers` hold separate account roles. `topics` stores ordered modules and notes. `questions` belongs to a topic and has PRACTICE, QUIZ or GOLDEN type. `attempts` records each scored assessment. `recommendations` records the advice generated for each attempt. Foreign keys connect activity to students and topics.

| Table | Key fields | Purpose |
|---|---|---|
| students | student_id, name, email, password | Student accounts and linked history |
| teachers | teacher_id, name, email, password | Teacher access |
| topics | topic_id, title, difficulty, topic_order, notes | Ordered course |
| questions | question_id, topic_id, question_type, correct_answer | Question bank |
| attempts | attempt_id, student_id, topic_id, type, score | Append-only scored history |
| recommendations | recommendation_id, student_id, topic_id, type, text, status | Advice history |

`database/01_schema.sql` defines the schema. `02_seed_data.sql` and `03_advanced_practice.sql` provide course content. `04_recommendation_text.sql` expands the advice field for an existing database without resetting it. The initial schema script drops and recreates the database and is for a fresh setup only.

### 6.2 Scoring and decisions

Percentage equals correct answers divided by total questions, multiplied by 100. A quiz has ten questions; a Golden Assessment has five. The boundaries are deliberate: 50% passes a quiz, 80% remains in the middle band, 81% opens Golden, and three correct Golden answers give 60% and pass.

| Assessment result | Rule | Advice and access |
|---|---|---|
| Quiz 0–49% | Below 50 | Revise, practise and retake; next topic stays locked |
| Quiz 50–80% | 50 through 80 | Next basic topic opens; advanced still needs Golden |
| Quiz 81–100% | Above 80 | Golden opens; next basic topic is already open |
| Golden 0–59% | Below 60 | Advanced practice and retry |
| Golden 60–100% | 60 or more | Next advanced topic may unlock |

The first topic is always open. A later basic topic needs at least 50% on its immediate predecessor's best quiz. A later advanced topic requires a passing quiz and passed Golden on its predecessor. These plain `if/else` rules live in `RecommendationEngine.java`. The UI shows locked, not started, needs revision, completed or mastered states.

### 6.3 Submission consistency

At assessment start, the server stores the question set in the session. A POST is accepted only for the matching assessment and topic. After submission, the active assessment is consumed, preventing a repeated POST from recording another attempt. The DAO inserts the attempt and advice in one SQL transaction; a failure rolls both back. Retakes append new rows. Best scores drive unlocks, while the full attempt sequence stays available.

## 7. Module implementation

**Authentication and roles.** Registration creates student accounts. Teachers use seeded accounts. Successful login creates a fresh session and a filter separates student and teacher routes. Passwords currently use a SHA-256 digest; stronger storage is identified under limitations.

**Student path.** The dashboard reports completion, average best score, quizzes, Golden passes and the current actionable topic. Modules shows the ordered path and advanced gate. Topic pages combine teacher-authored notes, unscored practice and quiz or Golden actions. Failed Golden attempts lead to advanced practice.

**Assessment and feedback.** Ten-question quizzes and five-question Golden Assessments use separate scoring paths. The result page shows percentage, rule headline, explanation and an action link. Recommendation history remains available later and its owner can mark an item done. That status does not control access; stored results do.

**Teacher workspace.** The teacher dashboard gives course and activity totals. Forms maintain topics and questions. Attempt history includes retakes. Recommendation history shows which rule fired, advice, status and time, making the system auditable during a presentation.

## 8. Verification and results

Verification used local MySQL and an isolated Tomcat 11.0.25 instance on 29 September 2026. The rule suite compiled all 38 Java sources and passed 44 checks. The database integration test exercised a valid attempt-plus-advice commit and a forced recommendation failure that rolled both writes back. The expected foreign-key message in the negative case belongs to the rollback test. Live browser inspection covered landing/login, student dashboard/path/topic, teacher dashboard/content pages and both teacher activity histories. Authenticated HTTP form submissions created, edited and deleted a temporary topic and question; direct database checks confirmed each change and that the seeded content was restored afterward.

| Test | Expected outcome | Observed result |
|---|---|---|
| `./build.sh test` | Thresholds, unlocks and next action hold | 44 passed, 0 failed |
| `./build.sh integration-test` | Commit or roll back attempt and advice together | Passed |
| Visitor opens student dashboard | Authentication required | Redirected to login |
| Student login | Saved dashboard/path load | Passed |
| Old optional Golden result after later low quiz | Current low topic is primary action | Dashboard shows OOP revision |
| Quiz/Golden endpoint mismatch | Reject without recording | Passed live check |
| Repeated quiz POST | No duplicate rows | Passed live check |
| Perfect quiz | Golden available | Passed live check |
| Golden score 3/5 | 60% pass | Passed live check |
| Teacher login | Dashboard and content/activity pages load | Passed browser walkthrough |
| Teacher content maintenance | Add, update and delete temporary topic and question | Passed authenticated HTTP and database checks; temporary rows removed |
| Teacher session requests student route | Role boundary enforced | Redirected away |

The seeded Rahul account showed 11 recorded attempts, four completed quiz topics out of eight, five unlocked topics and OOP at 20% as the immediate revision action. Teacher screens showed the eight topics and seeded question bank. These demo counts change as content is edited or new assessments are submitted.

This verification supports the MVP workflow. It is not a load test, public-hosting readiness test or exhaustive accessibility audit. Teacher forms were visually inspected, and their create, update and delete actions were exercised through authenticated HTTP submissions rather than a complete mouse-driven UI cycle.

## 9. Demonstration plan

1. Open the landing page and explain the four score rules and the eight modules.
2. Log in as `rahul@student.edu` with the demo fill button. Show OOP as the current revision task and the separate latest Conditions result.
3. Open Modules to explain basic/advanced access and Golden. Open OOP to show notes, practice, quiz action and progress.
4. Open Progress and Recommendations to show saved history.
5. Log out and log in as `anita.rao@college.edu`. Show teacher totals, topic and question bank pages, attempts and recommendations.
6. Explain the request path: forms reach Servlets, Java rules decide, JDBC saves to MySQL, and JSP presents the result.
7. State clearly that the MVP is adaptive and rule-based. No machine learning model is trained or called.

For a clean first-time path, use `sneha@student.edu` or register a new student. Demo passwords are in `README.md`. A live quiz changes account data, so use a throwaway registered account for a repeatable recorded demonstration.

## 10. Limitations and future work

The app meets its local classroom MVP scope. Its passwords use SHA-256 rather than a slow salted scheme. Teacher-authored notes render as HTML, and authenticated POST forms do not yet have CSRF tokens. Those points need attention before deploying the application as a public service. Database connection settings are read from environment variables rather than committed credentials. The interface is English-only; the course is a single seeded Python path; recommendation thresholds are fixed rather than teacher-configurable.

Future work could add secure account provisioning and configuration, CSRF protection, restricted teacher content, automated Servlet-level tests, accessibility review, teacher-adjustable thresholds, more courses and learning analytics. An ML recommender would be a separate research extension needing data and validation; it is not part of this MVP.

## 11. Conclusion

The completed MVP demonstrates that familiar Web Technologies can create a personalised learning path. Server-side scores, a small explainable rule engine and relational history provide meaningful next-step guidance and enforce the advanced-topic gate. Student and teacher journeys run locally, 44 rule checks pass, and the transaction test confirms that each attempt stays paired with its advice. The system is ready for classroom presentation, with public-deployment work identified separately.

## 12. References and appendices

**Direct project sources:** `README.md`; `database/SCHEMA_DESIGN.md` and `01_schema.sql`; `src/engine/RecommendationEngine.java` and `RuleConstants.java`; `src/controller`; `test/RuleEngineTest.java` and `AssessmentPersistenceTest.java`. These are the sources for the implementation claims in this report.

**Technology references:** Jakarta Servlet specification and API documentation; Apache Tomcat documentation; MySQL Reference Manual; Oracle JDBC documentation; Bootstrap 5 documentation. Version-specific deployment details should be checked against locally installed versions.

### Appendix A. Local setup

The repository `README.md` gives the complete setup and demo account instructions. It covers JDK, MySQL, Tomcat, Connector/J, environment variables, build and verification commands. For a fresh database, run schema, seed and advanced-practice scripts in order. The schema script recreates the database; use the migration script for existing data.
