package beans;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import model.Attempt;

/**
 * Holds one quiz (or one Golden Assessment) while the student is taking it,
 * and grades it when the answers come back.
 *
 * This is the business layer: the grading rule lives here, NOT in the JSP
 * and NOT in the servlet. The servlet only collects the form values and
 * hands them to {@link #evaluate(Map)}.
 */
public class QuizBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private int studentId;
    private int topicId;
    private String topicTitle;
    private String attemptType = Attempt.TYPE_QUIZ;   // QUIZ or GOLDEN

    private List<QuestionBean> questions = new ArrayList<QuestionBean>();

    // Filled in by evaluate()
    private int correctAnswers;
    private int totalQuestions;
    private int score;              // percentage 0..100
    private boolean evaluated;

    public QuizBean() {
    }

    /**
     * Grades the quiz.
     *
     * @param submittedAnswers key = question id, value = the letter chosen
     *                         (a question the student skipped is simply absent)
     * @return the score as a percentage
     */
    public int evaluate(Map<Integer, String> submittedAnswers) {
        int correct = 0;
        for (QuestionBean q : questions) {
            String given = submittedAnswers == null
                         ? null
                         : submittedAnswers.get(Integer.valueOf(q.getQuestionId()));
            if (q.isCorrect(given)) {
                correct++;
            }
        }
        this.correctAnswers = correct;
        this.totalQuestions = questions.size();
        this.score = Attempt.calculatePercentage(correct, totalQuestions);
        this.evaluated = true;
        return this.score;
    }

    /** Builds the row that AttemptDAO will insert. */
    public Attempt toAttempt() {
        Attempt a = new Attempt(studentId, topicId, attemptType,
                                correctAnswers, totalQuestions);
        a.setScore(score);
        return a;
    }

    public boolean isGolden() {
        return Attempt.TYPE_GOLDEN.equals(attemptType);
    }

    public boolean isEmpty() {
        return questions == null || questions.isEmpty();
    }

    public int getQuestionCount() {
        return questions == null ? 0 : questions.size();
    }

    public String getScoreFraction() {
        return correctAnswers + " / " + totalQuestions;
    }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }

    public String getTopicTitle() { return topicTitle; }
    public void setTopicTitle(String topicTitle) { this.topicTitle = topicTitle; }

    public String getAttemptType() { return attemptType; }
    public void setAttemptType(String attemptType) { this.attemptType = attemptType; }

    public List<QuestionBean> getQuestions() { return questions; }
    public void setQuestions(List<QuestionBean> questions) { this.questions = questions; }

    public int getCorrectAnswers() { return correctAnswers; }
    public void setCorrectAnswers(int correctAnswers) { this.correctAnswers = correctAnswers; }

    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }

    public boolean isEvaluated() { return evaluated; }
    public void setEvaluated(boolean evaluated) { this.evaluated = evaluated; }
}
