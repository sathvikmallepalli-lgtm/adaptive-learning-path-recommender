<%--
    Progress across the whole course plus the full attempt history.
--%>
<%@ page import="java.util.List" %>
<%@ page import="beans.ProgressBean" %>
<%@ page import="model.Attempt, model.TopicProgress" %>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Progress";
    String activePage = "progress";

    ProgressBean progress = (ProgressBean) request.getAttribute("progress");
    List<Attempt> history = (List<Attempt>) request.getAttribute("history");
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/studentNav.jsp" %>

<main class="content">

    <div class="page-head">
        <h1>Your progress</h1>
        <p class="sub">Best score per topic, and every attempt you have made.</p>
    </div>

    <!-- ---------- summary ---------- -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Course complete</div>
                <div class="stat-value"><%= progress.getOverallPercentage() %><small>%</small></div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Average score</div>
                <div class="stat-value"><%= progress.getAverageScore() %><small>%</small></div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Quizzes taken</div>
                <div class="stat-value"><%= progress.getTotalQuizAttempts() %></div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat is-gold">
                <div class="stat-label">Golden passed</div>
                <div class="stat-value"><%= progress.getGoldenPassedCount() %></div>
            </div>
        </div>
    </div>

    <!-- ---------- a bar per topic ---------- -->
    <div class="card-soft p-4 mb-4">
        <div class="stat-label mb-3">Topic by topic</div>

        <% for (TopicProgress t : progress.getTopics()) {
               String barColour = t.isGoldenPassed() ? "var(--gold)"
                                : t.getBestQuizScore() >= 50 ? "var(--jade)"
                                : t.isAttempted() ? "var(--coral)" : "var(--line)";
        %>
            <div class="mb-3">
                <div class="d-flex justify-content-between align-items-center mb-1 flex-wrap gap-2">
                    <div class="d-flex align-items-center gap-2">
                        <span class="figure-mono text-muted-2" style="font-size:12px;">
                            <%= (t.getTopicOrder() < 10 ? "0" : "") + t.getTopicOrder() %>
                        </span>
                        <span style="font-size:14.5px; font-weight:500;">
                            <%= Validator.escapeHtml(t.getTitle()) %>
                        </span>
                        <span class="pill <%= t.isAdvanced() ? "pill-advanced" : "pill-basic" %>">
                            <%= t.isAdvanced() ? "Advanced" : "Basic" %>
                        </span>
                        <% if (t.isGoldenPassed()) { %>
                            <span class="pill pill-gold">Golden passed</span>
                        <% } else if (t.isGoldenAttempted()) { %>
                            <span class="pill pill-idle">Golden attempted</span>
                        <% } %>
                    </div>
                    <div class="d-flex align-items-center gap-3">
                        <span class="text-muted-2" style="font-size:12.5px;">
                            <%= t.getQuizAttempts() %> attempt<%= t.getQuizAttempts() == 1 ? "" : "s" %>
                        </span>
                        <span class="figure-mono" style="font-size:14px; min-width:42px; text-align:right;">
                            <%= t.isUnlocked() ? t.getBestQuizScore() + "%" : "&mdash;" %>
                        </span>
                    </div>
                </div>
                <div class="progress" style="height:7px;">
                    <div class="progress-bar" role="progressbar"
                         style="width:<%= t.isUnlocked() ? t.getBestQuizScore() : 0 %>%; background:<%= barColour %>;"
                         aria-valuenow="<%= t.getBestQuizScore() %>"
                         aria-valuemin="0" aria-valuemax="100"
                         aria-label="<%= Validator.escapeHtml(t.getTitle()) %> best score"></div>
                </div>
            </div>
        <% } %>
    </div>

    <!-- ---------- full history ---------- -->
    <div class="card-soft">
        <div class="p-4 pb-2 d-flex justify-content-between align-items-center">
            <div class="stat-label mb-0">Every attempt</div>
            <span class="text-muted-2" style="font-size:12.5px;">
                <%= history == null ? 0 : history.size() %> in total
            </span>
        </div>

        <% if (history == null || history.isEmpty()) { %>
            <p class="text-muted-2 px-4 pb-4 mb-0" style="font-size:14px;">
                You have not taken a quiz yet.
                <a href="<%= request.getContextPath() %>/modules">Start with the first module.</a>
            </p>
        <% } else { %>
            <div class="table-wrap">
                <table class="table-clean">
                    <thead>
                        <tr><th>Topic</th><th>Type</th><th>Correct</th><th>Score</th><th>Date</th></tr>
                    </thead>
                    <tbody>
                    <% for (Attempt a : history) { %>
                        <tr>
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
