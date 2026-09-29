package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import beans.RecommendationBean;
import util.DBConnection;

/**
 * Database work for the recommendations table.
 *
 * A new row is written after every attempt, so a student and a teacher can
 * both see the full history of what the engine advised and when.
 */
public class RecommendationDAO {

    /** @return the generated recommendation_id, or -1 when the insert failed */
    public int insert(RecommendationBean r) {
        String sql = "INSERT INTO recommendations (student_id, topic_id, "
                   + "recommendation_type, recommendation, status) VALUES (?, ?, ?, ?, ?)";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet keys = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, r.getStudentId());
            ps.setInt(2, r.getTopicId());
            ps.setString(3, r.getRecommendationType());
            ps.setString(4, r.getRecommendation());
            ps.setString(5, r.getStatus());

            if (ps.executeUpdate() == 0) {
                return -1;
            }
            keys = ps.getGeneratedKeys();
            if (keys.next()) {
                int id = keys.getInt(1);
                r.setRecommendationId(id);
                return id;
            }
            return -1;
        } catch (SQLException e) {
            System.err.println("RecommendationDAO.insert failed: " + e.getMessage());
            return -1;
        } finally {
            DBConnection.closeAll(con, ps, keys);
        }
    }

    /** Everything advised to one student, newest first. */
    public List<RecommendationBean> findByStudent(int studentId) {
        String sql = "SELECT r.recommendation_id, r.student_id, r.topic_id, "
                   + "r.recommendation_type, r.recommendation, r.status, r.created_date, "
                   + "t.title AS topic_title "
                   + "FROM recommendations r JOIN topics t ON t.topic_id = r.topic_id "
                   + "WHERE r.student_id = ? "
                   + "ORDER BY r.created_date DESC, r.recommendation_id DESC";
        List<RecommendationBean> list = new ArrayList<RecommendationBean>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, studentId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("RecommendationDAO.findByStudent failed: " + e.getMessage());
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
        return list;
    }

    /** The most recent recommendation, shown as the "current" one. */
    public RecommendationBean findLatestByStudent(int studentId) {
        List<RecommendationBean> all = findByStudent(studentId);
        return all.isEmpty() ? null : all.get(0);
    }

    public RecommendationBean findById(int recommendationId) {
        String sql = "SELECT r.recommendation_id, r.student_id, r.topic_id, "
                   + "r.recommendation_type, r.recommendation, r.status, r.created_date, "
                   + "t.title AS topic_title "
                   + "FROM recommendations r JOIN topics t ON t.topic_id = r.topic_id "
                   + "WHERE r.recommendation_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, recommendationId);
            rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        } catch (SQLException e) {
            System.err.println("RecommendationDAO.findById failed: " + e.getMessage());
            return null;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    /**
     * Marks a recommendation as done.
     * The student_id is part of the WHERE clause so one student can never
     * change another student's recommendation by editing the id in the URL.
     */
    public boolean markCompleted(int recommendationId, int studentId) {
        String sql = "UPDATE recommendations SET status = 'COMPLETED' "
                   + "WHERE recommendation_id = ? AND student_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, recommendationId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("RecommendationDAO.markCompleted failed: " + e.getMessage());
            return false;
        } finally {
            DBConnection.closeAll(con, ps, null);
        }
    }

    /** Every recommendation for every student - the teacher screen. */
    public List<RecommendationBean> findAll() {
        String sql = "SELECT r.recommendation_id, r.student_id, r.topic_id, "
                   + "r.recommendation_type, r.recommendation, r.status, r.created_date, "
                   + "t.title AS topic_title, s.name AS student_name "
                   + "FROM recommendations r "
                   + "JOIN topics t ON t.topic_id = r.topic_id "
                   + "JOIN students s ON s.student_id = r.student_id "
                   + "ORDER BY r.created_date DESC, r.recommendation_id DESC";
        List<RecommendationBean> list = new ArrayList<RecommendationBean>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                RecommendationBean r = map(rs);
                r.setStudentName(rs.getString("student_name"));
                list.add(r);
            }
        } catch (SQLException e) {
            System.err.println("RecommendationDAO.findAll failed: " + e.getMessage());
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
        return list;
    }

    private RecommendationBean map(ResultSet rs) throws SQLException {
        RecommendationBean r = new RecommendationBean();
        r.setRecommendationId(rs.getInt("recommendation_id"));
        r.setStudentId(rs.getInt("student_id"));
        r.setTopicId(rs.getInt("topic_id"));
        r.setRecommendationType(rs.getString("recommendation_type"));
        r.setRecommendation(rs.getString("recommendation"));
        r.setStatus(rs.getString("status"));
        r.setCreatedDate(rs.getTimestamp("created_date"));
        r.setTopicTitle(rs.getString("topic_title"));
        return r;
    }
}
