<%--
    One module: notes, practice questions and the way in to the quiz.

    The notes column holds simple HTML written by the teacher, so it is
    printed as it is. Everything a student ever typed is escaped.
--%>
<%@ page import="java.util.List" %>
<%@ page import="beans.QuestionBean, beans.TopicBean" %>
<%@ page import="model.TopicProgress" %>
<%@ page import="util.Validator" %>
<%
    TopicBean topic = (TopicBean) request.getAttribute("topic");
    TopicProgress state = (TopicProgress) request.getAttribute("state");
    List<QuestionBean> practice = (List<QuestionBean>) request.getAttribute("practiceQuestions");
    List<QuestionBean> advancedPractice = (List<QuestionBean>) request.getAttribute("advancedPractice");
    // The advanced set is opened by default for a student who attempted the
    // Golden Assessment and did not pass - that is exactly who was told to
    // come here by the ADVANCED_PRACTICE recommendation.
    boolean needsAdvanced = state.isGoldenAttempted() && !state.isGoldenPassed();
    Boolean goldenAvailable = (Boolean) request.getAttribute("goldenAvailable");
    boolean canGolden = goldenAvailable != null && goldenAvailable.booleanValue();

    String pageTitle = topic.getTitle();
    String activePage = "modules";
    String problem = request.getParameter("error");
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/studentNav.jsp" %>

