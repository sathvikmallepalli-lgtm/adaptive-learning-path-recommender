package beans;

import java.io.Serializable;
import java.sql.Timestamp;

import model.RuleResult;

/**
 * One recommendation produced by the Recommendation Engine and stored in
 * the recommendations table.
 *
 * recommendationType tells recommendation.jsp which action button to draw,
 * so the page never has to read the message text to decide.
 */
public class RecommendationBean implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String PENDING = "PENDING";
    public static final String COMPLETED = "COMPLETED";

    private int recommendationId;
    private int studentId;
    private int topicId;
    private String recommendationType;
    private String recommendation;
    private String status = PENDING;
    private Timestamp createdDate;

    // Filled in by joins for the display screens
    private String topicTitle;
    private String studentName;

    public RecommendationBean() {
    }

    /** Builds a bean straight from what the engine decided. */
    public static RecommendationBean from(int studentId, int topicId, RuleResult result) {
        RecommendationBean r = new RecommendationBean();
        r.setStudentId(studentId);
        r.setTopicId(topicId);
        r.setRecommendationType(result.getType());
        r.setRecommendation(result.getMessage());
        r.setStatus(PENDING);
        return r;
    }

    public boolean isPending() {
        return PENDING.equals(status);
    }

    /** Bootstrap colour used by the badge on the recommendation card. */
    public String getColour() {
        if (RuleResult.UNLOCK_ADVANCED.equals(recommendationType))   return "warning";
        if (RuleResult.GOLDEN_ASSESSMENT.equals(recommendationType)) return "warning";
        if (RuleResult.NEXT_TOPIC.equals(recommendationType))        return "success";
        if (RuleResult.ADVANCED_PRACTICE.equals(recommendationType)) return "info";
        return "danger";
    }

    /** Human friendly version of the enum value, for tables. */
    public String getTypeLabel() {
        if (recommendationType == null) {
            return "";
        }
        if (RuleResult.UNLOCK_ADVANCED.equals(recommendationType)) {
            return "Golden passed";
        }
        return recommendationType.replace('_', ' ');
    }

    public int getRecommendationId() { return recommendationId; }
    public void setRecommendationId(int recommendationId) { this.recommendationId = recommendationId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }

    public String getRecommendationType() { return recommendationType; }
    public void setRecommendationType(String recommendationType) { this.recommendationType = recommendationType; }

    public String getRecommendation() { return recommendation; }
    public void setRecommendation(String recommendation) { this.recommendation = recommendation; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(Timestamp createdDate) { this.createdDate = createdDate; }

    public String getTopicTitle() { return topicTitle; }
    public void setTopicTitle(String topicTitle) { this.topicTitle = topicTitle; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
}
