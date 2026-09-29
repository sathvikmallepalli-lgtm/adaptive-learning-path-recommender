<%--
    Every quiz and Golden Assessment attempt made by every student.
--%>
<%@ page import="java.util.List" %>
<%@ page import="model.Attempt" %>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Student attempts";
    String activePage = "attempts";

    List<Attempt> attempts = (List<Attempt>) request.getAttribute("attempts");
    Integer quizCount = (Integer) request.getAttribute("quizCount");
    Integer goldenCount = (Integer) request.getAttribute("goldenCount");
    Integer averageScore = (Integer) request.getAttribute("averageScore");
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/teacherNav.jsp" %>

<main class="content">

    <div class="page-head">
        <h1>Student attempts</h1>
        <p class="sub">Newest first. Retakes appear as separate rows so nothing is lost.</p>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Total attempts</div>
                <div class="stat-value"><%= attempts.size() %></div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Quizzes</div>
                <div class="stat-value"><%= quizCount %></div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat is-gold">
                <div class="stat-label">Golden Assessments</div>
                <div class="stat-value"><%= goldenCount %></div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Average score</div>
                <div class="stat-value"><%= averageScore %><small>%</small></div>
            </div>
        </div>
    </div>

    <div class="card-soft">
        <% if (attempts.isEmpty()) { %>
            <p class="text-muted-2 p-4 mb-0" style="font-size:14px;">
                No student has taken a quiz yet.
            </p>
        <% } else { %>
            <div class="table-wrap">
                <table class="table-clean">
                    <thead>
                        <tr>
                            <th>Student</th><th>Topic</th><th>Type</th>
                            <th>Correct</th><th>Score</th><th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Attempt a : attempts) { %>
                        <tr>
                            <td style="font-weight:500;"><%= Validator.escapeHtml(a.getStudentName()) %></td>
                            <td><%= Validator.escapeHtml(a.getTopicTitle()) %></td>
                            <td>
                                <span class="pill <%= a.isGolden() ? "pill-gold" : "pill-idle" %>">
                                    <%= a.isGolden() ? "Golden" : "Quiz" %>
                                </span>
                            </td>
                            <td class="figure-mono"><%= a.getScoreFraction() %></td>
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

</main>
</div>
<%@ include file="/includes/foot.jsp" %>
