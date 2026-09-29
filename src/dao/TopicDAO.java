package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import beans.TopicBean;
import util.DBConnection;

/**
 * Database work for the topics table.
 *
 * Topics are always read in topic_order, because that order IS the
 * learning path.
 */
public class TopicDAO {

    private static final String COLUMNS =
            "topic_id, title, description, notes, difficulty, topic_order";

    /** Every topic, in learning path order. */
    public List<TopicBean> findAll() {
        String sql = "SELECT " + COLUMNS + " FROM topics ORDER BY topic_order";
        List<TopicBean> list = new ArrayList<TopicBean>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("TopicDAO.findAll failed: " + e.getMessage());
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
        return list;
    }

    public TopicBean findById(int topicId) {
        String sql = "SELECT " + COLUMNS + " FROM topics WHERE topic_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, topicId);
            rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        } catch (SQLException e) {
            System.err.println("TopicDAO.findById failed: " + e.getMessage());
            return null;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    /** The topic that comes straight after the given one, or null at the end. */
    public TopicBean findNext(int currentOrder) {
        String sql = "SELECT " + COLUMNS + " FROM topics "
                   + "WHERE topic_order > ? ORDER BY topic_order LIMIT 1";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, currentOrder);
            rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        } catch (SQLException e) {
            System.err.println("TopicDAO.findNext failed: " + e.getMessage());
            return null;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    /** The topic just before the given one - used by the unlock rule. */
    public TopicBean findPrevious(int currentOrder) {
        String sql = "SELECT " + COLUMNS + " FROM topics "
                   + "WHERE topic_order < ? ORDER BY topic_order DESC LIMIT 1";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, currentOrder);
            rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        } catch (SQLException e) {
            System.err.println("TopicDAO.findPrevious failed: " + e.getMessage());
            return null;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    public boolean insert(TopicBean topic) {
        String sql = "INSERT INTO topics (title, description, notes, difficulty, topic_order) "
                   + "VALUES (?, ?, ?, ?, ?)";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, topic.getTitle());
            ps.setString(2, topic.getDescription());
            ps.setString(3, topic.getNotes());
            ps.setString(4, topic.getDifficulty());
            ps.setInt(5, topic.getTopicOrder());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("TopicDAO.insert failed: " + e.getMessage());
            return false;
        } finally {
            DBConnection.closeAll(con, ps, null);
        }
    }

    public boolean update(TopicBean topic) {
        String sql = "UPDATE topics SET title = ?, description = ?, notes = ?, "
                   + "difficulty = ?, topic_order = ? WHERE topic_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, topic.getTitle());
            ps.setString(2, topic.getDescription());
            ps.setString(3, topic.getNotes());
            ps.setString(4, topic.getDifficulty());
            ps.setInt(5, topic.getTopicOrder());
            ps.setInt(6, topic.getTopicId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("TopicDAO.update failed: " + e.getMessage());
            return false;
        } finally {
            DBConnection.closeAll(con, ps, null);
        }
    }

    /**
     * Deleting a topic also deletes its questions (ON DELETE CASCADE).
     * It fails on purpose when students have already attempted the topic,
     * because that history must not be lost.
     */
    public boolean delete(int topicId) {
        String sql = "DELETE FROM topics WHERE topic_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, topicId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("TopicDAO.delete failed: " + e.getMessage());
            return false;
        } finally {
            DBConnection.closeAll(con, ps, null);
        }
    }

    /** True when a student has already attempted this topic. */
    public boolean hasAttempts(int topicId) {
        String sql = "SELECT COUNT(*) FROM attempts WHERE topic_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, topicId);
            rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } catch (SQLException e) {
            System.err.println("TopicDAO.hasAttempts failed: " + e.getMessage());
            return true;   // be careful: assume yes rather than delete history
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    /** Next free position in the learning path, used when adding a topic. */
    public int nextAvailableOrder() {
        String sql = "SELECT COALESCE(MAX(topic_order), 0) + 1 FROM topics";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 1;
        } catch (SQLException e) {
            System.err.println("TopicDAO.nextAvailableOrder failed: " + e.getMessage());
            return 1;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    private TopicBean map(ResultSet rs) throws SQLException {
        TopicBean t = new TopicBean();
        t.setTopicId(rs.getInt("topic_id"));
        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setNotes(rs.getString("notes"));
        t.setDifficulty(rs.getString("difficulty"));
        t.setTopicOrder(rs.getInt("topic_order"));
        return t;
    }
}
