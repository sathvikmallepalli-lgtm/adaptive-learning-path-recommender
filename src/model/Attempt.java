package model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * One row of the attempts table - a completed quiz or Golden Assessment.
 *
 * The specification names an AttemptDAO but no AttemptBean, so this plain
 * data class lives in the model package. studentName and topicTitle are
 * filled in only by the teacher screens, where the DAO joins the tables.
 */
public class Attempt implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String TYPE_QUIZ = "QUIZ";
    public static final String TYPE_GOLDEN = "GOLDEN";

    private int attemptId;
    private int studentId;
    private int topicId;
    private String attemptType = TYPE_QUIZ;
    private int score;              // percentage, 0..100
    private int correctAnswers;
    private int totalQuestions;
    private Timestamp attemptDate;

    // Filled by joins for the teacher screens only
    private String studentName;
    private String topicTitle;

    public Attempt() {
    }

    public Attempt(int studentId, int topicId, String attemptType,
                   int correctAnswers, int totalQuestions) {
        this.studentId = studentId;
        this.topicId = topicId;
        this.attemptType = attemptType;
        this.correctAnswers = correctAnswers;
        this.totalQuestions = totalQuestions;
        this.score = calculatePercentage(correctAnswers, totalQuestions);
    }

    /** Rounds to the nearest whole percent. Zero questions scores zero. */
    public static int calculatePercentage(int correct, int total) {
        if (total <= 0) {
            return 0;
        }
        return (int) Math.round((correct * 100.0) / total);
    }

    /** Convenience for the JSP: "7 / 10" */
    public String getScoreFraction() {
        return correctAnswers + " / " + totalQuestions;
    }

    public boolean isGolden() {
        return TYPE_GOLDEN.equals(attemptType);
    }

    public int getAttemptId() { return attemptId; }
    public void setAttemptId(int attemptId) { this.attemptId = attemptId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }

    public String getAttemptType() { return attemptType; }
    public void setAttemptType(String attemptType) { this.attemptType = attemptType; }

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }

    public int getCorrectAnswers() { return correctAnswers; }
    public void setCorrectAnswers(int correctAnswers) { this.correctAnswers = correctAnswers; }

    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

    public Timestamp getAttemptDate() { return attemptDate; }
    public void setAttemptDate(Timestamp attemptDate) { this.attemptDate = attemptDate; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getTopicTitle() { return topicTitle; }
    public void setTopicTitle(String topicTitle) { this.topicTitle = topicTitle; }
}
