package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import beans.QuestionBean;
import util.DBConnection;

/**
 * Database work for the questions table.
 *
 * The most used query is "give me the questions of one type for one topic",
 * which is exactly what the index idx_questions_topic_type supports.
 */
public class QuestionDAO {

    private static final String COLUMNS =
            "question_id, topic_id, question, option_a, option_b, option_c, option_d, "
          + "correct_answer, difficulty, question_type";

    /**
     * Questions for one screen.
     *
     * @param type  PRACTICE, QUIZ or GOLDEN
     * @param limit maximum number to return, 0 means no limit
     */
    public List<QuestionBean> findByTopicAndType(int topicId, String type, int limit) {
        String sql = "SELECT " + COLUMNS + " FROM questions "
                   + "WHERE topic_id = ? AND question_type = ? ORDER BY question_id"
                   + (limit > 0 ? " LIMIT ?" : "");
        List<QuestionBean> list = new ArrayList<QuestionBean>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, topicId);
            ps.setString(2, type);
            if (limit > 0) {
                ps.setInt(3, limit);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("QuestionDAO.findByTopicAndType failed: " + e.getMessage());
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
        return list;
    }

    /**
     * Practice questions split by how hard they are.
     *
     * The normal practice section uses the easier ones. When the rule engine
     * returns ADVANCED_PRACTICE - which happens after a failed Golden
     * Assessment - the topic page shows the HARD ones instead, so that the
     * advice actually leads somewhere harder.
     *
     * @param advanced true for the HARD set, false for everything else
     */
    public List<QuestionBean> findPractice(int topicId, boolean advanced) {
        String sql = "SELECT " + COLUMNS + " FROM questions "
                   + "WHERE topic_id = ? AND question_type = 'PRACTICE' "
                   + (advanced ? "AND difficulty = 'HARD' " : "AND difficulty <> 'HARD' ")
                   + "ORDER BY question_id";
        List<QuestionBean> list = new ArrayList<QuestionBean>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, topicId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("QuestionDAO.findPractice failed: " + e.getMessage());
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
        return list;
    }

    /** Every question of a topic, whatever its type - for the teacher screen. */
    public List<QuestionBean> findByTopic(int topicId) {
        String sql = "SELECT " + COLUMNS + " FROM questions "
                   + "WHERE topic_id = ? ORDER BY question_type, question_id";
        List<QuestionBean> list = new ArrayList<QuestionBean>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, topicId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("QuestionDAO.findByTopic failed: " + e.getMessage());
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
        return list;
    }

    public QuestionBean findById(int questionId) {
        String sql = "SELECT " + COLUMNS + " FROM questions WHERE question_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, questionId);
            rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        } catch (SQLException e) {
            System.err.println("QuestionDAO.findById failed: " + e.getMessage());
            return null;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    public int countByTopicAndType(int topicId, String type) {
        String sql = "SELECT COUNT(*) FROM questions WHERE topic_id = ? AND question_type = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, topicId);
            ps.setString(2, type);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            System.err.println("QuestionDAO.countByTopicAndType failed: " + e.getMessage());
            return 0;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    public boolean insert(QuestionBean q) {
        String sql = "INSERT INTO questions (topic_id, question, option_a, option_b, "
                   + "option_c, option_d, correct_answer, difficulty, question_type) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            bind(ps, q);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("QuestionDAO.insert failed: " + e.getMessage());
            return false;
        } finally {
            DBConnection.closeAll(con, ps, null);
        }
    }

    public boolean update(QuestionBean q) {
        String sql = "UPDATE questions SET topic_id = ?, question = ?, option_a = ?, "
                   + "option_b = ?, option_c = ?, option_d = ?, correct_answer = ?, "
                   + "difficulty = ?, question_type = ? WHERE question_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            bind(ps, q);
            ps.setInt(10, q.getQuestionId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("QuestionDAO.update failed: " + e.getMessage());
            return false;
        } finally {
            DBConnection.closeAll(con, ps, null);
        }
    }

    public boolean delete(int questionId) {
        String sql = "DELETE FROM questions WHERE question_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, questionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("QuestionDAO.delete failed: " + e.getMessage());
            return false;
        } finally {
            DBConnection.closeAll(con, ps, null);
        }
    }

    /** The nine values are identical for insert and update, so they are set once. */
    private void bind(PreparedStatement ps, QuestionBean q) throws SQLException {
        ps.setInt(1, q.getTopicId());
        ps.setString(2, q.getQuestion());
        ps.setString(3, q.getOptionA());
        ps.setString(4, q.getOptionB());
        ps.setString(5, q.getOptionC());
        ps.setString(6, q.getOptionD());
        ps.setString(7, q.getCorrectAnswer());
        ps.setString(8, q.getDifficulty());
        ps.setString(9, q.getQuestionType());
    }

    private QuestionBean map(ResultSet rs) throws SQLException {
        QuestionBean q = new QuestionBean();
        q.setQuestionId(rs.getInt("question_id"));
        q.setTopicId(rs.getInt("topic_id"));
        q.setQuestion(rs.getString("question"));
        q.setOptionA(rs.getString("option_a"));
        q.setOptionB(rs.getString("option_b"));
        q.setOptionC(rs.getString("option_c"));
        q.setOptionD(rs.getString("option_d"));
        q.setCorrectAnswer(rs.getString("correct_answer"));
        q.setDifficulty(rs.getString("difficulty"));
        q.setQuestionType(rs.getString("question_type"));
        return q;
    }
}
