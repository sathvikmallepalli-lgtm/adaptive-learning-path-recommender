package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import beans.TeacherBean;
import util.DBConnection;
import util.PasswordUtil;

/**
 * Database work for the teachers table.
 *
 * Teacher accounts are created by the seed script, so there is no insert
 * method here - only the queries the login and dashboard need.
 */
public class TeacherDAO {

    public TeacherBean authenticate(String email, String plainPassword) {
        TeacherBean teacher = findByEmail(email);
        if (teacher == null) {
            return null;
        }
        return PasswordUtil.matches(plainPassword, teacher.getPassword()) ? teacher : null;
    }

    public TeacherBean findByEmail(String email) {
        String sql = "SELECT teacher_id, name, email, password FROM teachers WHERE email = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        } catch (SQLException e) {
            System.err.println("TeacherDAO.findByEmail failed: " + e.getMessage());
            return null;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    public TeacherBean findById(int teacherId) {
        String sql = "SELECT teacher_id, name, email, password FROM teachers WHERE teacher_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, teacherId);
            rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        } catch (SQLException e) {
            System.err.println("TeacherDAO.findById failed: " + e.getMessage());
            return null;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    private TeacherBean map(ResultSet rs) throws SQLException {
        TeacherBean t = new TeacherBean();
        t.setTeacherId(rs.getInt("teacher_id"));
        t.setName(rs.getString("name"));
        t.setEmail(rs.getString("email"));
        t.setPassword(rs.getString("password"));
        return t;
    }
}
