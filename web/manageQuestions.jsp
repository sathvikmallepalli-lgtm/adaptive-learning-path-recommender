<%--
    Add, edit and delete questions for one topic at a time.
--%>
<%@ page import="java.util.List" %>
<%@ page import="beans.QuestionBean, beans.TopicBean" %>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Questions";
    String activePage = "questions";

    List<TopicBean> topics = (List<TopicBean>) request.getAttribute("topics");
    List<QuestionBean> questions = (List<QuestionBean>) request.getAttribute("questions");
    TopicBean selectedTopic = (TopicBean) request.getAttribute("selectedTopic");
    Integer selectedTopicId = (Integer) request.getAttribute("selectedTopicId");
    QuestionBean edit = (QuestionBean) request.getAttribute("editQuestion");
    String msg = request.getParameter("msg");
    boolean editing = edit != null;

    int practiceCount = 0, quizCount = 0, goldenCount = 0;
    for (QuestionBean q : questions) {
        if (QuestionBean.PRACTICE.equals(q.getQuestionType()))    { practiceCount++; }
        else if (QuestionBean.GOLDEN.equals(q.getQuestionType())) { goldenCount++; }
        else                                                      { quizCount++; }
    }
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/teacherNav.jsp" %>

<main class="content">

    <div class="page-head">
        <h1>Questions</h1>
        <p class="sub">
            Practice is not scored. The quiz decides the recommendation. Golden questions
            are the five that guard the advanced topics.
        </p>
    </div>

    <% if (msg != null && !msg.isEmpty()) { %>
        <div class="alert alert-info py-2" style="font-size:14px;"><%= Validator.escapeHtml(msg) %></div>
    <% } %>

    <!-- pick the topic to work on -->
    <div class="card-soft p-3 mb-3">
        <form method="get" action="<%= request.getContextPath() %>/manageQuestions"
              class="d-flex align-items-end gap-2 flex-wrap">
            <div style="min-width:240px;">
                <label class="form-label" for="topicPick">Topic</label>
                <select class="form-select" id="topicPick" name="topicId" onchange="this.form.submit();">
                    <% for (TopicBean t : topics) { %>
                        <option value="<%= t.getTopicId() %>"
                                <%= t.getTopicId() == selectedTopicId.intValue() ? "selected" : "" %>>
                            <%= t.getTopicOrder() %>. <%= Validator.escapeHtml(t.getTitle()) %>
                        </option>
                    <% } %>
                </select>
            </div>
            <button type="submit" class="btn btn-outline-secondary">Show</button>

            <div class="ms-auto d-flex gap-2 align-items-center">
                <span class="pill pill-idle">Practice <%= practiceCount %></span>
                <span class="pill pill-basic">Quiz <%= quizCount %></span>
                <span class="pill pill-gold">Golden <%= goldenCount %></span>
            </div>
        </form>
    </div>

    <div class="row g-3">

        <!-- ---------- list ---------- -->
        <div class="col-xl-7">
            <div class="card-soft">
                <div class="p-4 pb-2">
                    <div class="stat-label mb-0">
                        <%= selectedTopic == null ? "Questions" : Validator.escapeHtml(selectedTopic.getTitle()) %>
                        &middot; <%= questions.size() %> questions
                    </div>
                </div>

                <% if (questions.isEmpty()) { %>
                    <p class="text-muted-2 px-4 pb-4 mb-0" style="font-size:14px;">
                        No questions for this topic yet. Add the first one with the form.
                    </p>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="table-clean">
                            <thead>
                                <tr><th>Question</th><th>Type</th><th>Level</th><th>Answer</th><th></th></tr>
                            </thead>
                            <tbody>
                            <% for (QuestionBean q : questions) { %>
                                <tr>
                                    <td style="max-width:340px; font-size:13.5px;">
                                        <%= Validator.escapeHtml(q.getQuestion()) %>
                                    </td>
                                    <td>
                                        <span class="pill <%= QuestionBean.GOLDEN.equals(q.getQuestionType()) ? "pill-gold"
                                                            : QuestionBean.QUIZ.equals(q.getQuestionType()) ? "pill-basic"
                                                            : "pill-idle" %>">
                                            <%= Validator.escapeHtml(q.getQuestionType()) %>
                                        </span>
                                    </td>
                                    <td class="text-muted-2" style="font-size:12.5px;">
                                        <%= Validator.escapeHtml(q.getDifficulty()) %>
                                    </td>
                                    <td class="figure-mono"><%= Validator.escapeHtml(q.getCorrectAnswer()) %></td>
                                    <td class="text-end" style="white-space:nowrap;">
                                        <a class="btn btn-sm btn-outline-secondary" style="font-size:12px;"
                                           href="<%= request.getContextPath() %>/manageQuestions?topicId=<%= selectedTopicId %>&edit=<%= q.getQuestionId() %>">Edit</a>
                                        <form method="post" action="<%= request.getContextPath() %>/manageQuestions"
                                              style="display:inline;" data-confirm="Delete this question?">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="questionId" value="<%= q.getQuestionId() %>">
                                            <input type="hidden" name="topicId" value="<%= selectedTopicId %>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger"
                                                    style="font-size:12px;">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- ---------- form ---------- -->
        <div class="col-xl-5">
            <div class="card-soft p-4">
                <div class="stat-label mb-3"><%= editing ? "Edit question" : "Add a question" %></div>

                <form method="post" action="<%= request.getContextPath() %>/manageQuestions">
                    <input type="hidden" name="action" value="<%= editing ? "update" : "add" %>">
                    <% if (editing) { %>
                        <input type="hidden" name="questionId" value="<%= edit.getQuestionId() %>">
                    <% } %>
                    <input type="hidden" name="topicId"
                           value="<%= editing ? edit.getTopicId() : selectedTopicId %>">

                    <div class="mb-3">
                        <label class="form-label" for="question">Question</label>
                        <textarea class="form-control" id="question" name="question" rows="3" required
                                  maxlength="500"><%= editing ? Validator.escapeHtml(edit.getQuestion()) : "" %></textarea>
                    </div>

                    <% String[] letters = {"A", "B", "C", "D"};
                       for (String L : letters) { %>
                        <div class="mb-2">
                            <label class="form-label" for="option<%= L %>">Option <%= L %></label>
                            <input type="text" class="form-control" id="option<%= L %>"
                                   name="option<%= L %>" required maxlength="255"
                                   value="<%= editing ? Validator.escapeHtml(edit.getOption(L)) : "" %>">
                        </div>
                    <% } %>

                    <div class="row g-2 mt-1 mb-3">
                        <div class="col-4">
                            <label class="form-label" for="correctAnswer">Correct</label>
                            <select class="form-select" id="correctAnswer" name="correctAnswer">
                                <% for (String L : letters) { %>
                                    <option value="<%= L %>"
                                        <%= editing && L.equals(edit.getCorrectAnswer()) ? "selected" : "" %>><%= L %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-4">
                            <label class="form-label" for="difficulty">Level</label>
                            <select class="form-select" id="difficulty" name="difficulty">
                                <% String[] diffs = {"EASY", "MEDIUM", "HARD"};
                                   for (String d : diffs) { %>
                                    <option value="<%= d %>"
                                        <%= editing && d.equals(edit.getDifficulty()) ? "selected" : "" %>><%= d %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-4">
                            <label class="form-label" for="questionType">Used in</label>
                            <select class="form-select" id="questionType" name="questionType">
                                <% String[] types = {"PRACTICE", "QUIZ", "GOLDEN"};
                                   for (String ty : types) { %>
                                    <option value="<%= ty %>"
                                        <%= editing && ty.equals(edit.getQuestionType()) ? "selected" : "" %>><%= ty %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2">
                        <%= editing ? "Save changes" : "Add the question" %>
                    </button>
                    <% if (editing) { %>
                        <a class="btn btn-link w-100 mt-1"
                           href="<%= request.getContextPath() %>/manageQuestions?topicId=<%= selectedTopicId %>">Cancel</a>
                    <% } %>
                </form>
            </div>
        </div>
    </div>

</main>
</div>
<%@ include file="/includes/foot.jsp" %>
