<%--
    Landing page. Explains what the platform does and how the rules work,
    then sends the visitor to log in or register.
--%>
<% String pageTitle = "Learn Python on a path that adapts"; %>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="entry">

    <!-- Left: what this is, and the rules written out in the open -->
    <section class="entry-art">
        <a class="brand mb-4" href="<%= request.getContextPath() %>/">
            <span class="brand-mark">A</span>
            <span>Adaptive<br>Learning</span>
        </a>

        <h1>Learn Python on a path<br>that reacts to your quiz score.</h1>
        <p>
            Eight modules, from variables to modules. After every quiz the system reads
            your score and decides what you should do next &mdash; revise it, move on,
            or earn your way into the advanced half.
        </p>

        <div class="rule-strip">
            <div class="rule-row">
                <span class="rule-key">below 50%</span>
                <span>Revise the notes, practise, retake the quiz</span>
            </div>
            <div class="rule-row">
                <span class="rule-key">50 &ndash; 80%</span>
                <span>Move on to the next topic</span>
            </div>
            <div class="rule-row is-gold">
                <span class="rule-key">above 80%</span>
                <span>The Golden Assessment opens &mdash; 5 hard questions</span>
            </div>
            <div class="rule-row is-gold">
                <span class="rule-key">golden pass</span>
                <span>The advanced topic unlocks</span>
            </div>
        </div>
    </section>

    <!-- Right: the two ways in -->
    <section class="entry-form">
        <div class="inner">
            <h2 class="mb-1" style="font-size:24px;">Get started</h2>
            <p class="text-muted-2 mb-4" style="font-size:14px;">
                Students track their own path. Teachers manage the course content.
            </p>

            <a class="btn btn-primary w-100 mb-2 py-2" href="<%= request.getContextPath() %>/login.jsp">
                Log in
            </a>
            <a class="btn btn-outline-secondary w-100 py-2" href="<%= request.getContextPath() %>/register.jsp">
                Create a student account
            </a>

            <div class="card-soft mt-4 p-3">
                <div class="stat-label mb-2">What is inside</div>
                <div class="d-flex justify-content-between" style="font-size:14px;">
                    <span class="text-muted-2">Modules</span><span class="figure-mono">8</span>
                </div>
                <div class="d-flex justify-content-between" style="font-size:14px;">
                    <span class="text-muted-2">Questions</span><span class="figure-mono">200</span>
                </div>
                <div class="d-flex justify-content-between" style="font-size:14px;">
                    <span class="text-muted-2">Golden Assessments</span><span class="figure-mono">8 &times; 5</span>
                </div>
            </div>
        </div>
    </section>
</div>
<%@ include file="/includes/foot.jsp" %>
