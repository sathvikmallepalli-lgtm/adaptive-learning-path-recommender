package controller;

import java.io.IOException;
import java.util.List;

import beans.RecommendationBean;
import beans.StudentBean;
import beans.TopicBean;
import dao.AttemptDAO;
import dao.RecommendationDAO;
import dao.StudentDAO;
import dao.TopicDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Attempt;

/**
 * The teacher home screen: totals across the whole class and the most
 * recent activity.
 */
@WebServlet("/teacherDashboard")
public class TeacherDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final StudentDAO studentDAO = new StudentDAO();
    private final TopicDAO topicDAO = new TopicDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final RecommendationDAO recommendationDAO = new RecommendationDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<StudentBean> students = studentDAO.findAll();
        List<TopicBean> topics = topicDAO.findAll();
        List<Attempt> attempts = attemptDAO.findAll();
        List<RecommendationBean> recommendations = recommendationDAO.findAll();

        // Count how many Golden Assessments were passed across the class
        int goldenAttempts = 0;
        int goldenPassed = 0;
        for (Attempt a : attempts) {
            if (a.isGolden()) {
                goldenAttempts++;
                if (a.getScore() >= engine.RuleConstants.GOLDEN_PASS_SCORE) {
                    goldenPassed++;
                }
            }
        }

        List<Attempt> recent = attempts.size() > 8 ? attempts.subList(0, 8) : attempts;

        request.setAttribute("studentCount", Integer.valueOf(students.size()));
        request.setAttribute("topicCount", Integer.valueOf(topics.size()));
        request.setAttribute("attemptCount", Integer.valueOf(attempts.size()));
        request.setAttribute("recommendationCount", Integer.valueOf(recommendations.size()));
        request.setAttribute("goldenAttempts", Integer.valueOf(goldenAttempts));
        request.setAttribute("goldenPassed", Integer.valueOf(goldenPassed));
        request.setAttribute("recentAttempts", recent);
        request.getRequestDispatcher("/teacherDashboard.jsp").forward(request, response);
    }
}
