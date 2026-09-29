package controller;

import java.io.IOException;

import beans.ProgressBean;
import beans.StudentBean;
import engine.RecommendationEngine;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * The list of all eight modules with their lock state.
 *
 * The engine decides what is locked; this servlet only passes the answer
 * to the JSP.
 */
@WebServlet("/modules")
public class ModulesServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final RecommendationEngine engine = new RecommendationEngine();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        StudentBean student = (StudentBean) request.getSession().getAttribute("student");
        ProgressBean progress = engine.buildProgress(student.getStudentId());

        request.setAttribute("progress", progress);
        request.getRequestDispatcher("/modules.jsp").forward(request, response);
    }
}
