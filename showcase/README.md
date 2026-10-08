# Vercel showcase

This folder contains two separate Vercel experiences:

1. `/` is the opening showcase with an interactive score simulator. It mirrors the thresholds in `src/engine/RuleConstants.java` and the decisions in `src/engine/RecommendationEngine.java`.
2. `/product/` is an interactive browser version of the MVP product flow. Reviewers can enter as a student or teacher, read the actual seeded notes, practise with the actual questions, submit ten-question quizzes and five-question Golden Assessments, see recommendations and progress, and manage topics and questions. The **Play guided demo** button runs a one-click walkthrough: it answers the actual Functions quiz and Golden Assessment, shows the resulting recommendation and OOP unlock, then opens the teacher's attempt history. Pause, skip ahead, replay, or exit at any point. Exiting restores the visitor's previous browser progress.

`build_data.py` exports eight topics and 200 questions from `database/02_seed_data.sql` and `database/03_advanced_practice.sql` into `product/data.json`. Run it after changing either SQL seed file.

The full Java/JSP MVP lives in the repository root and runs on Tomcat with MySQL. The Vercel product demo is a browser implementation of its presentation flows and rules: role selection uses demo personas, scoring and teacher edits run in JavaScript, and attempts, recommendations and course edits stay in that visitor's `localStorage`. It has no real authentication, shared database or server-side scoring. The banner and entry screen disclose this clearly.

Deploy this folder as the Vercel project root (`showcase/`). No build command or environment variables are required.
