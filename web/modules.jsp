<%--
    The eight modules drawn as an actual path.

    The order of the topics is information the student needs, so the page
    draws a rail with a numbered node per topic instead of a plain grid of
    cards. The gold gate marks where the Golden Assessment stands between
    the basic and the advanced half of the course.
--%>
<%@ page import="java.util.List" %>
<%@ page import="beans.ProgressBean" %>
<%@ page import="model.TopicProgress" %>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Modules";
    String activePage = "modules";

    ProgressBean progress = (ProgressBean) request.getAttribute("progress");
    List<TopicProgress> path = progress.getTopics();
    String problem = request.getParameter("error");
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/studentNav.jsp" %>

<main class="content">

    <div class="page-head">
        <h1>Your learning path</h1>
        <p class="sub">
            Finish a topic to open the next one.
            <%= progress.getUnlockedTopics() %> of <%= progress.getTotalTopics() %> unlocked so far.
        </p>
    </div>

    <% if ("locked".equals(problem)) { %>
        <div class="alert alert-warning py-2" style="font-size:14px;">
            That topic is still locked. Finish the topic before it first.
        </div>
    <% } else if ("notfound".equals(problem)) { %>
        <div class="alert alert-danger py-2" style="font-size:14px;">
            That topic could not be found.
        </div>
    <% } else if ("expired".equals(problem)) { %>
        <div class="alert alert-warning py-2" style="font-size:14px;">
            That quiz is no longer open. Start it again from the topic page.
        </div>
    <% } %>

    <div class="row">
    <div class="col-xl-9">
    <div class="path">
        <%
            boolean gateDrawn = false;
            for (TopicProgress t : path) {

                // The gold gate is drawn once, right before the first
                // advanced topic - that is where the Golden Assessment sits.
                if (t.isAdvanced() && !gateDrawn) {
                    gateDrawn = true;
        %>
            <div class="path-gate">
                <strong>Golden Assessment gate.</strong>
                From here the topics are advanced. Each one opens only after you score
                above 80% on the topic before it and then pass its Golden Assessment
                &mdash; five hard questions, 60% to pass.
            </div>
        <%
                }

                String stepClass = "path-step";
                if (!t.isUnlocked()) {
                    stepClass += " is-locked";
                } else if (t.isGoldenPassed()) {
                    stepClass += " is-mastered";
                } else if (t.getBestQuizScore() >= 50) {
                    stepClass += " is-done";
                } else if (t.isAttempted()) {
                    stepClass += " is-current";
                }

                String number = (t.getTopicOrder() < 10 ? "0" : "") + t.getTopicOrder();
        %>

        <div class="<%= stepClass %>">
            <div class="path-node"><%= t.isUnlocked() ? number : "&#128274;" %></div>

            <% if (t.isUnlocked()) { %>
                <a class="topic-card" href="<%= request.getContextPath() %>/topic?id=<%= t.getTopicId() %>">
            <% } else { %>
                <div class="topic-card" aria-disabled="true">
            <% } %>

                <div class="d-flex justify-content-between align-items-start gap-3 flex-wrap">
                    <div style="min-width:0;">
                        <h2 class="topic-title"><%= Validator.escapeHtml(t.getTitle()) %></h2>
                        <p class="topic-desc">
                            <% if (!t.isUnlocked()) { %>
                                Locked &mdash; finish the topic before this one to open it.
                            <% } else if (!t.isAttempted()) { %>
                                Not started. Read the notes, practise, then take the quiz.
                            <% } else { %>
                                Best score <span class="figure-mono"><%= t.getBestQuizScore() %>%</span>
                                over <%= t.getQuizAttempts() %> attempt<%= t.getQuizAttempts() == 1 ? "" : "s" %>.
                            <% } %>
                        </p>
                    </div>

                    <div class="text-end flex-shrink-0">
                        <span class="pill <%= t.isAdvanced() ? "pill-advanced" : "pill-basic" %>">
                            <%= t.isAdvanced() ? "Advanced" : "Basic" %>
                        </span>
                        <div class="mt-2">
                            <span class="pill <%= !t.isUnlocked() ? "pill-idle"
                                                : t.isGoldenPassed() ? "pill-gold"
                                                : t.getBestQuizScore() >= 50 ? "pill-pass"
                                                : t.isAttempted() ? "pill-fail" : "pill-idle" %>">
                                <%= t.getStatus() %>
                            </span>
                        </div>
                    </div>
                </div>

                <% if (t.isUnlocked() && t.isAttempted()) { %>
                    <div class="progress mt-3" style="height:5px;">
                        <div class="progress-bar" role="progressbar"
                             style="width:<%= t.getBestQuizScore() %>%;
                                    background:<%= t.isGoldenPassed() ? "var(--gold)"
                                                 : t.getBestQuizScore() >= 50 ? "var(--jade)" : "var(--coral)" %>;"
                             aria-valuenow="<%= t.getBestQuizScore() %>"
                             aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                <% } %>

            <% if (t.isUnlocked()) { %>
                </a>
            <% } else { %>
                </div>
            <% } %>
        </div>
        <% } %>
    </div>
    </div>

    <!-- the key to the path, so the colours are never a guess -->
    <div class="col-xl-3">
        <div class="card-soft p-3" style="position:sticky; top:20px;">
            <div class="stat-label mb-3">Reading the path</div>
            <div class="d-flex align-items-center gap-2 mb-2" style="font-size:13px;">
                <span class="pill pill-idle">Locked</span> <span class="text-muted-2">not open yet</span>
            </div>
            <div class="d-flex align-items-center gap-2 mb-2" style="font-size:13px;">
                <span class="pill pill-fail">Needs revision</span> <span class="text-muted-2">below 50%</span>
            </div>
            <div class="d-flex align-items-center gap-2 mb-2" style="font-size:13px;">
                <span class="pill pill-pass">Completed</span> <span class="text-muted-2">50% or more</span>
            </div>
            <div class="d-flex align-items-center gap-2" style="font-size:13px;">
                <span class="pill pill-gold">Mastered</span> <span class="text-muted-2">Golden passed</span>
            </div>
        </div>
    </div>
    </div>

</main>
</div>
<%@ include file="/includes/foot.jsp" %>
