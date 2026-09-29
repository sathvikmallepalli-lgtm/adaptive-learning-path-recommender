package controller;

import java.io.IOException;
import java.util.List;

import beans.TopicBean;
import dao.TopicDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.Validator;

/**
 * Add, edit and delete topics.
 *
 * One servlet handles all three actions, chosen by a hidden "action" field.
 * That keeps the number of URLs small and is easy to follow.
 */
@WebServlet("/manageTopics")
public class ManageTopicsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final TopicDAO topicDAO = new TopicDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<TopicBean> topics = topicDAO.findAll();

        // When ?edit=5 is in the URL the form is filled with that topic
        int editId = Validator.toInt(request.getParameter("edit"), 0);
        if (editId > 0) {
            request.setAttribute("editTopic", topicDAO.findById(editId));
        }

        request.setAttribute("topics", topics);
        request.setAttribute("nextOrder", Integer.valueOf(topicDAO.nextAvailableOrder()));
        request.getRequestDispatcher("/manageTopics.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = Validator.clean(request.getParameter("action"));
        String message;

        if ("delete".equals(action)) {
            message = deleteTopic(request);
        } else if ("update".equals(action)) {
            message = saveTopic(request, true);
        } else {
            message = saveTopic(request, false);
        }

        // Redirect after post, so refreshing does not repeat the change
        response.sendRedirect(request.getContextPath() + "/manageTopics?msg="
                + java.net.URLEncoder.encode(message, "UTF-8"));
    }

    private String saveTopic(HttpServletRequest request, boolean isUpdate) {
        String title = Validator.clean(request.getParameter("title"));
        String description = Validator.clean(request.getParameter("description"));
        String notes = request.getParameter("notes");
        String difficulty = Validator.clean(request.getParameter("difficulty"));
        int order = Validator.toInt(request.getParameter("topicOrder"), 0);

        if (Validator.isEmpty(title) || Validator.isEmpty(description)) {
            return "Title and description are required.";
        }
        if (!TopicBean.BASIC.equals(difficulty) && !TopicBean.ADVANCED.equals(difficulty)) {
            difficulty = TopicBean.BASIC;
        }
        if (order <= 0) {
            order = topicDAO.nextAvailableOrder();
        }

        TopicBean topic = new TopicBean();
        topic.setTitle(title);
        topic.setDescription(description);
        topic.setNotes(notes);
        topic.setDifficulty(difficulty);
        topic.setTopicOrder(order);

        if (isUpdate) {
            int id = Validator.toInt(request.getParameter("topicId"), 0);
            if (id <= 0) {
                return "That topic could not be found.";
            }
            topic.setTopicId(id);
            return topicDAO.update(topic)
                 ? "Topic updated."
                 : "Update failed - the title or the position may already be in use.";
        }

        return topicDAO.insert(topic)
             ? "Topic added."
             : "Could not add the topic - the title or the position may already be in use.";
    }

    private String deleteTopic(HttpServletRequest request) {
        int id = Validator.toInt(request.getParameter("topicId"), 0);
        if (id <= 0) {
            return "That topic could not be found.";
        }
        // Student history must never be destroyed by a content change
        if (topicDAO.hasAttempts(id)) {
            return "This topic cannot be deleted because students have already attempted it.";
        }
        return topicDAO.delete(id)
             ? "Topic deleted along with its questions."
             : "Delete failed.";
    }
}
