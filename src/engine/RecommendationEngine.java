package engine;

import java.util.ArrayList;
import java.util.List;

import beans.ProgressBean;
import beans.TopicBean;
import dao.AttemptDAO;
import dao.TopicDAO;
import model.Attempt;
import model.RuleResult;
import model.TopicProgress;

/**
 * THE RULE ENGINE.
 *
 * This class is the whole "adaptive" part of the project and it is 100%
 * rule based - only if and else. There is no machine learning, no scoring
 * model and no randomness anywhere in this file.
 *
 * ------------------------------------------------------------------
 *  RULES AFTER A NORMAL QUIZ
 * ------------------------------------------------------------------
 *    score below 50      -> REVISION  (revise, practise, retake the quiz)
 *    score 50 to 80      -> NEXT_TOPIC
 *    score above 80      -> GOLDEN_ASSESSMENT
 *
 * ------------------------------------------------------------------
 *  RULES AFTER A GOLDEN ASSESSMENT
 * ------------------------------------------------------------------
 *    score 60 or more    -> UNLOCK_ADVANCED   (advanced topic opens)
 *    score below 60      -> ADVANCED_PRACTICE
 *
 * ------------------------------------------------------------------
 *  UNLOCK RULE
 * ------------------------------------------------------------------
 *    the first topic         -> always open
 *    a BASIC topic           -> open when the previous topic quiz best is 50+
 *    an ADVANCED topic       -> open when the previous topic quiz best is 50+
 *                               AND the Golden Assessment of that previous
 *                               topic was passed
 *
 * The last rule is what gives the Golden Assessment its purpose: scoring
 * well is not enough on its own to reach the advanced half of the course.
 */
public class RecommendationEngine {

    private final TopicDAO topicDAO = new TopicDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();

    // =================================================================
    //  1. RULES APPLIED AFTER A NORMAL QUIZ
    // =================================================================

    /**
     * Decides what a student should do next after finishing a topic quiz.
     *
     * @param score     the percentage just scored
     * @param topic     the topic that was just attempted
     * @param nextTopic the topic that follows it, or null at the end of the course
     */
    public RuleResult evaluateQuiz(int score, TopicBean topic, TopicBean nextTopic) {
        RuleResult result;

        if (score < RuleConstants.LOW_SCORE) {
            // ---------- RULE 1 : below 50 ----------
            result = new RuleResult(
                RuleResult.REVISION,
                "Revise this topic",
                "You scored " + score + "% in " + topic.getTitle() + ". "
              + "Read the notes again, work through the practice questions, "
              + "then retake the quiz. You need " + RuleConstants.LOW_SCORE
              + "% to move on.");

        } else if (score <= RuleConstants.HIGH_SCORE) {
            // ---------- RULE 2 : 50 to 80 ----------
            if (nextTopic == null) {
                result = new RuleResult(
                    RuleResult.NEXT_TOPIC,
                    "Course complete",
                    "You scored " + score + "% in " + topic.getTitle()
                  + " and this was the last topic. Well done.");
            } else if (nextTopic.isAdvanced()) {
                // The next topic is advanced, so the Golden gate applies.
                result = new RuleResult(
                    RuleResult.NEXT_TOPIC,
                    "Good work - one more step needed",
                    "You scored " + score + "% in " + topic.getTitle() + ". "
                  + nextTopic.getTitle() + " is an advanced topic, so it opens only "
                  + "after you score above " + RuleConstants.HIGH_SCORE + "% here and "
                  + "pass the Golden Assessment. Retake the quiz to try for that.");
            } else {
                result = new RuleResult(
                    RuleResult.NEXT_TOPIC,
                    "Move on to the next topic",
                    "You scored " + score + "% in " + topic.getTitle() + ". "
                  + "That is a good pass - continue with " + nextTopic.getTitle() + ".");
                result.setNextTopicUnlocked(true);
            }

        } else {
            // ---------- RULE 3 : above 80 ----------
            // A basic next topic is already open from the quiz pass. The
            // Golden gate is only required when the next topic is advanced.
            String guidance;
            if (nextTopic == null) {
                guidance = "This was the last topic. The Golden Assessment is available as an extra challenge.";
            } else if (nextTopic.isAdvanced()) {
                guidance = "Pass the Golden Assessment before " + nextTopic.getTitle()
                         + " opens.";
            } else {
                guidance = nextTopic.getTitle()
                         + " is already open. You can continue or take the Golden Assessment as an extra challenge.";
            }
            result = new RuleResult(
                RuleResult.GOLDEN_ASSESSMENT,
                "Golden Assessment unlocked",
                "Excellent - " + score + "% in " + topic.getTitle() + ". "
              + guidance + " It has " + RuleConstants.GOLDEN_QUESTION_COUNT + " challenging questions. "
              + "Score " + RuleConstants.GOLDEN_PASS_SCORE + "% or more to pass.");
            result.setGoldenUnlocked(true);
            result.setNextTopicUnlocked(nextTopic != null && !nextTopic.isAdvanced());
        }

        attachNextTopic(result, nextTopic);
        return result;
    }

    // =================================================================
    //  2. RULES APPLIED AFTER A GOLDEN ASSESSMENT
    // =================================================================

