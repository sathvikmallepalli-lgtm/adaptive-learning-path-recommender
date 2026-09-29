<%--
    Add, edit and delete topics.
    The same form is used for adding and editing - when ?edit=5 is in the
    URL the servlet supplies editTopic and the fields are pre-filled.
--%>
<%@ page import="java.util.List" %>
<%@ page import="beans.TopicBean" %>
<%@ page import="util.Validator" %>
<%
    String pageTitle = "Topics";
    String activePage = "topics";

    List<TopicBean> topics = (List<TopicBean>) request.getAttribute("topics");
    TopicBean edit = (TopicBean) request.getAttribute("editTopic");
    Integer nextOrder = (Integer) request.getAttribute("nextOrder");
    String msg = request.getParameter("msg");
    boolean editing = edit != null;
%>
<%@ include file="/includes/head.jsp" %>
<body>
<div class="app">
<%@ include file="/includes/teacherNav.jsp" %>

<main class="content">

    <div class="page-head">
        <h1>Topics</h1>
        <p class="sub">
            The order of the topics is the learning path. Advanced topics sit behind a
            Golden Assessment.
        </p>
    </div>

    <% if (msg != null && !msg.isEmpty()) { %>
        <div class="alert alert-info py-2" style="font-size:14px;"><%= Validator.escapeHtml(msg) %></div>
    <% } %>

    <div class="row g-3">

        <!-- ---------- the list ---------- -->
        <div class="col-lg-7">
            <div class="card-soft">
                <div class="p-4 pb-2 d-flex justify-content-between align-items-center">
                    <div class="stat-label mb-0">All topics</div>
                    <span class="text-muted-2" style="font-size:12.5px;"><%= topics.size() %> total</span>
                </div>
                <div class="table-wrap">
                    <table class="table-clean">
                        <thead>
                            <tr><th>#</th><th>Title</th><th>Level</th><th></th></tr>
                        </thead>
                        <tbody>
                        <% for (TopicBean t : topics) { %>
                            <tr>
                                <td class="figure-mono text-muted-2"><%= t.getTopicOrder() %></td>
                                <td>
                                    <div style="font-weight:500;"><%= Validator.escapeHtml(t.getTitle()) %></div>
                                    <div class="text-muted-2" style="font-size:12.5px;">
                                        <%= Validator.escapeHtml(t.getDescription()) %>
                                    </div>
                                </td>
                                <td>
                                    <span class="pill <%= t.isAdvanced() ? "pill-advanced" : "pill-basic" %>">
                                        <%= t.isAdvanced() ? "Advanced" : "Basic" %>
                                    </span>
                                </td>
                                <td class="text-end" style="white-space:nowrap;">
                                    <a class="btn btn-sm btn-outline-secondary" style="font-size:12px;"
                                       href="<%= request.getContextPath() %>/manageTopics?edit=<%= t.getTopicId() %>">Edit</a>
                                    <form method="post" action="<%= request.getContextPath() %>/manageTopics"
                                          style="display:inline;"
                                          data-confirm="Delete this topic and all of its questions?">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="topicId" value="<%= t.getTopicId() %>">
                                        <button type="submit" class="btn btn-sm btn-outline-danger"
                                                style="font-size:12px;">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ---------- the form ---------- -->
        <div class="col-lg-5">
            <div class="card-soft p-4" style="position:sticky; top:20px;">
                <div class="stat-label mb-3"><%= editing ? "Edit topic" : "Add a topic" %></div>

                <form method="post" action="<%= request.getContextPath() %>/manageTopics">
                    <input type="hidden" name="action" value="<%= editing ? "update" : "add" %>">
                    <% if (editing) { %>
                        <input type="hidden" name="topicId" value="<%= edit.getTopicId() %>">
                    <% } %>

                    <div class="mb-3">
                        <label class="form-label" for="title">Title</label>
                        <input type="text" class="form-control" id="title" name="title" required
                               maxlength="100"
                               value="<%= editing ? Validator.escapeHtml(edit.getTitle()) : "" %>">
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="description">One line description</label>
                        <input type="text" class="form-control" id="description" name="description" required
                               maxlength="255"
                               value="<%= editing ? Validator.escapeHtml(edit.getDescription()) : "" %>">
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-7">
                            <label class="form-label" for="difficulty">Level</label>
                            <select class="form-select" id="difficulty" name="difficulty">
                                <option value="BASIC" <%= editing && !edit.isAdvanced() ? "selected" : "" %>>Basic</option>
                                <option value="ADVANCED" <%= editing && edit.isAdvanced() ? "selected" : "" %>>Advanced</option>
                            </select>
                        </div>
                        <div class="col-5">
                            <label class="form-label" for="topicOrder">Position</label>
                            <input type="number" class="form-control" id="topicOrder" name="topicOrder"
                                   min="1" required
                                   value="<%= editing ? edit.getTopicOrder() : nextOrder %>">
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="notes">Notes (simple HTML)</label>
                        <textarea class="form-control" id="notes" name="notes" rows="8"
                                  style="font-family:var(--font-mono); font-size:12.5px;"
                                  placeholder="&lt;h4&gt;Heading&lt;/h4&gt;&lt;p&gt;Explanation&lt;/p&gt;&lt;pre&gt;code&lt;/pre&gt;"><%= editing && edit.getNotes() != null ? Validator.escapeHtml(edit.getNotes()) : "" %></textarea>
                        <div class="small text-muted-2 mt-1">
                            Shown on the topic page. Use h4, p, ul, li, code and pre.
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2">
                        <%= editing ? "Save changes" : "Add the topic" %>
                    </button>
                    <% if (editing) { %>
                        <a class="btn btn-link w-100 mt-1" href="<%= request.getContextPath() %>/manageTopics">Cancel</a>
                    <% } %>
                </form>
            </div>
        </div>
    </div>

</main>
</div>
<%@ include file="/includes/foot.jsp" %>
