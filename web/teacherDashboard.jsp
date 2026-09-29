<%--
    Teacher home screen: totals for the whole class and the latest activity.
--%>
<%@ page import="java.util.List" %>
<%@ page import="beans.TeacherBean" %>
<%@ page import="model.Attempt" %>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Teacher dashboard";
    String activePage = "dashboard";

    TeacherBean teacher = (TeacherBean) session.getAttribute("teacher");
    Integer studentCount = (Integer) request.getAttribute("studentCount");
    Integer topicCount = (Integer) request.getAttribute("topicCount");
    Integer attemptCount = (Integer) request.getAttribute("attemptCount");
    Integer recommendationCount = (Integer) request.getAttribute("recommendationCount");
    Integer goldenAttempts = (Integer) request.getAttribute("goldenAttempts");
    Integer goldenPassed = (Integer) request.getAttribute("goldenPassed");
    List<Attempt> recent = (List<Attempt>) request.getAttribute("recentAttempts");
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/teacherNav.jsp" %>

<main class="content">

    <div class="page-head">
        <h1>Hello, <%= Validator.escapeHtml(teacher.getFirstName()) %></h1>
        <p class="sub">Course activity across every student.</p>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Students</div>
                <div class="stat-value"><%= studentCount %></div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Topics</div>
                <div class="stat-value"><%= topicCount %></div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Attempts</div>
                <div class="stat-value"><%= attemptCount %></div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat is-gold">
                <div class="stat-label">Golden passed</div>
                <div class="stat-value">
                    <%= goldenPassed %><small> / <%= goldenAttempts %></small>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-3">
        <div class="col-lg-4">
            <div class="card-soft p-4 h-100">
                <div class="stat-label mb-3">Manage the course</div>
                <a class="btn btn-primary w-100 mb-2" href="<%= request.getContextPath() %>/manageTopics">
                    Topics
                </a>
                <a class="btn btn-outline-secondary w-100 mb-2" href="<%= request.getContextPath() %>/manageQuestions">
                    Questions
                </a>
                <a class="btn btn-outline-secondary w-100 mb-2" href="<%= request.getContextPath() %>/viewAttempts">
                    Student attempts
                </a>
                <a class="btn btn-outline-secondary w-100" href="<%= request.getContextPath() %>/viewRecommendations">
                    Recommendations (<%= recommendationCount %>)
                </a>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card-soft h-100">
                <div class="p-4 pb-2 d-flex justify-content-between align-items-center">
                    <div class="stat-label mb-0">Latest attempts</div>
                    <a href="<%= request.getContextPath() %>/viewAttempts" style="font-size:13px;">See all</a>
                </div>

                <% if (recent == null || recent.isEmpty()) { %>
                    <p class="text-muted-2 px-4 pb-4 mb-0" style="font-size:14px;">
                        No student has taken a quiz yet.
                    </p>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="table-clean">
                            <thead>
                                <tr><th>Student</th><th>Topic</th><th>Type</th><th>Score</th><th>When</th></tr>
                            </thead>
                            <tbody>
                            <% for (Attempt a : recent) { %>
                                <tr>
                                    <td><%= Validator.escapeHtml(a.getStudentName()) %></td>
                                    <td><%= Validator.escapeHtml(a.getTopicTitle()) %></td>
                                    <td>
                                        <span class="pill <%= a.isGolden() ? "pill-gold" : "pill-idle" %>">
                                            <%= a.isGolden() ? "Golden" : "Quiz" %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="pill <%= a.getScore() >= 50 ? "pill-pass" : "pill-fail" %>">
                                            <%= a.getScore() %>%
                                        </span>
                                    </td>
                                    <td class="text-muted-2" style="font-size:12.5px; white-space:nowrap;">
                                        <%= a.getAttemptDate() == null ? "" : a.getAttemptDate().toString().substring(0, 16) %>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

</main>
</div>
<%@ include file="/includes/foot.jsp" %>
