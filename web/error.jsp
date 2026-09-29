<%--
    Friendly replacement for the Tomcat stack trace page.
    Mapped to 404 and 500 in web.xml.
--%>
<%@ page isErrorPage="true" %>
<%
    String pageTitle = "Something went wrong";
    Object codeAttr = request.getAttribute("jakarta.servlet.error.status_code");
    String code = codeAttr == null ? "Error" : String.valueOf(codeAttr);
    boolean notFound = "404".equals(code);
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="entry">
    <section class="entry-art">
        <a class="brand mb-4" href="<%= request.getContextPath() %>/">
            <span class="brand-mark">A</span>
            <span>Adaptive<br>Learning</span>
        </a>
        <h1><%= notFound ? "That page does not exist." : "The server hit a problem." %></h1>
        <p>
            <%= notFound
                ? "The address may have been typed incorrectly, or the page may have moved."
                : "Check that MySQL is running and that the login details in DBConnection.java are correct." %>
        </p>
    </section>

    <section class="entry-form">
        <div class="inner text-center">
            <div class="card-soft p-4">
                <div class="stat-value mb-2"><%= code %></div>
                <p class="text-muted-2 mb-4" style="font-size:14px;">
                    Go back to a page you can reach from here.
                </p>
                <a class="btn btn-primary w-100 py-2" href="<%= request.getContextPath() %>/">Home</a>
                <a class="btn btn-link w-100 mt-1" href="<%= request.getContextPath() %>/login.jsp">Log in</a>
            </div>
        </div>
    </section>
</div>
<%@ include file="/includes/foot.jsp" %>
