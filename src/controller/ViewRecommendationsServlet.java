package controller;

import java.io.IOException;
import java.util.List;

import beans.RecommendationBean;
import dao.RecommendationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Everything the rule engine has advised, for every student.
 *
 * This is the screen that shows a teacher that the adaptive path really is
 * driven by the rules.
 */
@WebServlet("/viewRecommendations")
public class ViewRecommendationsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final RecommendationDAO recommendationDAO = new RecommendationDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<RecommendationBean> recommendations = recommendationDAO.findAll();

        int pending = 0;
        for (RecommendationBean r : recommendations) {
            if (r.isPending()) {
                pending++;
            }
        }

        request.setAttribute("recommendations", recommendations);
        request.setAttribute("pendingCount", Integer.valueOf(pending));
        request.getRequestDispatcher("/viewRecommendations.jsp").forward(request, response);
    }
}
