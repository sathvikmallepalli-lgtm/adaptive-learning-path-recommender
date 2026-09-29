package controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import beans.ProgressBean;
import beans.QuestionBean;
import beans.QuizBean;
import beans.RecommendationBean;
import beans.StudentBean;
import beans.TopicBean;
import dao.AttemptDAO;
import dao.QuestionDAO;
import dao.TopicDAO;
import engine.RecommendationEngine;
import engine.RuleConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Attempt;
import model.RuleResult;
import model.TopicProgress;
import util.Validator;

/**
 * The topic quiz.
 *
 *   GET  /quiz?topicId=3   starts the quiz and shows the questions
 *   POST /quiz             grades it, stores the attempt, asks the engine
 *                          for a recommendation and stores that too
 *
 * The grading itself is NOT done here - it is done by QuizBean.evaluate().
 * The decision about what to do next is NOT done here either - that is the
 * job of RecommendationEngine. This servlet only moves data between them.
 */
@WebServlet("/quiz")
public class QuizServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /** The quiz being taken is parked in the session under this name. */
    static final String ACTIVE_QUIZ = "activeQuiz";
    /** Where the servlet leaves the engine decision for recommendation.jsp. */
    static final String LAST_RESULT = "lastResult";

    private final TopicDAO topicDAO = new TopicDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final RecommendationEngine engine = new RecommendationEngine();

    // -----------------------------------------------------------------
    //  START THE QUIZ
    // -----------------------------------------------------------------
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        StudentBean student = (StudentBean) session.getAttribute("student");
        int topicId = Validator.toInt(request.getParameter("topicId"), 0);

        TopicBean topic = topicId > 0 ? topicDAO.findById(topicId) : null;
        if (topic == null) {
            response.sendRedirect(request.getContextPath() + "/modules?error=notfound");
            return;
        }

        // A locked topic may not be quizzed, whatever the URL says
        if (!isUnlocked(student.getStudentId(), topicId)) {
            response.sendRedirect(request.getContextPath() + "/modules?error=locked");
            return;
        }

        List<QuestionBean> questions = questionDAO.findByTopicAndType(
                topicId, QuestionBean.QUIZ, RuleConstants.QUIZ_QUESTION_COUNT);

        if (questions.size() != RuleConstants.QUIZ_QUESTION_COUNT) {
            response.sendRedirect(request.getContextPath()
                    + "/topic?id=" + topicId + "&error=noquestions");
            return;
        }

        QuizBean quiz = new QuizBean();
        quiz.setStudentId(student.getStudentId());
        quiz.setTopicId(topicId);
        quiz.setTopicTitle(topic.getTitle());
        quiz.setAttemptType(Attempt.TYPE_QUIZ);
        quiz.setQuestions(questions);

        // Kept in the session so the answers are graded against exactly the
        // questions that were shown, and so the correct answers are never
        // sent to the browser.
        session.setAttribute(ACTIVE_QUIZ, quiz);

        request.setAttribute("quiz", quiz);
        request.setAttribute("topic", topic);
        request.getRequestDispatcher("/quiz.jsp").forward(request, response);
    }

    // -----------------------------------------------------------------
    //  SUBMIT THE QUIZ
    // -----------------------------------------------------------------
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        StudentBean student = (StudentBean) session.getAttribute("student");
        QuizBean quiz = (QuizBean) session.getAttribute(ACTIVE_QUIZ);

        synchronized (session) {
            // A second POST, or a Golden form posted to /quiz, is not a quiz.
            if (quiz == null || quiz.isGolden() || quiz.isEvaluated()
                    || quiz.getStudentId() != student.getStudentId()
                    || session.getAttribute(ACTIVE_QUIZ) != quiz) {
                response.sendRedirect(request.getContextPath() + "/modules?error=expired");
                return;
            }

            TopicBean topic = topicDAO.findById(quiz.getTopicId());
            if (topic == null || !isUnlocked(student.getStudentId(), topic.getTopicId())) {
                session.removeAttribute(ACTIVE_QUIZ);
                response.sendRedirect(request.getContextPath() + "/modules?error=locked");
                return;
            }

            Map<Integer, String> answers = readAnswers(request, quiz);
            int score = quiz.evaluate(answers);
            TopicBean nextTopic = topicDAO.findNext(topic.getTopicOrder());
            RuleResult result = engine.evaluateQuiz(score, topic, nextTopic);
            Attempt attempt = quiz.toAttempt();
            RecommendationBean rec = RecommendationBean.from(
                    student.getStudentId(), topic.getTopicId(), result);

            if (!attemptDAO.insertWithRecommendation(attempt, rec)) {
                quiz.setEvaluated(false);
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Could not save the quiz result. Please try submitting again.");
                return;
            }

            session.removeAttribute(ACTIVE_QUIZ);
            session.setAttribute(LAST_RESULT, result);
            session.setAttribute("lastQuiz", quiz);
        }

        // Redirect rather than forward, so refreshing the result page does
        // not submit the quiz a second time.
        response.sendRedirect(request.getContextPath() + "/recommendation");
    }

    /**
     * Reads one radio button value per question.
     * A question the student skipped is simply not added to the map, and
     * QuizBean counts it as wrong.
     */
    private Map<Integer, String> readAnswers(HttpServletRequest request, QuizBean quiz) {
        Map<Integer, String> answers = new HashMap<Integer, String>();
        for (QuestionBean q : quiz.getQuestions()) {
            String value = request.getParameter("q" + q.getQuestionId());
            if (Validator.isValidOption(value)) {
                answers.put(Integer.valueOf(q.getQuestionId()), value.toUpperCase());
            }
        }
        return answers;
    }

    /** Asks the engine whether this topic is open for this student. */
    private boolean isUnlocked(int studentId, int topicId) {
        ProgressBean progress = engine.buildProgress(studentId);
        for (TopicProgress tp : progress.getTopics()) {
            if (tp.getTopicId() == topicId) {
                return tp.isUnlocked();
            }
        }
        return false;
    }
}
