# Vercel showcase

This folder is a static, interactive presentation of the full Java/JSP project. It mirrors the thresholds in `src/engine/RuleConstants.java` and the recommendation and unlock decisions in `src/engine/RecommendationEngine.java`. Simulated progress is stored in browser `localStorage` and can be reset.

The full MVP lives in the repository root and runs on Tomcat with MySQL. This showcase has no accounts, actual question bank, server-side scoring, teacher tools, or shared database. Its purpose is to let an external reviewer explore the learning path and decision rules immediately, without installing the Java stack.

Deploy this folder as the Vercel project root (`showcase/`). No build command or environment variables are required.
