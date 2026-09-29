package engine;

/**
 * Every number the rule engine uses, in one place.
 *
 * If a teacher wants a stricter course, these are the only values that
 * have to change - no other file needs editing.
 */
public final class RuleConstants {

    /** Below this the student must revise. */
    public static final int LOW_SCORE = 50;

    /** Above this the Golden Assessment is offered. */
    public static final int HIGH_SCORE = 80;

    /** How many questions a normal topic quiz has. */
    public static final int QUIZ_QUESTION_COUNT = 10;

    /** The Golden Assessment is always exactly five challenging questions. */
    public static final int GOLDEN_QUESTION_COUNT = 5;

    /** Percentage needed to pass the Golden Assessment (3 out of 5). */
    public static final int GOLDEN_PASS_SCORE = 60;

    private RuleConstants() {
    }
}
