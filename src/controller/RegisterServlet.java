package controller;

import java.io.IOException;

import beans.StudentBean;
import dao.StudentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.PasswordUtil;
import util.Validator;

/**
 * Student registration.
 *
 * Every field is checked on the server even though register.js checks them
 * in the browser first - browser checks can be switched off.
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final StudentDAO studentDAO = new StudentDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = Validator.clean(request.getParameter("name"));
        String email = Validator.clean(request.getParameter("email"));
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        // ---------- validation ----------
        if (!Validator.isValidName(name)) {
            fail(request, response, "Please enter your full name (at least 2 characters).", name, email);
            return;
        }
        if (!Validator.isValidEmail(email)) {
            fail(request, response, "Please enter a valid email address.", name, email);
            return;
        }
        if (!Validator.isValidPassword(password)) {
            fail(request, response, "The password must be at least "
                 + Validator.MIN_PASSWORD_LENGTH + " characters long.", name, email);
            return;
        }
        if (!password.equals(confirm)) {
            fail(request, response, "The two passwords do not match.", name, email);
            return;
        }
        if (studentDAO.emailExists(email)) {
            fail(request, response, "That email address is already registered. Please log in.", name, email);
            return;
        }

        // ---------- save ----------
        StudentBean student = new StudentBean(name, email, PasswordUtil.hash(password));
        int id = studentDAO.register(student);

        if (id <= 0) {
            fail(request, response, "Registration failed. Please try again.", name, email);
            return;
        }

        // Send them to the login page with a success message rather than
        // logging them in automatically - it confirms the account exists.
        response.sendRedirect(request.getContextPath() + "/login.jsp?registered=1");
    }

    private void fail(HttpServletRequest request, HttpServletResponse response,
                      String message, String name, String email)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.setAttribute("name", name);
        request.setAttribute("email", email);
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }
}
