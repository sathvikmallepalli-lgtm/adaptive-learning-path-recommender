<%--
    Login for both roles. The role radio decides which DAO the servlet asks.
    Any error message is put here by LoginServlet.
--%>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Log in";
    String error = (String) request.getAttribute("error");
    String email = (String) request.getAttribute("email");
    String role  = (String) request.getAttribute("role");
    if (role == null || role.isEmpty()) { role = "student"; }
    boolean justRegistered = "1".equals(request.getParameter("registered"));
    boolean sessionEnded   = "session".equals(request.getParameter("error"));
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="entry">

    <section class="entry-art">
        <a class="brand mb-4" href="<%= request.getContextPath() %>/">
            <span class="brand-mark">A</span>
            <span>Adaptive<br>Learning</span>
        </a>
        <h1>Welcome back.</h1>
        <p>Your path picks up exactly where your last quiz left it.</p>

        <div class="rule-strip">
            <div class="stat-label" style="color:#6f748f;">Demo accounts</div>
            <div class="rule-row">
                <span class="rule-key">student</span>
                <button type="button" class="btn btn-sm btn-outline-light py-0 px-2"
                        style="font-size:12px;"
                        data-demo-email="rahul@student.edu"
                        data-demo-password="student123"
                        data-demo-role="student">Use rahul@student.edu</button>
            </div>
            <div class="rule-row">
                <span class="rule-key">teacher</span>
                <button type="button" class="btn btn-sm btn-outline-light py-0 px-2"
                        style="font-size:12px;"
                        data-demo-email="anita.rao@college.edu"
                        data-demo-password="teacher123"
                        data-demo-role="teacher">Use anita.rao@college.edu</button>
            </div>
        </div>
    </section>

    <section class="entry-form">
        <div class="inner">
            <h2 class="mb-1" style="font-size:24px;">Log in</h2>
            <p class="text-muted-2 mb-4" style="font-size:14px;">Choose your role, then enter your details.</p>

            <% if (justRegistered) { %>
                <div class="alert alert-success py-2" style="font-size:14px;">
                    Your account is ready. Log in to start the first module.
                </div>
            <% } %>
            <% if (sessionEnded) { %>
                <div class="alert alert-warning py-2" style="font-size:14px;">
                    Your session ended. Please log in again.
                </div>
            <% } %>
            <% if (error != null) { %>
                <div class="alert alert-danger py-2" style="font-size:14px;">
                    <%= Validator.escapeHtml(error) %>
                </div>
            <% } %>

            <form id="loginForm" method="post" action="<%= request.getContextPath() %>/login">
                <div class="mb-3">
                    <label class="form-label">I am a</label>
                    <div class="role-pick">
                        <input type="radio" name="role" id="roleStudent" value="student"
                               <%= "teacher".equals(role) ? "" : "checked" %>>
                        <label for="roleStudent">Student</label>

                        <input type="radio" name="role" id="roleTeacher" value="teacher"
                               <%= "teacher".equals(role) ? "checked" : "" %>>
                        <label for="roleTeacher">Teacher</label>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label" for="email">Email address</label>
                    <input type="email" class="form-control" id="email" name="email"
                           value="<%= email == null ? "" : Validator.escapeHtml(email) %>"
                           required autocomplete="username" autofocus>
                </div>

                <div class="mb-4">
                    <label class="form-label" for="password">Password</label>
                    <input type="password" class="form-control" id="password" name="password"
                           required autocomplete="current-password">
                </div>

                <button type="submit" class="btn btn-primary w-100 py-2">Log in</button>
            </form>

            <p class="text-center mt-3 mb-0" style="font-size:14px;">
                No account yet?
                <a href="<%= request.getContextPath() %>/register.jsp">Create one</a>
            </p>
        </div>
    </section>
</div>
<%@ include file="/includes/foot.jsp" %>
