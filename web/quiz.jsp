<%--
    The ten question topic quiz.

    The correct answers are NOT sent to the browser. The QuizBean holding
    them stays in the session on the server, and QuizServlet grades the
    submission against it.
--%>
<%@ page import="beans.QuizBean, beans.QuestionBean, beans.TopicBean" %>
<%@ page import="util.Validator" %>
<%
    QuizBean quiz = (QuizBean) request.getAttribute("quiz");
    TopicBean topic = (TopicBean) request.getAttribute("topic");

    String pageTitle = topic.getTitle() + " quiz";
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
        <h1 class="mt-2"><%= Validator.escapeHtml(topic.getTitle()) %> quiz</h1>
        <p class="sub">
            <%= quiz.getQuestionCount() %> questions. Anything you leave blank counts as wrong.
        </p>
    </div>

    <div class="row">
    <div class="col-xl-9">

        <!-- progress bar that fills as questions are answered -->
        <div class="quiz-progress">
            <div class="d-flex justify-content-between mb-2" style="font-size:13px;">
                <span class="stat-label mb-0">Answered</span>
                <span class="figure-mono" id="quizAnswered">0 of <%= quiz.getQuestionCount() %></span>
            </div>
            <div class="quiz-bar"><span id="quizBarFill"></span></div>
        </div>

        <form id="quizForm" method="post" action="<%= request.getContextPath() %>/quiz">
            <%
                int n = 0;
                for (QuestionBean q : quiz.getQuestions()) {
                    n++;
            %>
            <div class="q-card">
                <div class="q-number">Question <%= n %> of <%= quiz.getQuestionCount() %></div>
                <div class="q-text"><%= Validator.escapeHtml(q.getQuestion()) %></div>

                <%
                    String[] letters = {"A", "B", "C", "D"};
                    for (String L : letters) {
                        String inputId = "q" + q.getQuestionId() + L;
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
                    Scoring 50% or more opens the next topic.
                    Above 80% opens the Golden Assessment.
                </div>
                <button type="submit" class="btn btn-primary px-4 py-2" id="quizSubmit">
                    Submit the quiz
                </button>
            </div>
        </form>
    </div>

    <div class="col-xl-3">
        <div class="card-soft p-3" style="position:sticky; top:20px;">
            <div class="stat-label mb-2">How this is marked</div>
            <div class="rule-row" style="color:var(--muted); padding:5px 0;">
                <span class="rule-key" style="background:var(--coral-dim); color:#b3303c;">&lt; 50%</span>
                <span style="font-size:13px;">Revise and retake</span>
            </div>
            <div class="rule-row" style="color:var(--muted); padding:5px 0;">
                <span class="rule-key" style="background:var(--jade-dim); color:#1a7d4d;">50&ndash;80%</span>
                <span style="font-size:13px;">Next topic</span>
            </div>
            <div class="rule-row" style="color:var(--muted); padding:5px 0;">
                <span class="rule-key" style="background:var(--gold-dim); color:var(--gold-deep);">&gt; 80%</span>
                <span style="font-size:13px;">Golden Assessment</span>
            </div>
        </div>
    </div>
    </div>

</main>
</div>
<%@ include file="/includes/foot.jsp" %>
