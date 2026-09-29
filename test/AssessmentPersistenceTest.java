import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.UUID;

import beans.RecommendationBean;
import dao.AttemptDAO;
import model.Attempt;
import model.RuleResult;
import util.DBConnection;
import util.PasswordUtil;

/** Optional MySQL integration test; creates and removes one temporary student. */
public class AssessmentPersistenceTest {

    public static void main(String[] args) throws Exception {
        int studentId = -1;
        try {
            int topicId = firstTopicId();
            studentId = createStudent();
            AttemptDAO dao = new AttemptDAO();

            Attempt failedAttempt = new Attempt(studentId, topicId, Attempt.TYPE_QUIZ, 1, 10);
            RecommendationBean invalid = recommendation(-1, topicId);
            if (dao.insertWithRecommendation(failedAttempt, invalid)) {
                throw new AssertionError("A recommendation with an invalid student unexpectedly saved");
            }
            if (count("attempts", studentId) != 0 || count("recommendations", studentId) != 0) {
                throw new AssertionError("Failed recommendation did not roll back the attempt");
            }

            Attempt validAttempt = new Attempt(studentId, topicId, Attempt.TYPE_QUIZ, 1, 10);
            RecommendationBean valid = recommendation(studentId, topicId);
            if (!dao.insertWithRecommendation(validAttempt, valid)
                    || validAttempt.getAttemptId() <= 0 || valid.getRecommendationId() <= 0) {
                throw new AssertionError("Valid assessment did not save both rows");
            }
            if (count("attempts", studentId) != 1 || count("recommendations", studentId) != 1) {
                throw new AssertionError("Valid assessment saved an unexpected number of rows");
            }
            System.out.println("Assessment persistence: rollback and commit passed");
        } finally {
            if (studentId > 0) {
                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement(
                             "DELETE FROM students WHERE student_id = ?")) {
                    ps.setInt(1, studentId);
                    ps.executeUpdate();
                }
            }
        }
    }

    private static int firstTopicId() throws Exception {
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery("SELECT topic_id FROM topics ORDER BY topic_order LIMIT 1")) {
            if (!rs.next()) {
                throw new IllegalStateException("Seed at least one topic before running this test");
            }
            return rs.getInt(1);
        }
    }

    private static int createStudent() throws Exception {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO students (name, email, password) VALUES (?, ?, ?)",
                     Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, "Assessment Test");
            ps.setString(2, "assessment-" + UUID.randomUUID() + "@example.test");
            ps.setString(3, PasswordUtil.hash("temporary-test-password"));
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new IllegalStateException("No student ID was generated");
                }
                return keys.getInt(1);
            }
        }
    }

    private static RecommendationBean recommendation(int studentId, int topicId) {
        RecommendationBean rec = new RecommendationBean();
        rec.setStudentId(studentId);
        rec.setTopicId(topicId);
        rec.setRecommendationType(RuleResult.REVISION);
        rec.setRecommendation("Revise this topic and retry the quiz.");
        return rec;
    }

    private static int count(String table, int studentId) throws Exception {
        // Only literal table names from this test are passed to this helper.
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT COUNT(*) FROM " + table + " WHERE student_id = ?")) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }
}
