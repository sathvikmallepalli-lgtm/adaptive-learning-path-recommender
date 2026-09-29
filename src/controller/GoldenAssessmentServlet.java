package controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import util.Validator;

/**
 * THE GOLDEN ASSESSMENT - the special feature of this project.
 *
 * It is entered only through one door: the student must already have scored
 * above 80% in the normal quiz for the topic. That check is made by
 * RecommendationEngine.isGoldenAvailable(), never by the JSP, so hiding the
 * button is a convenience and not the actual protection.
 *
 *   GET  /golden?topicId=3   shows the five challenging questions
 *   POST /golden             grades them and applies the pass/fail rule
 *
 * Pass  (60% or more, that is 3 of 5) -> the advanced topic is unlocked
 * Fail  (below 60%)                   -> advanced practice is recommended
 *
 * Everything here is if/else. Nothing is predicted or learned.
 */
@WebServlet("/golden")
public class GoldenAssessmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final TopicDAO topicDAO = new TopicDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final RecommendationEngine engine = new RecommendationEngine();

    // -----------------------------------------------------------------
    //  START THE GOLDEN ASSESSMENT
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

        // ---------- THE GATE ----------
        // Only a quiz score above 80% opens the Golden Assessment.
        if (!engine.isGoldenAvailable(student.getStudentId(), topicId)) {
            response.sendRedirect(request.getContextPath()
                    + "/topic?id=" + topicId + "&error=goldenlocked");
            return;
        }

        List<QuestionBean> questions = questionDAO.findByTopicAndType(
                topicId, QuestionBean.GOLDEN, RuleConstants.GOLDEN_QUESTION_COUNT);

        if (questions.size() != RuleConstants.GOLDEN_QUESTION_COUNT) {
            response.sendRedirect(request.getContextPath()
                    + "/topic?id=" + topicId + "&error=noquestions");
            return;
        }

        QuizBean golden = new QuizBean();
        golden.setStudentId(student.getStudentId());
        golden.setTopicId(topicId);
        golden.setTopicTitle(topic.getTitle());
        golden.setAttemptType(Attempt.TYPE_GOLDEN);
        golden.setQuestions(questions);

        session.setAttribute(QuizServlet.ACTIVE_QUIZ, golden);

        request.setAttribute("quiz", golden);
        request.setAttribute("topic", topic);
        request.getRequestDispatcher("/goldenAssessment.jsp").forward(request, response);
    }

    // -----------------------------------------------------------------
    //  SUBMIT THE GOLDEN ASSESSMENT
    // -----------------------------------------------------------------
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        StudentBean student = (StudentBean) session.getAttribute("student");
        QuizBean golden = (QuizBean) session.getAttribute(QuizServlet.ACTIVE_QUIZ);

        synchronized (session) {
            if (golden == null || !golden.isGolden() || golden.isEvaluated()
                    || golden.getStudentId() != student.getStudentId()
                    || session.getAttribute(QuizServlet.ACTIVE_QUIZ) != golden) {
                response.sendRedirect(request.getContextPath() + "/modules?error=expired");
                return;
            }

            TopicBean topic = topicDAO.findById(golden.getTopicId());
            if (topic == null || !engine.isGoldenAvailable(student.getStudentId(), topic.getTopicId())) {
                session.removeAttribute(QuizServlet.ACTIVE_QUIZ);
                response.sendRedirect(request.getContextPath() + "/modules?error=locked");
                return;
            }

            Map<Integer, String> answers = new HashMap<Integer, String>();
            for (QuestionBean q : golden.getQuestions()) {
                String value = request.getParameter("q" + q.getQuestionId());
                if (Validator.isValidOption(value)) {
                    answers.put(Integer.valueOf(q.getQuestionId()), value.toUpperCase());
                }
            }
            int score = golden.evaluate(answers);
            TopicBean nextTopic = topicDAO.findNext(topic.getTopicOrder());
            RuleResult result = engine.evaluateGolden(score, topic, nextTopic);
            Attempt attempt = golden.toAttempt();
            RecommendationBean rec = RecommendationBean.from(
                    student.getStudentId(), topic.getTopicId(), result);

            if (!attemptDAO.insertWithRecommendation(attempt, rec)) {
                golden.setEvaluated(false);
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Could not save the assessment result. Please try submitting again.");
                return;
            }

            session.removeAttribute(QuizServlet.ACTIVE_QUIZ);
            session.setAttribute(QuizServlet.LAST_RESULT, result);
            session.setAttribute("lastQuiz", golden);
        }

        response.sendRedirect(request.getContextPath() + "/recommendation");
    }
}
