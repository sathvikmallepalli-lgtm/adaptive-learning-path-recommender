package model;

import java.io.Serializable;

/**
 * How one student is doing on one topic.
 *
 * Nothing here is stored in a table - the Recommendation Engine builds these
 * objects from the attempts table every time a page is opened. That is why
 * the design has no progress table.
 */
public class TopicProgress implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String STATUS_LOCKED = "LOCKED";
    public static final String STATUS_NOT_STARTED = "NOT STARTED";
    public static final String STATUS_NEEDS_REVISION = "NEEDS REVISION";
    public static final String STATUS_COMPLETED = "COMPLETED";
    public static final String STATUS_MASTERED = "MASTERED";

    private int topicId;
    private String title;
    private String difficulty;      // BASIC or ADVANCED
    private int topicOrder;

    private int bestQuizScore;      // 0 when never attempted
    private int quizAttempts;
    private boolean goldenAttempted;
    private boolean goldenPassed;

    private boolean unlocked;
    private String status = STATUS_LOCKED;

    public boolean isAdvanced() {
        return "ADVANCED".equalsIgnoreCase(difficulty);
    }

    public boolean isAttempted() {
        return quizAttempts > 0;
    }

    /** Colour used by the Bootstrap progress bar and badges. */
    public String getStatusColour() {
        if (!unlocked)                            return "secondary";
        if (STATUS_MASTERED.equals(status))       return "warning";
        if (STATUS_COMPLETED.equals(status))      return "success";
        if (STATUS_NEEDS_REVISION.equals(status)) return "danger";
        return "info";
    }

    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }

    public int getTopicOrder() { return topicOrder; }
    public void setTopicOrder(int topicOrder) { this.topicOrder = topicOrder; }

    public int getBestQuizScore() { return bestQuizScore; }
    public void setBestQuizScore(int bestQuizScore) { this.bestQuizScore = bestQuizScore; }

    public int getQuizAttempts() { return quizAttempts; }
    public void setQuizAttempts(int quizAttempts) { this.quizAttempts = quizAttempts; }

    public boolean isGoldenAttempted() { return goldenAttempted; }
    public void setGoldenAttempted(boolean goldenAttempted) { this.goldenAttempted = goldenAttempted; }

    public boolean isGoldenPassed() { return goldenPassed; }
    public void setGoldenPassed(boolean goldenPassed) { this.goldenPassed = goldenPassed; }

    public boolean isUnlocked() { return unlocked; }
    public void setUnlocked(boolean unlocked) { this.unlocked = unlocked; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
