<%--
    The dark rail on the left of every student page.
    Set the variable  activePage  before including it so the current link
    can be highlighted.
--%>
<%@ page import="beans.StudentBean" %>
<%
    StudentBean navStudent = (StudentBean) session.getAttribute("student");
    String ctx = request.getContextPath();
%>
<aside class="sidebar">
    <a class="brand" href="<%= ctx %>/studentDashboard">
        <span class="brand-mark">A</span>
        <span>Adaptive<br>Learning</span>
    </a>

    <div class="nav-label">Learning</div>
    <nav>
        <a class="nav-item <%= "dashboard".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/studentDashboard">
            <span class="nav-icon">&#9632;</span> Dashboard
        </a>
        <a class="nav-item <%= "modules".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/modules">
            <span class="nav-icon">&#9776;</span> Modules
        </a>
        <a class="nav-item <%= "recommendation".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/recommendation">
            <span class="nav-icon">&#9758;</span> Recommendations
        </a>
        <a class="nav-item <%= "progress".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/progress">
            <span class="nav-icon">&#9650;</span> Progress
        </a>
    </nav>

    <div class="sidebar-foot">
        <div class="who">
            <div class="avatar"><%= navStudent == null ? "S" : navStudent.getInitials() %></div>
            <div>
                <div class="who-name"><%= navStudent == null ? "Student" : util.Validator.escapeHtml(navStudent.getName()) %></div>
                <div class="who-role">Student</div>
            </div>
        </div>
        <a class="nav-item" href="<%= ctx %>/logout"><span class="nav-icon">&#8629;</span> Log out</a>
    </div>
</aside>
