<%--
    Shown after LogoutServlet has destroyed the session.
    This page must stay public, otherwise the filter would send a logged
    out user straight back to the login page and the confirmation would
    never be seen.
--%>
<% String pageTitle = "Logged out"; %>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="entry">
    <section class="entry-art">
        <a class="brand mb-4" href="<%= request.getContextPath() %>/">
            <span class="brand-mark">A</span>
            <span>Adaptive<br>Learning</span>
        </a>
        <h1>You are logged out.</h1>
        <p>Your session was destroyed. Nothing from it stays in the browser.</p>
    </section>

    <section class="entry-form">
        <div class="inner text-center">
            <div class="card-soft p-4">
                <h2 style="font-size:20px;" class="mb-2">See you next time</h2>
                <p class="text-muted-2 mb-4" style="font-size:14px;">
                    Your progress is saved. Log in again to continue where you stopped.
                </p>
                <a class="btn btn-primary w-100 py-2" href="<%= request.getContextPath() %>/login.jsp">Log in again</a>
                <a class="btn btn-link w-100 mt-1" href="<%= request.getContextPath() %>/">Back to the home page</a>
            </div>
        </div>
    </section>
</div>
<%@ include file="/includes/foot.jsp" %>