<main class="content">

    <div class="page-head">
        <a href="<%= request.getContextPath() %>/modules" style="font-size:13px;">&larr; All modules</a>
        <div class="d-flex align-items-center gap-2 mt-2 flex-wrap">
            <h1 class="mb-0">
                <span class="figure-mono text-muted-2" style="font-size:19px;">
                    <%= (state.getTopicOrder() < 10 ? "0" : "") + state.getTopicOrder() %>
                </span>
                <%= Validator.escapeHtml(topic.getTitle()) %>
            </h1>
            <span class="pill <%= topic.isAdvanced() ? "pill-advanced" : "pill-basic" %>">
                <%= topic.isAdvanced() ? "Advanced" : "Basic" %>
            </span>
        </div>
        <p class="sub mt-1"><%= Validator.escapeHtml(topic.getDescription()) %></p>
    </div>

    <% if ("goldenlocked".equals(problem)) { %>
        <div class="alert alert-warning py-2" style="font-size:14px;">
            The Golden Assessment opens only after you score above 80% in this quiz.
        </div>
    <% } else if ("noquestions".equals(problem)) { %>
        <div class="alert alert-danger py-2" style="font-size:14px;">
            The full question set is not available yet. Ask your teacher to complete it.
        </div>
    <% } %>

    <div class="row g-3">

        <!-- ---------- notes ---------- -->
        <div class="col-lg-8">
            <div class="card-soft p-4">
                <div class="stat-label mb-3">Notes</div>
                <div class="notes">
                    <%-- The teacher writes this HTML, so it is rendered rather than escaped --%>
                    <%= topic.getNotes() == null ? "<p>No notes have been added for this topic yet.</p>" : topic.getNotes() %>
                </div>
            </div>

            <!-- ---------- practice ---------- -->
            <div class="card-soft p-4 mt-3">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <div class="stat-label mb-0">Practice</div>
                    <span class="text-muted-2" style="font-size:12.5px;">not scored</span>
                </div>
                <p class="text-muted-2 mb-3" style="font-size:14px;">
                    Check yourself before the quiz. Click a question to see its answer.
                </p>

                <% if (practice == null || practice.isEmpty()) { %>
                    <p class="text-muted-2 mb-0" style="font-size:14px;">
                        No practice questions for this topic yet.
                    </p>
                <% } else {
                       int pn = 0;
                       for (QuestionBean q : practice) { pn++; %>
                    <details class="q-card mb-2" style="cursor:pointer;">
                        <summary style="list-style:none;">
                            <div class="q-number">Practice <%= pn %></div>
                            <div class="q-text mb-0"><%= Validator.escapeHtml(q.getQuestion()) %></div>
                        </summary>
                        <div class="mt-3">
                            <% String[] letters = {"A", "B", "C", "D"};
                               for (String L : letters) {
                                   boolean right = L.equals(q.getCorrectAnswer()); %>
                                <div class="opt <%= right ? "picked" : "" %>" style="cursor:default;">
                                    <span class="letter"><%= L %></span>
                                    <span><%= Validator.escapeHtml(q.getOption(L)) %></span>
                                    <% if (right) { %>
                                        <span class="pill pill-pass ms-auto">Correct</span>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    </details>
                <%     }
                   } %>
            </div>

            <!-- ---------- advanced practice ---------- -->
            <div class="card-soft p-4 mt-3" id="advancedPractice">
                <div class="d-flex justify-content-between align-items-center mb-1 flex-wrap gap-2">
                    <div class="stat-label mb-0">Advanced practice</div>
                    <span class="pill pill-gold">harder</span>
                </div>
                <p class="text-muted-2 mb-3" style="font-size:14px;">
                    <% if (needsAdvanced) { %>
                        You were sent here after the Golden Assessment. Work through these,
                        then attempt it again.
                    <% } else { %>
                        Tougher questions than the set above. These are the ones to practise
                        before a Golden Assessment.
                    <% } %>
                </p>

                <% if (advancedPractice == null || advancedPractice.isEmpty()) { %>
                    <p class="text-muted-2 mb-0" style="font-size:14px;">
                        No advanced practice questions for this topic yet.
                    </p>
                <% } else {
                       int an = 0;
                       for (QuestionBean q : advancedPractice) { an++; %>
                    <details class="q-card gold mb-2" style="cursor:pointer;"
                             <%= needsAdvanced ? "open" : "" %>>
                        <summary style="list-style:none;">
                            <div class="q-number">Advanced <%= an %></div>
                            <div class="q-text mb-0"><%= Validator.escapeHtml(q.getQuestion()) %></div>
                        </summary>
                        <div class="mt-3">
                            <% String[] aLetters = {"A", "B", "C", "D"};
                               for (String L : aLetters) {
                                   boolean right = L.equals(q.getCorrectAnswer()); %>
                                <div class="opt <%= right ? "picked" : "" %>" style="cursor:default;">
                                    <span class="letter"><%= L %></span>
                                    <span><%= Validator.escapeHtml(q.getOption(L)) %></span>
                                    <% if (right) { %>
                                        <span class="pill pill-pass ms-auto">Correct</span>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    </details>
                <%     }
                   } %>
            </div>
        </div>

        <!-- ---------- the actions on the right ---------- -->
        <div class="col-lg-4">
            <div class="card-soft p-4" style="position:sticky; top:20px;">
                <div class="stat-label mb-2">Your standing here</div>

                <div class="d-flex align-items-baseline gap-2 mb-1">
                    <span class="stat-value"><%= state.getBestQuizScore() %><small>%</small></span>
                    <span class="text-muted-2" style="font-size:13px;">best score</span>
                </div>

                <div class="progress mb-3" style="height:5px;">
                    <div class="progress-bar" role="progressbar"
                         style="width:<%= state.getBestQuizScore() %>%;
                                background:<%= state.isGoldenPassed() ? "var(--gold)"
                                             : state.getBestQuizScore() >= 50 ? "var(--jade)" : "var(--coral)" %>;"
                         aria-valuenow="<%= state.getBestQuizScore() %>"
                         aria-valuemin="0" aria-valuemax="100"></div>
                </div>

                <div class="d-flex justify-content-between mb-1" style="font-size:13.5px;">
                    <span class="text-muted-2">Attempts</span>
                    <span class="figure-mono"><%= state.getQuizAttempts() %></span>
                </div>
                <div class="d-flex justify-content-between mb-3" style="font-size:13.5px;">
                    <span class="text-muted-2">Status</span>
                    <span class="pill <%= state.isGoldenPassed() ? "pill-gold"
                                        : state.getBestQuizScore() >= 50 ? "pill-pass"
                                        : state.isAttempted() ? "pill-fail" : "pill-idle" %>">
                        <%= state.getStatus() %>
                    </span>
                </div>

                <a class="btn btn-primary w-100 py-2"
                   href="<%= request.getContextPath() %>/quiz?topicId=<%= topic.getTopicId() %>">
                    <%= state.isAttempted() ? "Retake the quiz" : "Take the quiz" %>
                </a>
                <div class="text-muted-2 text-center mt-2" style="font-size:12.5px;">
                    10 questions &middot; 50% to move on
                </div>

                <!-- The Golden Assessment appears only when the rule allows it -->
                <% if (canGolden) { %>
                    <hr class="my-3">
                    <div class="golden-banner mb-2">
                        <h2 style="font-size:17px;">Golden Assessment</h2>
                        <p>
                            You scored above 80% here. Try five harder questions;
                            60% is a pass. A Golden pass is required before an
                            advanced next topic opens.
                        </p>
                    </div>
                    <a class="btn btn-gold w-100 py-2"
                       href="<%= request.getContextPath() %>/golden?topicId=<%= topic.getTopicId() %>">
                        <%= state.isGoldenAttempted() ? "Attempt it again" : "Start the Golden Assessment" %>
                    </a>
                    <% if (state.isGoldenPassed()) { %>
                        <div class="text-center mt-2">
                            <span class="pill pill-gold">Already passed</span>
                        </div>
                    <% } %>
                <% } else { %>
                    <hr class="my-3">
                    <div class="stat-label mb-2">Golden Assessment</div>
                    <p class="text-muted-2 mb-0" style="font-size:13.5px;">
                        Locked. Score above 80% in this quiz to open it.
                        <% if (topic.isAdvanced()) { %>
                            It is the only way to unlock the topic after this one.
                        <% } %>
                    </p>
                <% } %>
            </div>
        </div>
    </div>

</main>
</div>
<%@ include file="/includes/foot.jsp" %>
