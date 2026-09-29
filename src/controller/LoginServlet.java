package controller;

import java.io.IOException;

import beans.StudentBean;
import beans.TeacherBean;
import dao.StudentDAO;
import dao.TeacherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.Validator;

/**
 * Handles the login form for both roles.
 *
 * The controller does three things only: read the form, ask the DAO, put the
 * result in the session. No SQL and no rules live here.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final StudentDAO studentDAO = new StudentDAO();
    private final TeacherDAO teacherDAO = new TeacherDAO();

    /** Someone typed /login in the address bar - just show the form. */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = Validator.clean(request.getParameter("email"));
        String password = request.getParameter("password");
        String role = Validator.clean(request.getParameter("role"));

        // ---------- validation ----------
        if (Validator.isEmpty(email) || Validator.isEmpty(password)) {
            fail(request, response, "Please enter both your email and your password.", email, role);
            return;
        }
        if (!Validator.isValidEmail(email)) {
            fail(request, response, "That does not look like a valid email address.", email, role);
            return;
        }

        // ---------- teacher login ----------
        if ("teacher".equalsIgnoreCase(role)) {
            TeacherBean teacher = teacherDAO.authenticate(email, password);
            if (teacher == null) {
                fail(request, response, "Wrong email or password for a teacher account.", email, role);
                return;
            }
            HttpSession session = freshSession(request);
            session.setAttribute("teacher", teacher);
            session.setAttribute("role", "teacher");
            response.sendRedirect(request.getContextPath() + "/teacherDashboard");
            return;
        }

        // ---------- student login ----------
        StudentBean student = studentDAO.authenticate(email, password);
        if (student == null) {
            fail(request, response, "Wrong email or password.", email, role);
            return;
        }
        HttpSession session = freshSession(request);
        session.setAttribute("student", student);
        session.setAttribute("role", "student");
        response.sendRedirect(request.getContextPath() + "/studentDashboard");
    }

    /** A new login must not inherit another account's role or quiz state. */
    private HttpSession freshSession(HttpServletRequest request) {
        HttpSession previous = request.getSession(false);
        if (previous != null) {
            previous.invalidate();
        }
        return request.getSession(true);
    }

    /** Sends the user back to the form with the message and the typed email. */
    private void fail(HttpServletRequest request, HttpServletResponse response,
                      String message, String email, String role)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.setAttribute("email", email);
        request.setAttribute("role", role);
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
}
