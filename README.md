# Adaptive Personalised Learning Path Recommender

A rule-based Python learning course built for a Web Technologies PBL presentation. Students study eight topics, take quizzes, receive explainable next-step advice, and unlock advanced topics through Golden Assessments. Teachers manage the course and inspect attempts and recommendations.

**Live showcase:** [adaptive-learning-path-showcase.vercel.app](https://adaptive-learning-path-showcase.vercel.app). Start with the project presentation and rule simulator, then open the separate [MVP product demo](https://adaptive-learning-path-showcase.vercel.app/product/). In the MVP, click **Play guided demo** for a walkthrough under one minute showing quiz revision (40%), a passing score (70%), Golden eligibility (90%), a Golden retry (40%), an advanced unlock (60%), and the teacher's recommendations and attempt history. You can also explore the student and teacher flows yourself.

**This repository contains the complete source code and project report.** The Vercel experiences live in [`showcase/`](showcase/). The product demo uses real seeded questions but runs entirely in the visitor's browser. Its role selector is for demonstration, and its attempts and teacher edits stay on that device. The complete Java/JSP/MySQL MVP still runs locally with Tomcat.

**Project team:** M Shreevenkat Sathvik (25WU0101168), N Siddharth (25WU0102263), and S Dhanush (25WU0101139). Second-year B.Tech CSE, Section Panthers, School of Technology, Woxsen University. Guided by Prof. Veeresh Biradar.

**Report:** [View PDF](docs/PROJECT_REPORT.pdf) · [Download Word document](docs/PROJECT_REPORT.docx)

## What the MVP does

- Separate student and teacher sign-in, with student registration.
- Ordered learning path with notes, unscored practice, ten-question quizzes and five-question Golden Assessments.
- Server-side scoring, persistent retake history and recommendations based on each student's results.
- Teacher pages to manage topics and questions and view all activity.
- Eight seeded Python topics and 200 questions for a ready-to-run demonstration.

| Result | Decision |
|---|---|
| Quiz below 50% | Revise and retake |
| Quiz 50–80% | Move to the next basic topic |
| Quiz above 80% | Golden Assessment becomes available |
| Golden below 60% | Use advanced practice and retry |
| Golden 60% or more | Unlock the next advanced topic when eligible |

The first topic is open to everyone. Later basic topics require at least 50% on the previous topic's best quiz. Advanced topics also require a passed Golden Assessment on the previous topic. These are plain Java rules, **not machine learning**.

## Run locally

### Requirements

- JDK 17 or newer
- MySQL 8
- Apache Tomcat 10.1 or 11 (the code uses `jakarta.servlet`)
- MySQL Connector/J 8.x

### First-time setup

1. Clone this repository and enter the directory:

   ```bash
   git clone https://github.com/sathvikmallepalli-lgtm/adaptive-learning-path-recommender.git
   cd adaptive-learning-path-recommender
   ```

2. Configure local database credentials. `.env.local` is ignored by Git:

   ```bash
   cp .env.example .env.local
   # Edit .env.local with your local MySQL password.
   source .env.local
   ```

   The app reads `ADAPTIVE_DB_PASSWORD` at runtime. `ADAPTIVE_DB_USER` defaults to `root`, and `ADAPTIVE_DB_URL` defaults to the local `adaptive_learning` database. Start Tomcat from the **same shell** after sourcing the file so it inherits these values.

3. Create the demonstration database, in order:

   ```bash
   mysql -u root -p < database/01_schema.sql
   mysql -u root -p < database/02_seed_data.sql
   mysql -u root -p < database/03_advanced_practice.sql
   ```

   **Important:** `01_schema.sql` drops and recreates `adaptive_learning`. Run it only for a fresh setup. For an existing database from an earlier copy of this project, keep its data and run `database/04_recommendation_text.sql` once instead.

4. Put a compatible `mysql-connector-j-8.x.jar` in `web/WEB-INF/lib/`. The JAR is not committed to Git.

5. Build, deploy and run Tomcat. Set `TOMCAT` to your installation's `libexec` or main Tomcat directory:

   ```bash
   export TOMCAT=/path/to/tomcat
   ./build.sh test
   ./build.sh integration-test
   ./build.sh deploy
   "$TOMCAT/bin/catalina.sh" run
   ```

   Open [http://localhost:8080/AdaptiveLearning/](http://localhost:8080/AdaptiveLearning/). If Tomcat already runs as a background service, configure the three `ADAPTIVE_DB_*` variables for that service and restart it; variables sourced in another shell will not reach it.

### Demo accounts

These credentials are **only for a local seeded demonstration**. Change them before any shared deployment.

| Role | Email | Password |
|---|---|---|
| Student | `rahul@student.edu` | `student123` |
| Student | `sneha@student.edu` | `student123` |
| Teacher | `anita.rao@college.edu` | `teacher123` |
| Teacher | `vikram.nair@college.edu` | `teacher123` |

The login page has fill buttons for Rahul and Anita. Rahul's account demonstrates existing results and a revision recommendation; Sneha's account is useful for the first-time student path.

## Project layout

| Path | Purpose |
|---|---|
| `src/controller/` | Servlets, role filter and lifecycle listener |
| `src/engine/` | Recommendation and unlock rules |
| `src/beans/`, `src/model/` | Page-ready state and data objects |
| `src/dao/`, `src/util/` | JDBC persistence, configuration and validation |
| `web/` | JSP, CSS, JavaScript and deployment descriptor |
| `database/` | Schema, seed scripts and data design |
| `test/` | Rule and database transaction tests |
| `docs/` | [Project report PDF](docs/PROJECT_REPORT.pdf), [Word version](docs/PROJECT_REPORT.docx), [Markdown source](docs/PROJECT_REPORT.md) and report figures |
| `showcase/` | Vercel presentation and separate browser product demo, with exported seeded course data |

The request flow is browser → Servlet/filter → JavaBeans and rule engine → DAO/JDBC → MySQL → JSP response. Scoring and unlock decisions happen on the server.

## Verification

`./build.sh test` compiles 38 Java files and runs 44 rule checks. `./build.sh integration-test` verifies that an assessment and its recommendation commit together and roll back together when one insert fails. The MVP was also walked through in a browser for both roles. The detailed test evidence, starting point, completed changes, design and presentation sequence are in the [report](docs/PROJECT_REPORT.md).

## Scope and security

This is a **classroom MVP**. It is suitable for local demonstration and source review. It is not configured as a public production service. Password storage currently uses SHA-256 rather than a slow salted password hash; teacher-authored HTML notes are not sanitised; and POST forms do not have CSRF tokens. Database credentials are read from environment variables and are not committed. See the report for the improvement plan.

Bootstrap 5.3.3 is included locally; see [third-party notices](THIRD_PARTY_NOTICES.md). MySQL Connector/J must be installed separately.
