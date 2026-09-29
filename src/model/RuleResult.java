package model;

import java.io.Serializable;

/**
 * What the Recommendation Engine decided after one attempt.
 *
 * It is a plain result object: the engine fills it in, the servlet saves the
 * recommendation and the JSP displays it. No logic lives here.
 */
public class RuleResult implements Serializable {

    private static final long serialVersionUID = 1L;

    // The seven values also used by the recommendations.recommendation_type column
    public static final String REVISION = "REVISION";
    public static final String PRACTICE = "PRACTICE";
    public static final String RETAKE_QUIZ = "RETAKE_QUIZ";
    public static final String NEXT_TOPIC = "NEXT_TOPIC";
    public static final String GOLDEN_ASSESSMENT = "GOLDEN_ASSESSMENT";
    public static final String UNLOCK_ADVANCED = "UNLOCK_ADVANCED";
    public static final String ADVANCED_PRACTICE = "ADVANCED_PRACTICE";

    private String type;            // one of the constants above
    private String message;         // sentence shown to the student
    private String headline;        // short title on the recommendation card
    private boolean goldenUnlocked; // show the "Start Golden Assessment" button
    private boolean nextTopicUnlocked;
    private int nextTopicId;        // 0 when there is no next topic
    private String nextTopicTitle;

    public RuleResult() {
    }

    public RuleResult(String type, String headline, String message) {
        this.type = type;
        this.headline = headline;
        this.message = message;
    }

    /** Bootstrap colour for the recommendation card. */
    public String getColour() {
        if (UNLOCK_ADVANCED.equals(type))   return "warning";
        if (GOLDEN_ASSESSMENT.equals(type)) return "warning";
        if (NEXT_TOPIC.equals(type))        return "success";
        if (ADVANCED_PRACTICE.equals(type)) return "info";
        return "danger";
    }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getHeadline() { return headline; }
    public void setHeadline(String headline) { this.headline = headline; }

    public boolean isGoldenUnlocked() { return goldenUnlocked; }
    public void setGoldenUnlocked(boolean goldenUnlocked) { this.goldenUnlocked = goldenUnlocked; }

    public boolean isNextTopicUnlocked() { return nextTopicUnlocked; }
    public void setNextTopicUnlocked(boolean nextTopicUnlocked) { this.nextTopicUnlocked = nextTopicUnlocked; }

    public int getNextTopicId() { return nextTopicId; }
    public void setNextTopicId(int nextTopicId) { this.nextTopicId = nextTopicId; }

    public String getNextTopicTitle() { return nextTopicTitle; }
    public void setNextTopicTitle(String nextTopicTitle) { this.nextTopicTitle = nextTopicTitle; }
}
