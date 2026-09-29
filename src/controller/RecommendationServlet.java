package controller;

import java.io.IOException;
import java.util.List;

import beans.QuizBean;
import beans.RecommendationBean;
import beans.StudentBean;
import dao.RecommendationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.RuleResult;
import util.Validator;

/**
 * Shows what the rule engine decided, plus the history of everything it has
 * ever advised this student.
 *
 *   GET  /recommendation                  show the result and the history
 *   POST /recommendation  action=complete mark one recommendation as done
 */
@WebServlet("/recommendation")
public class RecommendationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final RecommendationDAO recommendationDAO = new RecommendationDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        StudentBean student = (StudentBean) session.getAttribute("student");

        // Put there by QuizServlet or GoldenAssessmentServlet a moment ago.
        RuleResult result = (RuleResult) session.getAttribute(QuizServlet.LAST_RESULT);
        QuizBean lastQuiz = (QuizBean) session.getAttribute("lastQuiz");

        List<RecommendationBean> history =
                recommendationDAO.findByStudent(student.getStudentId());

        request.setAttribute("result", result);
        request.setAttribute("lastQuiz", lastQuiz);
        request.setAttribute("history", history);
        request.getRequestDispatcher("/recommendation.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        StudentBean student = (StudentBean) session.getAttribute("student");

        String action = Validator.clean(request.getParameter("action"));
        int id = Validator.toInt(request.getParameter("recommendationId"), 0);

        if ("complete".equals(action) && id > 0) {
            // The student id is part of the update, so one student can never
            // complete another student's recommendation.
            recommendationDAO.markCompleted(id, student.getStudentId());
        }

        response.sendRedirect(request.getContextPath() + "/recommendation");
    }
}
