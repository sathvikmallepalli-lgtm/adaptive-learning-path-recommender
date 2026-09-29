<%--
    Student registration. RegisterServlet checks everything again on the
    server; app.js only makes the form friendlier.
--%>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Create your account";
    String error = (String) request.getAttribute("error");
    String name  = (String) request.getAttribute("name");
    String email = (String) request.getAttribute("email");
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="entry">

    <section class="entry-art">
        <a class="brand mb-4" href="<%= request.getContextPath() %>/">
            <span class="brand-mark">A</span>
            <span>Adaptive<br>Learning</span>
        </a>
        <h1>Start at Variables.<br>Finish at Modules.</h1>
        <p>
            Every topic gives you notes, practice questions and a ten question quiz.
            The quiz score decides what the platform asks you to do next.
        </p>

        <div class="rule-strip">
            <div class="rule-row"><span class="rule-key">01&ndash;04</span><span>Variables, Conditions, Loops, Functions</span></div>
            <div class="rule-row is-gold"><span class="rule-key">gate</span><span>Golden Assessment</span></div>
            <div class="rule-row"><span class="rule-key">05&ndash;08</span><span>OOP, Files, Exceptions, Modules</span></div>
        </div>
    </section>

    <section class="entry-form">
        <div class="inner">
            <h2 class="mb-1" style="font-size:24px;">Create a student account</h2>
            <p class="text-muted-2 mb-4" style="font-size:14px;">Teacher accounts are created by the department.</p>

            <% if (error != null) { %>
                <div class="alert alert-danger py-2" style="font-size:14px;">
                    <%= Validator.escapeHtml(error) %>
                </div>
            <% } %>

            <form id="registerForm" method="post" action="<%= request.getContextPath() %>/register">
                <div class="mb-3">
                    <label class="form-label" for="name">Full name</label>
                    <input type="text" class="form-control" id="name" name="name"
                           value="<%= name == null ? "" : Validator.escapeHtml(name) %>"
                           required minlength="2" maxlength="100" autofocus>
                </div>

                <div class="mb-3">
                    <label class="form-label" for="email">Email address</label>
                    <input type="email" class="form-control" id="email" name="email"
                           value="<%= email == null ? "" : Validator.escapeHtml(email) %>"
                           required maxlength="100">
                </div>

                <div class="mb-3">
                    <label class="form-label" for="password">Password</label>
                    <input type="password" class="form-control" id="password" name="password"
                           required minlength="6" autocomplete="new-password">
                    <div class="small text-muted-2 mt-1">At least 6 characters.</div>
                </div>

                <div class="mb-4">
                    <label class="form-label" for="confirmPassword">Confirm password</label>
                    <input type="password" class="form-control" id="confirmPassword"
                           name="confirmPassword" required autocomplete="new-password">
                    <div id="passwordNote"></div>
                </div>

                <button type="submit" class="btn btn-primary w-100 py-2">Create account</button>
            </form>

            <p class="text-center mt-3 mb-0" style="font-size:14px;">
                Already registered?
                <a href="<%= request.getContextPath() %>/login.jsp">Log in</a>
            </p>
        </div>
    </section>
</div>
<%@ include file="/includes/foot.jsp" %>
