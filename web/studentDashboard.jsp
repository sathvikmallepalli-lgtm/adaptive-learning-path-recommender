<%--
    Student home screen.
    Everything on this page was prepared by StudentDashboardServlet - the
    JSP only reads request attributes and prints them.
--%>
<%@ page import="java.util.List" %>
<%@ page import="beans.ProgressBean, beans.RecommendationBean, beans.StudentBean" %>
<%@ page import="model.Attempt, model.TopicProgress" %>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Dashboard";
    String activePage = "dashboard";

    StudentBean student = (StudentBean) session.getAttribute("student");
    ProgressBean progress = (ProgressBean) request.getAttribute("progress");
    RecommendationBean latest = (RecommendationBean) request.getAttribute("latestRecommendation");
    List<Attempt> recent = (List<Attempt>) request.getAttribute("recentAttempts");
    TopicProgress current = progress == null ? null : progress.getCurrentTopic();
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/studentNav.jsp" %>

<main class="content">

    <div class="page-head">
        <h1>Hello, <%= Validator.escapeHtml(student.getFirstName()) %></h1>
        <p class="sub">Here is where your learning path stands today.</p>
    </div>

    <!-- ---------- the four numbers ---------- -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Course complete</div>
                <div class="stat-value"><%= progress.getOverallPercentage() %><small>%</small></div>
                <div class="progress mt-2" style="height:5px;">
                    <div class="progress-bar" role="progressbar"
                         style="width:<%= progress.getOverallPercentage() %>%; background:var(--accent);"
                         aria-valuenow="<%= progress.getOverallPercentage() %>"
                         aria-valuemin="0" aria-valuemax="100"></div>
                </div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Topics done</div>
                <div class="stat-value"><%= progress.getCompletedTopics() %><small> / <%= progress.getTotalTopics() %></small></div>
                <div class="text-muted-2 mt-2" style="font-size:12.5px;"><%= progress.getUnlockedTopics() %> unlocked</div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat">
                <div class="stat-label">Average score</div>
                <div class="stat-value"><%= progress.getAverageScore() %><small>%</small></div>
                <div class="text-muted-2 mt-2" style="font-size:12.5px;"><%= progress.getTotalQuizAttempts() %> quizzes taken</div>
            </div>
        </div>
        <div class="col-6 col-lg-3">
            <div class="stat is-gold">
                <div class="stat-label">Golden passed</div>
                <div class="stat-value"><%= progress.getGoldenPassedCount() %></div>
                <div class="text-muted-2 mt-2" style="font-size:12.5px;">unlocks advanced topics</div>
            </div>
        </div>
    </div>

    <div class="row g-3">

        <!-- ---------- what to do next ---------- -->
        <div class="col-lg-7">
            <div class="card-soft p-4 h-100">
                <div class="stat-label mb-3">What to do next</div>

                <% if (current == null) { %>
                    <h2 style="font-size:19px;" class="mb-2">Course complete</h2>
                    <p class="text-muted-2 mb-4" style="font-size:14.5px;">
                        You have completed every topic in the learning path. Review your progress
                        or revisit a module whenever you want to practise.
                    </p>
                    <a class="btn btn-primary" href="<%= request.getContextPath() %>/progress">View your progress</a>

                <% } else { %>
                    <h2 style="font-size:19px;" class="mb-2"><%= Validator.escapeHtml(current.getTitle()) %></h2>
                    <p style="font-size:15px; line-height:1.6;" class="mb-4">
                        <% if (!current.isAttempted()) { %>
                            Read the notes, try the practice questions, then take the quiz.
                        <% } else if (current.getBestQuizScore() < 50) { %>
                            Your best quiz score is <%= current.getBestQuizScore() %>%. Revise the notes and practice before retaking the quiz.
                        <% } else if (current.getBestQuizScore() <= 80) { %>
                            The next advanced topic needs a Golden pass. Retake this quiz and score above 80% to open the Golden Assessment.
                        <% } else if (current.isGoldenAttempted()) { %>
                            Your quiz score opened the Golden Assessment. Practise the harder questions, then try it again to unlock the next topic.
                        <% } else { %>
                            Your quiz score opened the Golden Assessment. Pass it to unlock the next advanced topic.
                        <% } %>
                    </p>
                    <a class="btn btn-primary" href="<%= request.getContextPath() %>/topic?id=<%= current.getTopicId() %>">
                        Open <%= Validator.escapeHtml(current.getTitle()) %>
                    </a>
                <% } %>
                <% if (latest != null) { %>
                    <div class="mt-4 pt-3 border-top" style="font-size:13.5px;">
                        <div class="stat-label mb-1">Latest result</div>
                        <span class="text-muted-2"><%= Validator.escapeHtml(latest.getTypeLabel()) %> on <%= Validator.escapeHtml(latest.getTopicTitle()) %>.</span>
                        <a class="ms-1" href="<%= request.getContextPath() %>/recommendation">Read the advice</a>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- ---------- recent attempts ---------- -->
        <div class="col-lg-5">
            <div class="card-soft h-100">
                <div class="p-4 pb-2">
                    <div class="stat-label">Recent attempts</div>
                </div>

                <% if (recent == null || recent.isEmpty()) { %>
                    <p class="text-muted-2 px-4 pb-4 mb-0" style="font-size:14px;">
                        Nothing here yet. Your quiz results will appear as you take them.
                    </p>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="table-clean">
                            <thead>
                                <tr><th>Topic</th><th>Type</th><th class="text-end">Score</th></tr>
                            </thead>
                            <tbody>
                            <% for (Attempt a : recent) { %>
                                <tr>
                                    <td><%= Validator.escapeHtml(a.getTopicTitle()) %></td>
                                    <td>
                                        <span class="pill <%= a.isGolden() ? "pill-gold" : "pill-idle" %>">
                                            <%= a.isGolden() ? "Golden" : "Quiz" %>
                                        </span>
                                    </td>
                                    <td class="text-end">
                                        <span class="figure-mono"><%= a.getScore() %>%</span>
                                        <div class="text-muted-2" style="font-size:11.5px;"><%= a.getScoreFraction() %></div>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div class="px-4 py-3">
                        <a href="<%= request.getContextPath() %>/progress" style="font-size:13.5px;">See the full history</a>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

</main>
</div>
<%@ include file="/includes/foot.jsp" %>
