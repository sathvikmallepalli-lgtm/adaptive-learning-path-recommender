package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Single place where a JDBC connection to MySQL is created.
 *
 * Every DAO calls {@link #getConnection()} and closes what it opened in a
 * finally block. Connection settings come from the process environment,
 * so a public source checkout does not contain a local database password.
 */
public class DBConnection {

    /** JDBC driver class shipped inside mysql-connector-j-8.x.jar */
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    /** Database URL. The extra parameters avoid the usual MySQL 8 warnings. */
    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/adaptive_learning"
          + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static String setting(String name, String fallback) {
        String value = System.getenv(name);
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    /**
     * The driver only has to be registered once, so it is done in a static
     * block that runs the first time this class is used.
     */
    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            // If this happens the jar is missing from WEB-INF/lib
            throw new ExceptionInInitializerError(
                    "MySQL JDBC driver not found. Put mysql-connector-j-8.x.jar "
                  + "inside web/WEB-INF/lib and restart Tomcat.");
        }
    }

    /** Private constructor - this is a utility class, never an object. */
    private DBConnection() {
    }

    /**
     * @return a new connection to the adaptive_learning database
     * @throws SQLException if MySQL is not running or the login is wrong
     */
    public static Connection getConnection() throws SQLException {
        String password = System.getenv("ADAPTIVE_DB_PASSWORD");
        if (password == null) {
            throw new SQLException("Set ADAPTIVE_DB_PASSWORD before starting the app.");
        }
        return DriverManager.getConnection(
                setting("ADAPTIVE_DB_URL", DEFAULT_URL),
                setting("ADAPTIVE_DB_USER", "root"),
                password);
    }

    // -----------------------------------------------------------------
    // Close helpers. They swallow the exception on purpose: a failure while
    // closing must never hide the real error that happened earlier.
    // -----------------------------------------------------------------

    public static void close(ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                System.err.println("Could not close ResultSet: " + e.getMessage());
            }
        }
    }

    public static void close(Statement st) {
        if (st != null) {
            try {
                st.close();
            } catch (SQLException e) {
                System.err.println("Could not close Statement: " + e.getMessage());
            }
        }
    }

    public static void close(Connection con) {
        if (con != null) {
            try {
                con.close();
            } catch (SQLException e) {
                System.err.println("Could not close Connection: " + e.getMessage());
            }
        }
    }

    /** Closes all three in the correct order (result set first). */
    public static void closeAll(Connection con, Statement st, ResultSet rs) {
        close(rs);
        close(st);
        close(con);
    }
}
