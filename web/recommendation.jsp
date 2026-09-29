<%--
    What the rule engine decided, and the history of everything it has ever
    advised this student.

    The result object was put in the session by QuizServlet or by
    GoldenAssessmentServlet. If the page is opened directly there is no
    fresh result, so only the history is shown.
--%>
<%@ page import="java.util.List" %>
<%@ page import="beans.QuizBean, beans.RecommendationBean" %>
<%@ page import="model.RuleResult" %>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Recommendation";
    String activePage = "recommendation";

    RuleResult result = (RuleResult) request.getAttribute("result");
    QuizBean lastQuiz = (QuizBean) request.getAttribute("lastQuiz");
    List<RecommendationBean> history = (List<RecommendationBean>) request.getAttribute("history");

    // Which colour the score ring should use
    String ringColour = "var(--accent)";
    if (result != null) {
        if ("warning".equals(result.getColour()))      { ringColour = "var(--gold)"; }
        else if ("success".equals(result.getColour())) { ringColour = "var(--jade)"; }
        else if ("danger".equals(result.getColour()))  { ringColour = "var(--coral)"; }
    }
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/studentNav.jsp" %>

<main class="content">

    <div class="page-head">
        <h1>Recommendation</h1>
        <p class="sub">Decided by the rules, from the score you just got.</p>
    </div>

    <% if (result != null && lastQuiz != null) { %>
        <!-- ---------- the fresh result ---------- -->
        <div class="card-soft p-4 mb-4">
            <div class="row align-items-center g-4">

                <div class="col-md-auto text-center">
                    <div class="score-ring" id="scoreRing"
                         data-score="<%= lastQuiz.getScore() %>"
                         style="--ring-colour: <%= ringColour %>; --pct: 0;">
                        <div>
                            <div class="score-value"><%= lastQuiz.getScore() %>%</div>
                            <div class="score-sub"><%= lastQuiz.getScoreFraction() %></div>
                        </div>
                    </div>
                    <div class="mt-2">
                        <span class="pill <%= lastQuiz.isGolden() ? "pill-gold" : "pill-idle" %>">
                            <%= lastQuiz.isGolden() ? "Golden Assessment" : "Topic quiz" %>
                        </span>
                    </div>
                </div>

                <div class="col-md">
                    <div class="stat-label mb-2">
                        <%= Validator.escapeHtml(lastQuiz.getTopicTitle()) %>
                    </div>
                    <h2 style="font-size:22px;" class="mb-2">
                        <%= Validator.escapeHtml(result.getHeadline()) %>
                    </h2>
                    <p style="font-size:15px; line-height:1.62;" class="mb-3">
                        <%= Validator.escapeHtml(result.getMessage()) %>
                    </p>

                    <!-- The action button depends on the rule that fired -->
                    <div class="d-flex gap-2 flex-wrap">
                        <% String ctxp = request.getContextPath();
                           String type = result.getType();

                           if (RuleResult.GOLDEN_ASSESSMENT.equals(type)) { %>
                            <a class="btn btn-gold px-4"
                               href="<%= ctxp %>/golden?topicId=<%= lastQuiz.getTopicId() %>">
                                Start the Golden Assessment
                            </a>
                            <% if (result.isNextTopicUnlocked() && result.getNextTopicId() > 0) { %>
                                <a class="btn btn-primary px-4"
                                   href="<%= ctxp %>/topic?id=<%= result.getNextTopicId() %>">
                                    Continue with <%= Validator.escapeHtml(result.getNextTopicTitle()) %>
                                </a>
                            <% } %>
                            <a class="btn btn-outline-secondary"
                               href="<%= ctxp %>/topic?id=<%= lastQuiz.getTopicId() %>">Back to the topic</a>

                        <% } else if (RuleResult.UNLOCK_ADVANCED.equals(type)) { %>
                            <% if (result.getNextTopicId() > 0) { %>
                                <a class="btn btn-primary px-4"
                                   href="<%= ctxp %>/topic?id=<%= result.getNextTopicId() %>">
                                    Open <%= Validator.escapeHtml(result.getNextTopicTitle()) %>
                                </a>
                            <% } %>
                            <a class="btn btn-outline-secondary" href="<%= ctxp %>/modules">See the path</a>

                        <% } else if (RuleResult.ADVANCED_PRACTICE.equals(type)) { %>
                            <a class="btn btn-primary px-4"
                               href="<%= ctxp %>/topic?id=<%= lastQuiz.getTopicId() %>#advancedPractice">
                                Go to advanced practice
                            </a>
                            <a class="btn btn-gold"
                               href="<%= ctxp %>/golden?topicId=<%= lastQuiz.getTopicId() %>">
                                Try the Golden Assessment again
                            </a>

                        <% } else if (RuleResult.NEXT_TOPIC.equals(type)) { %>
                            <% if (result.isNextTopicUnlocked() && result.getNextTopicId() > 0) { %>
                                <a class="btn btn-primary px-4"
                                   href="<%= ctxp %>/topic?id=<%= result.getNextTopicId() %>">
                                    Continue with <%= Validator.escapeHtml(result.getNextTopicTitle()) %>
                                </a>
                            <% } else { %>
                                <a class="btn btn-primary px-4"
                                   href="<%= ctxp %>/quiz?topicId=<%= lastQuiz.getTopicId() %>">
                                    Retake the quiz for a higher score
                                </a>
                            <% } %>
                            <a class="btn btn-outline-secondary" href="<%= ctxp %>/modules">See the path</a>

                        <% } else { %>
                            <a class="btn btn-primary px-4"
                               href="<%= ctxp %>/topic?id=<%= lastQuiz.getTopicId() %>">
                                Read the notes again
                            </a>
                            <a class="btn btn-outline-secondary"
                               href="<%= ctxp %>/quiz?topicId=<%= lastQuiz.getTopicId() %>">
                                Retake the quiz
                            </a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    <% } else { %>
        <div class="card-soft p-4 mb-4">
            <h2 style="font-size:19px;" class="mb-2">No new result</h2>
            <p class="text-muted-2 mb-3" style="font-size:14.5px;">
                Take a quiz and the rule engine will decide your next step. Everything it
                has advised before is listed below.
            </p>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/modules">Go to the modules</a>
        </div>
    <% } %>

    <!-- ---------- history ---------- -->
    <div class="card-soft">
        <div class="p-4 pb-2 d-flex justify-content-between align-items-center">
            <div class="stat-label mb-0">Everything advised so far</div>
            <span class="text-muted-2" style="font-size:12.5px;">
                <%= history == null ? 0 : history.size() %> in total
            </span>
        </div>

        <% if (history == null || history.isEmpty()) { %>
            <p class="text-muted-2 px-4 pb-4 mb-0" style="font-size:14px;">
                Nothing yet. Your first recommendation appears after your first quiz.
            </p>
        <% } else { %>
            <div class="table-wrap">
                <table class="table-clean">
                    <thead>
                        <tr>
                            <th>Topic</th><th>Recommendation</th><th>Advice</th>
                            <th>When</th><th>Status</th><th></th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (RecommendationBean r : history) { %>
                        <tr>
                            <td><%= Validator.escapeHtml(r.getTopicTitle()) %></td>
                            <td>
                                <span class="pill pill-<%= r.getColour().equals("warning") ? "gold"
                                                          : r.getColour().equals("success") ? "pass"
                                                          : r.getColour().equals("info") ? "basic" : "fail" %>">
                                    <%= Validator.escapeHtml(r.getTypeLabel()) %>
                                </span>
                            </td>
                            <td style="max-width:420px;"><%= Validator.escapeHtml(r.getRecommendation()) %></td>
                            <td class="text-muted-2" style="font-size:12.5px; white-space:nowrap;">
                                <%= r.getCreatedDate() == null ? "" : r.getCreatedDate().toString().substring(0, 16) %>
                            </td>
                            <td>
                                <span class="pill <%= r.isPending() ? "pill-idle" : "pill-pass" %>">
                                    <%= Validator.escapeHtml(r.getStatus()) %>
                                </span>
                            </td>
                            <td class="text-end">
                                <% if (r.isPending()) { %>
                                    <form method="post" action="<%= request.getContextPath() %>/recommendation"
                                          style="display:inline;">
                                        <input type="hidden" name="action" value="complete">
                                        <input type="hidden" name="recommendationId"
                                               value="<%= r.getRecommendationId() %>">
                                        <button type="submit" class="btn btn-sm btn-outline-secondary"
                                                style="font-size:12px;">Mark done</button>
                                    </form>
                                <% } %>
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
