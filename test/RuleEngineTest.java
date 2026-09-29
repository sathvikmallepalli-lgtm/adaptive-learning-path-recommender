import beans.TopicBean;
import beans.ProgressBean;
import engine.RecommendationEngine;
import engine.RuleConstants;
import model.RuleResult;
import model.TopicProgress;
import java.util.Arrays;

/**
 * Tests for the rule engine - Step 13.
 *
 * The three rule methods take plain values and return a plain result, so
 * they can be tested without MySQL and without Tomcat. That is the whole
 * reason the rules were kept free of database calls.
 *
 * Run it with:
 *   javac -d build/test -cp web/WEB-INF/classes test/RuleEngineTest.java
 *   java  -cp build/test:web/WEB-INF/classes RuleEngineTest
 */
public class RuleEngineTest {

    private static int passed = 0;
    private static int failed = 0;

    public static void main(String[] args) {
        System.out.println("Rule engine tests");
        System.out.println("=================================================");

        testQuizRules();
        testGoldenRules();
        testUnlockRules();
        testBoundaries();
        testCurrentTopic();

        System.out.println("=================================================");
        System.out.println("passed: " + passed + "   failed: " + failed);
        if (failed > 0) {
            System.exit(1);
        }
    }

    // -----------------------------------------------------------------
    //  RULE 1, 2, 3 : what happens after a normal quiz
    // -----------------------------------------------------------------
    private static void testQuizRules() {
        section("Quiz rules");
        RecommendationEngine engine = new RecommendationEngine();
        TopicBean loops = topic(3, "Loops", TopicBean.BASIC);
        TopicBean functions = topic(4, "Functions", TopicBean.BASIC);

        check("0% gives REVISION",
              RuleResult.REVISION, engine.evaluateQuiz(0, loops, functions).getType());
        check("30% gives REVISION",
              RuleResult.REVISION, engine.evaluateQuiz(30, loops, functions).getType());
        check("49% gives REVISION",
              RuleResult.REVISION, engine.evaluateQuiz(49, loops, functions).getType());

        check("50% gives NEXT_TOPIC",
              RuleResult.NEXT_TOPIC, engine.evaluateQuiz(50, loops, functions).getType());
        check("70% gives NEXT_TOPIC",
              RuleResult.NEXT_TOPIC, engine.evaluateQuiz(70, loops, functions).getType());
        check("80% gives NEXT_TOPIC (80 is not above 80)",
              RuleResult.NEXT_TOPIC, engine.evaluateQuiz(80, loops, functions).getType());

        check("81% gives GOLDEN_ASSESSMENT",
              RuleResult.GOLDEN_ASSESSMENT, engine.evaluateQuiz(81, loops, functions).getType());
        check("90% gives GOLDEN_ASSESSMENT",
              RuleResult.GOLDEN_ASSESSMENT, engine.evaluateQuiz(90, loops, functions).getType());
        check("100% gives GOLDEN_ASSESSMENT",
              RuleResult.GOLDEN_ASSESSMENT, engine.evaluateQuiz(100, loops, functions).getType());

        checkTrue("above 80% sets the golden flag",
                  engine.evaluateQuiz(95, loops, functions).isGoldenUnlocked());
        checkTrue("above 80% still opens a BASIC next topic",
                  engine.evaluateQuiz(90, loops, functions).isNextTopicUnlocked());
        checkFalse("above 80% does not directly open an ADVANCED next topic",
                   engine.evaluateQuiz(90, loops, topic(5, "OOP", TopicBean.ADVANCED))
                         .isNextTopicUnlocked());
        checkTrue("a 60% pass on a BASIC next topic unlocks it",
                  engine.evaluateQuiz(60, loops, functions).isNextTopicUnlocked());
    }

    // -----------------------------------------------------------------
    //  GOLDEN ASSESSMENT : pass and fail
    // -----------------------------------------------------------------
    private static void testGoldenRules() {
        section("Golden Assessment rules");
        RecommendationEngine engine = new RecommendationEngine();
        TopicBean functions = topic(4, "Functions", TopicBean.BASIC);
        TopicBean oop = topic(5, "OOP", TopicBean.ADVANCED);

        check("0 of 5 fails",
              RuleResult.ADVANCED_PRACTICE, engine.evaluateGolden(0, functions, oop).getType());
        check("2 of 5 (40%) fails",
              RuleResult.ADVANCED_PRACTICE, engine.evaluateGolden(40, functions, oop).getType());
        check("3 of 5 (60%) passes",
              RuleResult.UNLOCK_ADVANCED, engine.evaluateGolden(60, functions, oop).getType());
        check("4 of 5 (80%) passes",
              RuleResult.UNLOCK_ADVANCED, engine.evaluateGolden(80, functions, oop).getType());
        check("5 of 5 (100%) passes",
              RuleResult.UNLOCK_ADVANCED, engine.evaluateGolden(100, functions, oop).getType());

        checkTrue("passing unlocks the next topic",
                  engine.evaluateGolden(60, functions, oop).isNextTopicUnlocked());
        checkFalse("failing does NOT unlock the next topic",
                   engine.evaluateGolden(40, functions, oop).isNextTopicUnlocked());
        checkTrue("failing still allows another golden attempt",
                  engine.evaluateGolden(40, functions, oop).isGoldenUnlocked());

        check("passing names the topic it unlocked",
              "OOP", engine.evaluateGolden(60, functions, oop).getNextTopicTitle());
        checkTrue("passing a Golden Assessment on a BASIC path remains navigable",
                  engine.evaluateGolden(60, functions, topic(2, "Conditions", TopicBean.BASIC))
                        .isNextTopicUnlocked());
    }

