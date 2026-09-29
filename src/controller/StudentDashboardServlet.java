package controller;

import java.io.IOException;
import java.util.List;

import beans.ProgressBean;
import beans.RecommendationBean;
import beans.StudentBean;
import dao.AttemptDAO;
import dao.RecommendationDAO;
import engine.RecommendationEngine;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Attempt;

/**
 * The student home screen: overall progress, the latest recommendation and
 * the last few attempts.
 */
@WebServlet("/studentDashboard")
public class StudentDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final RecommendationEngine engine = new RecommendationEngine();
    private final RecommendationDAO recommendationDAO = new RecommendationDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        StudentBean student = (StudentBean) request.getSession().getAttribute("student");

        ProgressBean progress = engine.buildProgress(student.getStudentId());
        RecommendationBean latest = recommendationDAO.findLatestByStudent(student.getStudentId());
        List<Attempt> attempts = attemptDAO.findByStudent(student.getStudentId());

        // Show at most the five most recent attempts on the dashboard
        if (attempts.size() > 5) {
            attempts = attempts.subList(0, 5);
        }

        request.setAttribute("progress", progress);
        request.setAttribute("latestRecommendation", latest);
        request.setAttribute("recentAttempts", attempts);
        request.getRequestDispatcher("/studentDashboard.jsp").forward(request, response);
    }
}
