<%--
    Everything the rule engine has advised, for every student.
    This screen is the evidence that the adaptive path is driven by the rules.
--%>
<%@ page import="java.util.List" %>
<%@ page import="beans.RecommendationBean" %>
<%@ page import="engine.RuleConstants" %>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Recommendations";
    String activePage = "recommendations";

    List<RecommendationBean> recommendations =
            (List<RecommendationBean>) request.getAttribute("recommendations");
    Integer pendingCount = (Integer) request.getAttribute("pendingCount");
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/teacherNav.jsp" %>

<main class="content">

    <div class="page-head">
        <h1>Recommendations</h1>
        <p class="sub">Produced automatically by the rule engine after every attempt.</p>
    </div>

    <!-- the rules stated in the open, so nothing about the engine is hidden -->
    <div class="card-soft p-4 mb-3">
        <div class="stat-label mb-3">The rules being applied</div>
        <div class="row g-2">
            <div class="col-md-6">
                <div class="rule-row" style="color:var(--muted); padding:5px 0;">
                    <span class="rule-key" style="background:var(--coral-dim); color:#b3303c;">
                        &lt; <%= RuleConstants.LOW_SCORE %>%</span>
                    <span style="font-size:13px;">Revision, practice, retake the quiz</span>
                </div>
                <div class="rule-row" style="color:var(--muted); padding:5px 0;">
                    <span class="rule-key" style="background:var(--jade-dim); color:#1a7d4d;">
                        <%= RuleConstants.LOW_SCORE %>&ndash;<%= RuleConstants.HIGH_SCORE %>%</span>
                    <span style="font-size:13px;">Move to the next topic</span>
                </div>
            </div>
            <div class="col-md-6">
                <div class="rule-row" style="color:var(--muted); padding:5px 0;">
                    <span class="rule-key" style="background:var(--gold-dim); color:var(--gold-deep);">
                        &gt; <%= RuleConstants.HIGH_SCORE %>%</span>
                    <span style="font-size:13px;">Golden Assessment opens</span>
                </div>
                <div class="rule-row" style="color:var(--muted); padding:5px 0;">
                    <span class="rule-key" style="background:var(--gold-dim); color:var(--gold-deep);">
                        golden <%= RuleConstants.GOLDEN_PASS_SCORE %>%</span>
                    <span style="font-size:13px;">Pass unlocks the advanced topic, fail gives advanced practice</span>
                </div>
            </div>
        </div>
    </div>

    <div class="card-soft">
        <div class="p-4 pb-2 d-flex justify-content-between align-items-center">
            <div class="stat-label mb-0">All recommendations</div>
            <div class="d-flex gap-2">
                <span class="pill pill-idle">Pending <%= pendingCount %></span>
                <span class="pill pill-pass">Completed <%= recommendations.size() - pendingCount.intValue() %></span>
            </div>
        </div>

        <% if (recommendations.isEmpty()) { %>
            <p class="text-muted-2 px-4 pb-4 mb-0" style="font-size:14px;">
                Nothing yet. Recommendations appear as soon as a student submits a quiz.
            </p>
        <% } else { %>
            <div class="table-wrap">
                <table class="table-clean">
                    <thead>
                        <tr>
                            <th>Student</th><th>Topic</th><th>Rule that fired</th>
                            <th>Advice given</th><th>Status</th><th>When</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (RecommendationBean r : recommendations) { %>
                        <tr>
                            <td style="font-weight:500;"><%= Validator.escapeHtml(r.getStudentName()) %></td>
                            <td><%= Validator.escapeHtml(r.getTopicTitle()) %></td>
                            <td>
                                <span class="pill pill-<%= r.getColour().equals("warning") ? "gold"
                                                          : r.getColour().equals("success") ? "pass"
                                                          : r.getColour().equals("info") ? "basic" : "fail" %>">
                                    <%= Validator.escapeHtml(r.getTypeLabel()) %>
                                </span>
                            </td>
                            <td style="max-width:400px; font-size:13.5px;">
                                <%= Validator.escapeHtml(r.getRecommendation()) %>
                            </td>
                            <td>
                                <span class="pill <%= r.isPending() ? "pill-idle" : "pill-pass" %>">
                                    <%= Validator.escapeHtml(r.getStatus()) %>
                                </span>
                            </td>
                            <td class="text-muted-2" style="font-size:12.5px; white-space:nowrap;">
                                <%= r.getCreatedDate() == null ? "" : r.getCreatedDate().toString().substring(0, 16) %>
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
