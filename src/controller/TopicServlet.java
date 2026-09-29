package controller;

import java.io.IOException;
import java.util.List;

import beans.ProgressBean;
import beans.QuestionBean;
import beans.StudentBean;
import beans.TopicBean;
import dao.QuestionDAO;
import dao.TopicDAO;
import engine.RecommendationEngine;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.TopicProgress;
import util.Validator;

/**
 * One module: the notes and the practice questions.
 *
 * Before anything is shown the servlet checks that the engine really has
 * unlocked this topic for this student, so a locked topic cannot be opened
 * by editing the id in the address bar.
 */
@WebServlet("/topic")
public class TopicServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final TopicDAO topicDAO = new TopicDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();
    private final RecommendationEngine engine = new RecommendationEngine();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        StudentBean student = (StudentBean) request.getSession().getAttribute("student");
        int topicId = Validator.toInt(request.getParameter("id"), 0);

        TopicBean topic = topicId > 0 ? topicDAO.findById(topicId) : null;
        if (topic == null) {
            response.sendRedirect(request.getContextPath() + "/modules?error=notfound");
            return;
        }

        // ---------- the lock check ----------
        ProgressBean progress = engine.buildProgress(student.getStudentId());
        TopicProgress state = null;
        for (TopicProgress tp : progress.getTopics()) {
            if (tp.getTopicId() == topicId) {
                state = tp;
                break;
            }
        }
        if (state == null || !state.isUnlocked()) {
            response.sendRedirect(request.getContextPath() + "/modules?error=locked");
            return;
        }

        // Two separate sets: the everyday practice questions, and the harder
        // ones the engine points a student to after a failed Golden Assessment.
        List<QuestionBean> practice = questionDAO.findPractice(topicId, false);
        List<QuestionBean> advancedPractice = questionDAO.findPractice(topicId, true);

        request.setAttribute("topic", topic);
        request.setAttribute("state", state);
        request.setAttribute("practiceQuestions", practice);
        request.setAttribute("advancedPractice", advancedPractice);
        request.setAttribute("goldenAvailable",
                engine.isGoldenAvailable(student.getStudentId(), topicId));
        request.getRequestDispatcher("/topic.jsp").forward(request, response);
    }
}
