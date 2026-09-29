package controller;

import java.io.IOException;
import java.util.List;

import dao.AttemptDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Attempt;

/**
 * Every quiz and Golden Assessment attempt made by every student.
 */
@WebServlet("/viewAttempts")
public class ViewAttemptsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final AttemptDAO attemptDAO = new AttemptDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Attempt> attempts = attemptDAO.findAll();

        int quizCount = 0;
        int goldenCount = 0;
        int scoreTotal = 0;
        for (Attempt a : attempts) {
            if (a.isGolden()) {
                goldenCount++;
            } else {
                quizCount++;
            }
            scoreTotal += a.getScore();
        }
        int average = attempts.isEmpty() ? 0 : Math.round((float) scoreTotal / attempts.size());

        request.setAttribute("attempts", attempts);
        request.setAttribute("quizCount", Integer.valueOf(quizCount));
        request.setAttribute("goldenCount", Integer.valueOf(goldenCount));
        request.setAttribute("averageScore", Integer.valueOf(average));
        request.getRequestDispatcher("/viewAttempts.jsp").forward(request, response);
    }
}
