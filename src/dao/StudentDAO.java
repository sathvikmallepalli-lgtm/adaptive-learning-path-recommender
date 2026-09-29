package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import beans.StudentBean;
import util.DBConnection;
import util.PasswordUtil;

/**
 * All database work for the students table.
 *
 * Every query uses a PreparedStatement, so a value typed into a form can
 * never change the meaning of the SQL (no SQL injection).
 */
public class StudentDAO {

    /**
     * Saves a new student. The password inside the bean must already be
     * hashed by the servlet before this is called.
     *
     * @return the generated student_id, or -1 if the insert failed
     */
    public int register(StudentBean student) {
        String sql = "INSERT INTO students (name, email, password) VALUES (?, ?, ?)";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet keys = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, student.getName());
            ps.setString(2, student.getEmail());
            ps.setString(3, student.getPassword());

            if (ps.executeUpdate() == 0) {
                return -1;
            }
            keys = ps.getGeneratedKeys();
            if (keys.next()) {
                int id = keys.getInt(1);
                student.setStudentId(id);
                return id;
            }
            return -1;
        } catch (SQLException e) {
            System.err.println("StudentDAO.register failed: " + e.getMessage());
            return -1;
        } finally {
            DBConnection.closeAll(con, ps, keys);
        }
    }

    /**
     * Checks a login.
     *
     * @param plainPassword the password exactly as typed on the form
     * @return the student when the email and password match, otherwise null
     */
    public StudentBean authenticate(String email, String plainPassword) {
        StudentBean student = findByEmail(email);
        if (student == null) {
            return null;
        }
        if (PasswordUtil.matches(plainPassword, student.getPassword())) {
            return student;
        }
        return null;
    }

    public StudentBean findByEmail(String email) {
        String sql = "SELECT student_id, name, email, password, registered_on "
                   + "FROM students WHERE email = ?";
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
            System.err.println("StudentDAO.findByEmail failed: " + e.getMessage());
            return null;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    public StudentBean findById(int studentId) {
        String sql = "SELECT student_id, name, email, password, registered_on "
                   + "FROM students WHERE student_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, studentId);
            rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        } catch (SQLException e) {
            System.err.println("StudentDAO.findById failed: " + e.getMessage());
            return null;
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
    }

    /** Used by register.jsp to show "this email is already registered". */
    public boolean emailExists(String email) {
        return findByEmail(email) != null;
    }

    /** Every student, newest first - for the teacher screens. */
    public List<StudentBean> findAll() {
        String sql = "SELECT student_id, name, email, password, registered_on "
                   + "FROM students ORDER BY name";
        List<StudentBean> list = new ArrayList<StudentBean>();
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
            System.err.println("StudentDAO.findAll failed: " + e.getMessage());
        } finally {
            DBConnection.closeAll(con, ps, rs);
        }
        return list;
    }

    /** Copies one row of the result set into a bean. */
    private StudentBean map(ResultSet rs) throws SQLException {
        StudentBean s = new StudentBean();
        s.setStudentId(rs.getInt("student_id"));
        s.setName(rs.getString("name"));
        s.setEmail(rs.getString("email"));
        s.setPassword(rs.getString("password"));
        s.setRegisteredOn(rs.getTimestamp("registered_on"));
        return s;
    }
}
