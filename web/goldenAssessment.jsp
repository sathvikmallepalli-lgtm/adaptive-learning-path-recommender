<%--
    THE GOLDEN ASSESSMENT.

    Same mechanics as the quiz, but only five questions and a different
    rule at the end. The page is deliberately dressed in gold so it is
    obvious that this is the special step, not another quiz.
--%>
<%@ page import="beans.QuizBean, beans.QuestionBean, beans.TopicBean" %>
<%@ page import="engine.RuleConstants" %>
<%@ page import="util.Validator" %>
<%
    QuizBean quiz = (QuizBean) request.getAttribute("quiz");
    TopicBean topic = (TopicBean) request.getAttribute("topic");

    String pageTitle = topic.getTitle() + " Golden Assessment";
    String activePage = "modules";
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/studentNav.jsp" %>

<main class="content">

    <div class="page-head">
        <a href="<%= request.getContextPath() %>/topic?id=<%= topic.getTopicId() %>" style="font-size:13px;">
            &larr; Back to <%= Validator.escapeHtml(topic.getTitle()) %>
        </a>
    </div>

    <div class="row">
    <div class="col-xl-9">

        <div class="golden-banner mb-4">
            <h2>Golden Assessment &middot; <%= Validator.escapeHtml(topic.getTitle()) %></h2>
            <p>
                You earned this by scoring above <%= RuleConstants.HIGH_SCORE %>% in the quiz.
                <%= RuleConstants.GOLDEN_QUESTION_COUNT %> hard questions,
                <%= RuleConstants.GOLDEN_PASS_SCORE %>% to pass. Pass and the advanced topic
                opens. Fall short and you get advanced practice, then another attempt.
            </p>
        </div>

        <div class="quiz-progress">
            <div class="d-flex justify-content-between mb-2" style="font-size:13px;">
                <span class="stat-label mb-0">Answered</span>
                <span class="figure-mono" id="quizAnswered">0 of <%= quiz.getQuestionCount() %></span>
            </div>
            <div class="quiz-bar gold"><span id="quizBarFill"></span></div>
        </div>

        <form id="quizForm" method="post" action="<%= request.getContextPath() %>/golden">
            <%
                int n = 0;
                for (QuestionBean q : quiz.getQuestions()) {
                    n++;
            %>
            <div class="q-card gold">
                <div class="q-number">Golden question <%= n %> of <%= quiz.getQuestionCount() %></div>
                <div class="q-text"><%= Validator.escapeHtml(q.getQuestion()) %></div>

                <%
                    String[] letters = {"A", "B", "C", "D"};
                    for (String L : letters) {
                        String inputId = "g" + q.getQuestionId() + L;
                %>
                    <label class="opt" for="<%= inputId %>">
                        <input type="radio" id="<%= inputId %>"
                               name="q<%= q.getQuestionId() %>" value="<%= L %>">
                        <span class="letter"><%= L %></span>
                        <span><%= Validator.escapeHtml(q.getOption(L)) %></span>
                    </label>
                <% } %>
            </div>
            <% } %>

            <div class="card-soft p-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                <div class="text-muted-2" style="font-size:13.5px;">
                    <%= RuleConstants.GOLDEN_PASS_SCORE %>% of
                    <%= RuleConstants.GOLDEN_QUESTION_COUNT %> questions
                    means <%= (RuleConstants.GOLDEN_QUESTION_COUNT * RuleConstants.GOLDEN_PASS_SCORE) / 100 %> correct.
                </div>
                <button type="submit" class="btn btn-gold px-4 py-2" id="quizSubmit">
                    Submit the Golden Assessment
                </button>
            </div>
        </form>
    </div>

    <div class="col-xl-3">
        <div class="card-soft p-3" style="position:sticky; top:20px;">
            <div class="stat-label mb-2">What happens next</div>
            <div class="rule-row" style="color:var(--muted); padding:6px 0;">
                <span class="rule-key" style="background:var(--gold-dim); color:var(--gold-deep);">pass</span>
                <span style="font-size:13px;">The advanced topic unlocks</span>
            </div>
            <div class="rule-row" style="color:var(--muted); padding:6px 0;">
                <span class="rule-key" style="background:#eef0f6; color:var(--muted);">fail</span>
                <span style="font-size:13px;">Advanced practice, then try again</span>
            </div>
            <hr>
            <p class="text-muted-2 mb-0" style="font-size:13px;">
                Your quiz score for this topic is already saved. Nothing here can lower it.
            </p>
        </div>
    </div>
    </div>

</main>
</div>
<%@ include file="/includes/foot.jsp" %>