    /**
     * Decides what happens after the five Golden Assessment questions.
     *
     * @param score     percentage scored in the Golden Assessment
     * @param topic     the topic the assessment belonged to
     * @param nextTopic the topic it unlocks, or null at the end of the course
     */
    public RuleResult evaluateGolden(int score, TopicBean topic, TopicBean nextTopic) {
        RuleResult result;

        if (score >= RuleConstants.GOLDEN_PASS_SCORE) {
            // ---------- GOLDEN PASSED ----------
            String unlocked = nextTopic == null
                            ? "You have finished the whole course."
                            : nextTopic.isAdvanced()
                              ? nextTopic.getTitle() + " is now unlocked."
                              : nextTopic.getTitle() + " was already open after your quiz pass.";
            result = new RuleResult(
                RuleResult.UNLOCK_ADVANCED,
                "Golden Assessment passed",
                "You scored " + score + "% in the " + topic.getTitle()
              + " Golden Assessment. " + unlocked);
            result.setNextTopicUnlocked(true);

        } else {
            // ---------- GOLDEN FAILED ----------
            result = new RuleResult(
                RuleResult.ADVANCED_PRACTICE,
                "Advanced practice recommended",
                "You scored " + score + "% in the " + topic.getTitle()
              + " Golden Assessment and " + RuleConstants.GOLDEN_PASS_SCORE
              + "% was needed. Work through the advanced practice questions for "
              + topic.getTitle() + ", then attempt the Golden Assessment again.");
            result.setGoldenUnlocked(true);   // they may try again
        }

        attachNextTopic(result, nextTopic);
        return result;
    }

    // =================================================================
    //  3. THE UNLOCK RULE
    // =================================================================

    /**
     * Is this topic open for this student?
     *
     * Pure if/else with no database access, so the rule is easy to read and
     * easy to test on its own.
     *
     * @param topic                the topic being checked
     * @param isFirstTopic         true when it is first in the learning path
     * @param previousBestQuiz     best quiz percentage on the previous topic
     * @param previousGoldenPassed whether the previous topic Golden was passed
     */
    public boolean isUnlocked(TopicBean topic, boolean isFirstTopic,
                              int previousBestQuiz, boolean previousGoldenPassed) {
        if (isFirstTopic) {
            return true;
        }
        if (previousBestQuiz < RuleConstants.LOW_SCORE) {
            return false;
        }
        if (topic.isAdvanced()) {
            return previousGoldenPassed;
        }
        return true;
    }

    /**
     * May this student start the Golden Assessment for this topic?
     * Only after scoring above 80% in the normal quiz for that topic.
     */
    public boolean isGoldenAvailable(int studentId, int topicId) {
        int best = attemptDAO.findBestScore(studentId, topicId, Attempt.TYPE_QUIZ);
        return best > RuleConstants.HIGH_SCORE;
    }

    public boolean hasPassedGolden(int studentId, int topicId) {
        int best = attemptDAO.findBestScore(studentId, topicId, Attempt.TYPE_GOLDEN);
        return best >= RuleConstants.GOLDEN_PASS_SCORE;
    }

    // =================================================================
    //  4. BUILDING THE WHOLE LEARNING PATH
    // =================================================================

    /**
     * Works out the state of every topic for one student.
     *
     * This is what modules.jsp and progress.jsp display. Because it is
     * calculated here every time, the database needs no progress table.
     */
    public ProgressBean buildProgress(int studentId) {
        ProgressBean progress = new ProgressBean();
        progress.setStudentId(studentId);

        List<TopicBean> topics = topicDAO.findAll();
        List<TopicProgress> path = new ArrayList<TopicProgress>();

        // Carried from one loop pass to the next - the rule only ever looks
        // at the topic immediately before the current one.
        int previousBestQuiz = 0;
        boolean previousGoldenPassed = false;
        boolean first = true;

        for (TopicBean topic : topics) {
            TopicProgress tp = new TopicProgress();
            tp.setTopicId(topic.getTopicId());
            tp.setTitle(topic.getTitle());
            tp.setDifficulty(topic.getDifficulty());
            tp.setTopicOrder(topic.getTopicOrder());

            int bestQuiz = attemptDAO.findBestScore(studentId, topic.getTopicId(), Attempt.TYPE_QUIZ);
            int quizCount = attemptDAO.countAttempts(studentId, topic.getTopicId(), Attempt.TYPE_QUIZ);
            int goldenCount = attemptDAO.countAttempts(studentId, topic.getTopicId(), Attempt.TYPE_GOLDEN);
            int bestGolden = attemptDAO.findBestScore(studentId, topic.getTopicId(), Attempt.TYPE_GOLDEN);

            tp.setBestQuizScore(bestQuiz);
            tp.setQuizAttempts(quizCount);
            tp.setGoldenAttempted(goldenCount > 0);
            tp.setGoldenPassed(bestGolden >= RuleConstants.GOLDEN_PASS_SCORE);

            tp.setUnlocked(isUnlocked(topic, first, previousBestQuiz, previousGoldenPassed));
            tp.setStatus(decideStatus(tp));

            path.add(tp);

            previousBestQuiz = bestQuiz;
            previousGoldenPassed = tp.isGoldenPassed();
            first = false;
        }

        progress.setTopics(path);
        return progress;
    }

    /** The label shown on the module card. Pure if/else. */
    private String decideStatus(TopicProgress tp) {
        if (!tp.isUnlocked()) {
            return TopicProgress.STATUS_LOCKED;
        }
        if (tp.getQuizAttempts() == 0) {
            return TopicProgress.STATUS_NOT_STARTED;
        }
        if (tp.getBestQuizScore() < RuleConstants.LOW_SCORE) {
            return TopicProgress.STATUS_NEEDS_REVISION;
        }
        if (tp.isGoldenPassed()) {
            return TopicProgress.STATUS_MASTERED;
        }
        return TopicProgress.STATUS_COMPLETED;
    }

    /** Copies the next topic details onto the result for the action button. */
    private void attachNextTopic(RuleResult result, TopicBean nextTopic) {
        if (nextTopic != null) {
            result.setNextTopicId(nextTopic.getTopicId());
            result.setNextTopicTitle(nextTopic.getTitle());
        }
    }
}
