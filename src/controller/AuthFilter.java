package controller;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Session guard.
 *
 * Runs before every request. If a page needs a login and there is no session,
 * the browser is sent back to login.jsp. This is what stops a student from
 * simply typing studentDashboard.jsp in the address bar.
 *
 * It also keeps the two roles apart: a student cannot open a teacher page
 * even if they know the URL.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    /** Pages anyone may open without logging in. */
    private static final Set<String> PUBLIC_PAGES = new HashSet<String>(Arrays.asList(
            "/", "/index.jsp", "/login.jsp", "/register.jsp", "/error.jsp",
            "/login", "/register", "/logout", "/logout.jsp"
    ));

    /** Pages only a teacher may open. */
    private static final Set<String> TEACHER_PAGES = new HashSet<String>(Arrays.asList(
            "/teacherDashboard", "/teacherDashboard.jsp",
            "/manageTopics", "/manageTopics.jsp",
            "/manageQuestions", "/manageQuestions.jsp",
            "/viewAttempts", "/viewAttempts.jsp",
            "/viewRecommendations", "/viewRecommendations.jsp"
    ));

    /**
     * A JSP typed straight into the address bar has none of the data its
     * servlet would have prepared, so it would fail with a null value.
     * Each one is sent to the servlet that knows how to fill it instead.
     *
     * This only affects a browser asking for the page directly - a forward
     * from a servlet is not passed through filters, so the normal flow is
     * untouched.
     */
    private static final Map<String, String> JSP_TO_SERVLET = new HashMap<String, String>();
    static {
        JSP_TO_SERVLET.put("/studentDashboard.jsp",   "/studentDashboard");
        JSP_TO_SERVLET.put("/modules.jsp",            "/modules");
        JSP_TO_SERVLET.put("/progress.jsp",           "/progress");
        JSP_TO_SERVLET.put("/recommendation.jsp",     "/recommendation");
        // These three need a topic id that a typed URL does not carry,
        // so the student is sent back to the list of modules.
        JSP_TO_SERVLET.put("/topic.jsp",              "/modules");
        JSP_TO_SERVLET.put("/quiz.jsp",               "/modules");
        JSP_TO_SERVLET.put("/goldenAssessment.jsp",   "/modules");

        JSP_TO_SERVLET.put("/teacherDashboard.jsp",   "/teacherDashboard");
        JSP_TO_SERVLET.put("/manageTopics.jsp",       "/manageTopics");
        JSP_TO_SERVLET.put("/manageQuestions.jsp",    "/manageQuestions");
        JSP_TO_SERVLET.put("/viewAttempts.jsp",       "/viewAttempts");
        JSP_TO_SERVLET.put("/viewRecommendations.jsp","/viewRecommendations");
    }

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String context = request.getContextPath();
        String path = request.getRequestURI().substring(context.length());
        if (path.isEmpty()) {
            path = "/";
        }

        // Static files are always allowed - the page must be able to load its style
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/")) {
            chain.doFilter(req, res);
            return;
        }

        if (PUBLIC_PAGES.contains(path)) {
            chain.doFilter(req, res);
            return;
        }

        // getSession(false) does NOT create a new session - it only looks
        HttpSession session = request.getSession(false);
        boolean isStudent = session != null && session.getAttribute("student") != null;
        boolean isTeacher = session != null && session.getAttribute("teacher") != null;

        if (!isStudent && !isTeacher) {
            response.sendRedirect(context + "/login.jsp?error=session");
            return;
        }

        if (TEACHER_PAGES.contains(path) && !isTeacher) {
            response.sendRedirect(context + "/studentDashboard?error=denied");
            return;
        }

        if (!TEACHER_PAGES.contains(path) && !isStudent) {
            // A teacher tried to open a student page
            response.sendRedirect(context + "/teacherDashboard?error=denied");
            return;
        }

        // Private HTML must be fetched again after logout, not shown from
        // the browser's back/forward cache.
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");

        // A JSP asked for directly goes to its servlet, so the page always
        // has the data it needs instead of failing on a null value.
        String servlet = JSP_TO_SERVLET.get(path);
        if (servlet != null) {
            response.sendRedirect(context + servlet);
            return;
        }

        chain.doFilter(req, res);
    }

    public void init(jakarta.servlet.FilterConfig config) throws ServletException {
    }

    public void destroy() {
    }
}
