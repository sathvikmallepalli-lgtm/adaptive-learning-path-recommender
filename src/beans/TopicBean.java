package beans;

import java.io.Serializable;

/**
 * One module of the Python course.
 *
 * topicOrder decides the position in the learning path and difficulty
 * (BASIC or ADVANCED) decides whether the Golden Assessment guards it.
 */
public class TopicBean implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String BASIC = "BASIC";
    public static final String ADVANCED = "ADVANCED";

    private int topicId;
    private String title;
    private String description;
    private String notes;
    private String difficulty = BASIC;
    private int topicOrder;

    public TopicBean() {
    }

    public boolean isAdvanced() {
        return ADVANCED.equalsIgnoreCase(difficulty);
    }

    /** Bootstrap badge colour for the difficulty label. */
    public String getDifficultyColour() {
        return isAdvanced() ? "warning" : "primary";
    }

    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }

    public int getTopicOrder() { return topicOrder; }
    public void setTopicOrder(int topicOrder) { this.topicOrder = topicOrder; }
}
