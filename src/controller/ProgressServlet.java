package controller;

import java.io.IOException;
import java.util.List;

import beans.ProgressBean;
import beans.StudentBean;
import dao.AttemptDAO;
import engine.RecommendationEngine;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Attempt;

/**
 * The progress screen: a bar per topic plus the full attempt history.
 */
@WebServlet("/progress")
public class ProgressServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final RecommendationEngine engine = new RecommendationEngine();
    private final AttemptDAO attemptDAO = new AttemptDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        StudentBean student = (StudentBean) request.getSession().getAttribute("student");

        ProgressBean progress = engine.buildProgress(student.getStudentId());
        List<Attempt> history = attemptDAO.findByStudent(student.getStudentId());

        request.setAttribute("progress", progress);
        request.setAttribute("history", history);
        request.getRequestDispatcher("/progress.jsp").forward(request, response);
    }
}
