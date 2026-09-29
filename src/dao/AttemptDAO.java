package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import beans.RecommendationBean;
import model.Attempt;
import util.DBConnection;

/**
 * Database work for the attempts table.
 *
 * Rows are only ever inserted. A retake adds a new row, which is what makes
 * the progress screen able to show a full history while still using the best
 * score for the rules.
 */
public class AttemptDAO {

    private static final String COLUMNS =
            "attempt_id, student_id, topic_id, attempt_type, score, "
          + "correct_answers, total_questions, attempt_date";

    /** Save an assessment and its advice together, or save neither. */
    public boolean insertWithRecommendation(Attempt attempt, RecommendationBean recommendation) {
        String attemptSql = "INSERT INTO attempts (student_id, topic_id, attempt_type, "
                + "score, correct_answers, total_questions) VALUES (?, ?, ?, ?, ?, ?)";
        String recommendationSql = "INSERT INTO recommendations (student_id, topic_id, "
                + "recommendation_type, recommendation, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement attemptStatement = con.prepareStatement(
                    attemptSql, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement recommendationStatement = con.prepareStatement(
                    recommendationSql, Statement.RETURN_GENERATED_KEYS)) {
                attemptStatement.setInt(1, attempt.getStudentId());
                attemptStatement.setInt(2, attempt.getTopicId());
                attemptStatement.setString(3, attempt.getAttemptType());
                attemptStatement.setInt(4, attempt.getScore());
                attemptStatement.setInt(5, attempt.getCorrectAnswers());
                attemptStatement.setInt(6, attempt.getTotalQuestions());
                if (attemptStatement.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }

                recommendationStatement.setInt(1, recommendation.getStudentId());
                recommendationStatement.setInt(2, recommendation.getTopicId());
                recommendationStatement.setString(3, recommendation.getRecommendationType());
                recommendationStatement.setString(4, recommendation.getRecommendation());
                recommendationStatement.setString(5, recommendation.getStatus());
                if (recommendationStatement.executeUpdate() != 1) {
                    con.rollback();
                    return false;
                }

                try (ResultSet attemptKeys = attemptStatement.getGeneratedKeys();
                     ResultSet recommendationKeys = recommendationStatement.getGeneratedKeys()) {
                    if (!attemptKeys.next() || !recommendationKeys.next()) {
                        con.rollback();
                        return false;
                    }
                    int attemptId = attemptKeys.getInt(1);
                    int recommendationId = recommendationKeys.getInt(1);
                    con.commit();
                    attempt.setAttemptId(attemptId);
                    recommendation.setRecommendationId(recommendationId);
                    return true;
                }
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        } catch (SQLException e) {
            System.err.println("AttemptDAO.insertWithRecommendation failed: " + e.getMessage());
            return false;
        }
    }

    /** @return the generated attempt_id, or -1 when the insert failed */
    public int insert(Attempt attempt) {
        String sql = "INSERT INTO attempts (student_id, topic_id, attempt_type, "
                   + "score, correct_answers, total_questions) VALUES (?, ?, ?, ?, ?, ?)";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet keys = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, attempt.getStudentId());
            ps.setInt(2, attempt.getTopicId());
            ps.setString(3, attempt.getAttemptType());
            ps.setInt(4, attempt.getScore());
            ps.setInt(5, attempt.getCorrectAnswers());
            ps.setInt(6, attempt.getTotalQuestions());

            if (ps.executeUpdate() == 0) {
                return -1;
            }
            keys = ps.getGeneratedKeys();
            if (keys.next()) {
                int id = keys.getInt(1);
                attempt.setAttemptId(id);
                return id;
            }
            return -1;
        } catch (SQLException e) {
            System.err.println("AttemptDAO.insert failed: " + e.getMessage());
            return -1;
        } finally {
            DBConnection.closeAll(con, ps, keys);
        }
    }

    /**
     * The highest score this student ever reached on this topic.
     * This single number drives most of the unlock rules.
     *
     * @param type QUIZ or GOLDEN
     * @return 0 when the topic was never attempted
     */
    public int findBestScore(int studentId, int topicId, String type) {
        String sql = "SELECT COALESCE(MAX(score), 0) FROM attempts "
                   + "WHERE student_id = ? AND topic_id = ? AND attempt_type = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, studentId);
            ps.setInt(2, topicId);
            ps.setString(3, type);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            System.err.println("AttemptDAO.findBestScore failed: " + e.getMessage());
            return 0;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    public int countAttempts(int studentId, int topicId, String type) {
        String sql = "SELECT COUNT(*) FROM attempts "
                   + "WHERE student_id = ? AND topic_id = ? AND attempt_type = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, studentId);
            ps.setInt(2, topicId);
            ps.setString(3, type);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            System.err.println("AttemptDAO.countAttempts failed: " + e.getMessage());
            return 0;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    /** History for one student, newest first, with the topic title joined in. */
    public List<Attempt> findByStudent(int studentId) {
        String sql = "SELECT a.attempt_id, a.student_id, a.topic_id, a.attempt_type, "
                   + "a.score, a.correct_answers, a.total_questions, a.attempt_date, "
                   + "t.title AS topic_title "
                   + "FROM attempts a JOIN topics t ON t.topic_id = a.topic_id "
                   + "WHERE a.student_id = ? ORDER BY a.attempt_date DESC, a.attempt_id DESC";
        return query(sql, studentId, 0);
    }

    /** History for one student on one topic, newest first. */
    public List<Attempt> findByStudentAndTopic(int studentId, int topicId) {
        String sql = "SELECT a.attempt_id, a.student_id, a.topic_id, a.attempt_type, "
                   + "a.score, a.correct_answers, a.total_questions, a.attempt_date, "
                   + "t.title AS topic_title "
                   + "FROM attempts a JOIN topics t ON t.topic_id = a.topic_id "
                   + "WHERE a.student_id = ? AND a.topic_id = ? "
                   + "ORDER BY a.attempt_date DESC, a.attempt_id DESC";
        return query(sql, studentId, topicId);
    }

    /**
     * Every attempt by every student, newest first - the teacher screen.
     * The student name and topic title are joined in for display.
     */
    public List<Attempt> findAll() {
        String sql = "SELECT a.attempt_id, a.student_id, a.topic_id, a.attempt_type, "
                   + "a.score, a.correct_answers, a.total_questions, a.attempt_date, "
                   + "t.title AS topic_title, s.name AS student_name "
                   + "FROM attempts a "
                   + "JOIN topics t ON t.topic_id = a.topic_id "
                   + "JOIN students s ON s.student_id = a.student_id "
                   + "ORDER BY a.attempt_date DESC, a.attempt_id DESC";
        List<Attempt> list = new ArrayList<Attempt>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Attempt a = map(rs);
                a.setStudentName(rs.getString("student_name"));
                list.add(a);
            }
        } catch (SQLException e) {
            System.err.println("AttemptDAO.findAll failed: " + e.getMessage());
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
        return list;
    }

    /** Shared body of the two "find by student" queries. */
    private List<Attempt> query(String sql, int studentId, int topicId) {
        List<Attempt> list = new ArrayList<Attempt>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, studentId);
            if (topicId > 0) {
                ps.setInt(2, topicId);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("AttemptDAO query failed: " + e.getMessage());
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
        return list;
    }

    private Attempt map(ResultSet rs) throws SQLException {
        Attempt a = new Attempt();
        a.setAttemptId(rs.getInt("attempt_id"));
        a.setStudentId(rs.getInt("student_id"));
        a.setTopicId(rs.getInt("topic_id"));
        a.setAttemptType(rs.getString("attempt_type"));
        a.setScore(rs.getInt("score"));
        a.setCorrectAnswers(rs.getInt("correct_answers"));
        a.setTotalQuestions(rs.getInt("total_questions"));
        a.setAttemptDate(rs.getTimestamp("attempt_date"));
        a.setTopicTitle(rs.getString("topic_title"));
        return a;
    }
}