    // -----------------------------------------------------------------
    //  UNLOCK RULE : the gate that gives the Golden Assessment its purpose
    // -----------------------------------------------------------------
    private static void testUnlockRules() {
        section("Unlock rules");
        RecommendationEngine engine = new RecommendationEngine();
        TopicBean basic = topic(2, "Conditions", TopicBean.BASIC);
        TopicBean advanced = topic(5, "OOP", TopicBean.ADVANCED);

        checkTrue("the first topic is always open",
                  engine.isUnlocked(basic, true, 0, false));

        checkFalse("a BASIC topic stays locked when the previous score is 49",
                   engine.isUnlocked(basic, false, 49, false));
        checkTrue("a BASIC topic opens when the previous score is 50",
                  engine.isUnlocked(basic, false, 50, false));
        checkTrue("a BASIC topic opens at 100 without any golden pass",
                  engine.isUnlocked(basic, false, 100, false));

        checkFalse("an ADVANCED topic stays locked at 100 without a golden pass",
                   engine.isUnlocked(advanced, false, 100, false));
        checkTrue("an ADVANCED topic opens at 100 with a golden pass",
                  engine.isUnlocked(advanced, false, 100, true));
        checkFalse("an ADVANCED topic stays locked at 40 even with a golden pass",
                   engine.isUnlocked(advanced, false, 40, true));
    }

    // -----------------------------------------------------------------
    //  The exact numbers the whole project depends on
    // -----------------------------------------------------------------
    private static void testBoundaries() {
        section("Constants");
        check("low score is 50",  50, RuleConstants.LOW_SCORE);
        check("high score is 80", 80, RuleConstants.HIGH_SCORE);
        check("the golden assessment has 5 questions",
              5, RuleConstants.GOLDEN_QUESTION_COUNT);
        check("the golden pass mark is 60",
              60, RuleConstants.GOLDEN_PASS_SCORE);
        check("the quiz has 10 questions",
              10, RuleConstants.QUIZ_QUESTION_COUNT);

        // 3 correct out of 5 must be at or above the pass mark
        int threeOfFive = model.Attempt.calculatePercentage(3, 5);
        checkTrue("3 of 5 (" + threeOfFive + "%) reaches the pass mark",
                  threeOfFive >= RuleConstants.GOLDEN_PASS_SCORE);
        int twoOfFive = model.Attempt.calculatePercentage(2, 5);
        checkFalse("2 of 5 (" + twoOfFive + "%) does not reach it",
                   twoOfFive >= RuleConstants.GOLDEN_PASS_SCORE);

        // Percentage rounding used everywhere
        check("7 of 10 is 70%", 70, model.Attempt.calculatePercentage(7, 10));
        check("0 of 10 is 0%",   0, model.Attempt.calculatePercentage(0, 10));
        check("no questions scores 0", 0, model.Attempt.calculatePercentage(0, 0));
    }

    private static void testCurrentTopic() {
        section("Dashboard next step");
        ProgressBean progress = new ProgressBean();
        TopicProgress basic = pathTopic(1, true, 70, false);
        TopicProgress advanced = pathTopic(2, false, 0, false);
        progress.setTopics(Arrays.asList(basic, advanced));
        check("a locked advanced topic points back to its prerequisite",
              basic, progress.getCurrentTopic());

        basic.setBestQuizScore(90);
        check("a Golden gate stays actionable after a high quiz score",
              basic, progress.getCurrentTopic());

        advanced.setUnlocked(true);
        advanced.setBestQuizScore(20);
        check("an incomplete unlocked topic takes priority",
              advanced, progress.getCurrentTopic());

        advanced.setBestQuizScore(50);
        check("all passing topics complete the path",
              null, progress.getCurrentTopic());
    }

    private static TopicProgress pathTopic(int id, boolean unlocked, int score, boolean goldenPassed) {
        TopicProgress topic = new TopicProgress();
        topic.setTopicId(id);
        topic.setUnlocked(unlocked);
        topic.setBestQuizScore(score);
        topic.setGoldenPassed(goldenPassed);
        return topic;
    }

    // -----------------------------------------------------------------
    //  Tiny test helpers - no library needed
    // -----------------------------------------------------------------
    private static TopicBean topic(int order, String title, String difficulty) {
        TopicBean t = new TopicBean();
        t.setTopicId(order);
        t.setTopicOrder(order);
        t.setTitle(title);
        t.setDifficulty(difficulty);
        return t;
    }

    private static void section(String name) {
        System.out.println("\n-- " + name + " --");
    }

    private static void check(String what, Object expected, Object actual) {
        if (expected == null ? actual == null : expected.equals(actual)) {
            pass(what);
        } else {
            fail(what + "  (expected " + expected + ", got " + actual + ")");
        }
    }

    private static void check(String what, int expected, int actual) {
        check(what, Integer.valueOf(expected), Integer.valueOf(actual));
    }

    private static void checkTrue(String what, boolean actual) {
        if (actual) { pass(what); } else { fail(what + "  (expected true)"); }
    }

    private static void checkFalse(String what, boolean actual) {
        if (!actual) { pass(what); } else { fail(what + "  (expected false)"); }
    }

    private static void pass(String what) {
        passed++;
        System.out.println("  PASS  " + what);
    }

    private static void fail(String what) {
        failed++;
        System.out.println("  FAIL  " + what);
    }
}
