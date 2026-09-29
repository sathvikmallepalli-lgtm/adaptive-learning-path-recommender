package controller;

import java.io.IOException;
import java.util.List;

import beans.QuestionBean;
import beans.TopicBean;
import dao.QuestionDAO;
import dao.TopicDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.Validator;

/**
 * Add, edit and delete questions, one topic at a time.
 */
@WebServlet("/manageQuestions")
public class ManageQuestionsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final QuestionDAO questionDAO = new QuestionDAO();
    private final TopicDAO topicDAO = new TopicDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<TopicBean> topics = topicDAO.findAll();

        // Default to the first topic so the page is never empty
        int topicId = Validator.toInt(request.getParameter("topicId"), 0);
        if (topicId <= 0 && !topics.isEmpty()) {
            topicId = topics.get(0).getTopicId();
        }

        List<QuestionBean> questions = topicId > 0
                ? questionDAO.findByTopic(topicId)
                : new java.util.ArrayList<QuestionBean>();

        int editId = Validator.toInt(request.getParameter("edit"), 0);
        if (editId > 0) {
            request.setAttribute("editQuestion", questionDAO.findById(editId));
        }

        request.setAttribute("topics", topics);
        request.setAttribute("selectedTopicId", Integer.valueOf(topicId));
        request.setAttribute("selectedTopic", topicDAO.findById(topicId));
        request.setAttribute("questions", questions);
        request.getRequestDispatcher("/manageQuestions.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = Validator.clean(request.getParameter("action"));
        int topicId = Validator.toInt(request.getParameter("topicId"), 0);
        String message;

        if ("delete".equals(action)) {
            int id = Validator.toInt(request.getParameter("questionId"), 0);
            message = (id > 0 && questionDAO.delete(id))
                    ? "Question deleted." : "Delete failed.";
        } else {
            message = saveQuestion(request, "update".equals(action));
        }

        response.sendRedirect(request.getContextPath() + "/manageQuestions?topicId=" + topicId
                + "&msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
    }

    private String saveQuestion(HttpServletRequest request, boolean isUpdate) {
        int topicId = Validator.toInt(request.getParameter("topicId"), 0);
        String text = Validator.clean(request.getParameter("question"));
        String a = Validator.clean(request.getParameter("optionA"));
        String b = Validator.clean(request.getParameter("optionB"));
        String c = Validator.clean(request.getParameter("optionC"));
        String d = Validator.clean(request.getParameter("optionD"));
        String correct = Validator.clean(request.getParameter("correctAnswer")).toUpperCase();
        String difficulty = Validator.clean(request.getParameter("difficulty"));
        String type = Validator.clean(request.getParameter("questionType"));

        // ---------- validation ----------
        if (topicId <= 0) {
            return "Please choose a topic.";
        }
        if (Validator.isEmpty(text)) {
            return "The question text is required.";
        }
        if (Validator.isEmpty(a) || Validator.isEmpty(b)
                || Validator.isEmpty(c) || Validator.isEmpty(d)) {
            return "All four options are required.";
        }
        if (!Validator.isValidOption(correct)) {
            return "The correct answer must be A, B, C or D.";
        }
        if (!"EASY".equals(difficulty) && !"MEDIUM".equals(difficulty) && !"HARD".equals(difficulty)) {
            difficulty = "EASY";
        }
        if (!QuestionBean.PRACTICE.equals(type) && !QuestionBean.QUIZ.equals(type)
                && !QuestionBean.GOLDEN.equals(type)) {
            type = QuestionBean.QUIZ;
        }

        QuestionBean q = new QuestionBean();
        q.setTopicId(topicId);
        q.setQuestion(text);
        q.setOptionA(a);
        q.setOptionB(b);
        q.setOptionC(c);
        q.setOptionD(d);
        q.setCorrectAnswer(correct);
        q.setDifficulty(difficulty);
        q.setQuestionType(type);

        if (isUpdate) {
            int id = Validator.toInt(request.getParameter("questionId"), 0);
            if (id <= 0) {
                return "That question could not be found.";
            }
            q.setQuestionId(id);
            return questionDAO.update(q) ? "Question updated." : "Update failed.";
        }
        return questionDAO.insert(q) ? "Question added." : "Could not add the question.";
    }
}
