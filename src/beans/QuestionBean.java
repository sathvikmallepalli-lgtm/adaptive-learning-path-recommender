package beans;

import java.io.Serializable;

/**
 * One multiple choice question.
 *
 * questionType decides where the question is used:
 *   PRACTICE - the practice section, not scored
 *   QUIZ     - the ten question topic quiz
 *   GOLDEN   - the five question Golden Assessment
 */
public class QuestionBean implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String PRACTICE = "PRACTICE";
    public static final String QUIZ = "QUIZ";
    public static final String GOLDEN = "GOLDEN";

    private int questionId;
    private int topicId;
    private String question;
    private String optionA;
    private String optionB;
    private String optionC;
    private String optionD;
    private String correctAnswer;   // "A", "B", "C" or "D"
    private String difficulty = "EASY";
    private String questionType = QUIZ;

    private String topicTitle;      // filled in by joins on the teacher screens

    public QuestionBean() {
    }

    /**
     * Checks one submitted answer.
     *
     * @param given the letter the student selected, may be null if skipped
     * @return true when it matches the correct answer
     */
    public boolean isCorrect(String given) {
        return given != null && given.trim().equalsIgnoreCase(correctAnswer);
    }

    /** Lets the JSP read the four options in a loop instead of four ifs. */
    public String getOption(String letter) {
        if (letter == null) {
            return "";
        }
        switch (letter.toUpperCase()) {
            case "A": return optionA;
            case "B": return optionB;
            case "C": return optionC;
            case "D": return optionD;
            default:  return "";
        }
    }

    public int getQuestionId() { return questionId; }
    public void setQuestionId(int questionId) { this.questionId = questionId; }

    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public String getOptionA() { return optionA; }
    public void setOptionA(String optionA) { this.optionA = optionA; }

    public String getOptionB() { return optionB; }
    public void setOptionB(String optionB) { this.optionB = optionB; }

    public String getOptionC() { return optionC; }
    public void setOptionC(String optionC) { this.optionC = optionC; }

    public String getOptionD() { return optionD; }
    public void setOptionD(String optionD) { this.optionD = optionD; }

    public String getCorrectAnswer() { return correctAnswer; }
    public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }

    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }

    public String getQuestionType() { return questionType; }
    public void setQuestionType(String questionType) { this.questionType = questionType; }

    public String getTopicTitle() { return topicTitle; }
    public void setTopicTitle(String topicTitle) { this.topicTitle = topicTitle; }
}
