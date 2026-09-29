<%--
    The dark rail on the left of every teacher page.
--%>
<%@ page import="beans.TeacherBean" %>
<%
    TeacherBean navTeacher = (TeacherBean) session.getAttribute("teacher");
    String ctx = request.getContextPath();
%>
<aside class="sidebar">
    <a class="brand" href="<%= ctx %>/teacherDashboard">
        <span class="brand-mark">A</span>
        <span>Adaptive<br>Learning</span>
    </a>

    <div class="nav-label">Teaching</div>
    <nav>
        <a class="nav-item <%= "dashboard".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/teacherDashboard">
            <span class="nav-icon">&#9632;</span> Dashboard
        </a>
        <a class="nav-item <%= "topics".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/manageTopics">
            <span class="nav-icon">&#9776;</span> Topics
        </a>
        <a class="nav-item <%= "questions".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/manageQuestions">
            <span class="nav-icon">&#63;</span> Questions
        </a>
        <a class="nav-item <%= "attempts".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/viewAttempts">
            <span class="nav-icon">&#9650;</span> Attempts
        </a>
        <a class="nav-item <%= "recommendations".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/viewRecommendations">
            <span class="nav-icon">&#9758;</span> Recommendations
        </a>
    </nav>

    <div class="sidebar-foot">
        <div class="who">
            <div class="avatar"><%= navTeacher == null ? "T" : navTeacher.getInitials() %></div>
            <div>
                <div class="who-name"><%= navTeacher == null ? "Teacher" : util.Validator.escapeHtml(navTeacher.getName()) %></div>
                <div class="who-role">Teacher</div>
            </div>
        </div>
        <a class="nav-item" href="<%= ctx %>/logout"><span class="nav-icon">&#8629;</span> Log out</a>
    </div>
</aside>
