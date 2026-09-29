package beans;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * A student account. Follows the JavaBean rules:
 * public no-argument constructor, private fields, public get/set methods,
 * and it implements Serializable so it can be stored in the HttpSession.
 *
 * The password field always holds the SHA-256 hash, never the plain text.
 */
public class StudentBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private int studentId;
    private String name;
    private String email;
    private String password;
    private Timestamp registeredOn;

    public StudentBean() {
    }

    public StudentBean(String name, String email, String password) {
        this.name = name;
        this.email = email;
        this.password = password;
    }

    /** First name only - used for the "Welcome, Rahul" greeting. */
    public String getFirstName() {
        if (name == null || name.trim().isEmpty()) {
            return "Student";
        }
        return name.trim().split("\\s+")[0];
    }

    /** Two letters for the round avatar in the navigation bar. */
    public String getInitials() {
        if (name == null || name.trim().isEmpty()) {
            return "S";
        }
        String[] parts = name.trim().split("\\s+");
        String first = parts[0].substring(0, 1);
        String second = parts.length > 1 ? parts[parts.length - 1].substring(0, 1) : "";
        return (first + second).toUpperCase();
    }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Timestamp getRegisteredOn() { return registeredOn; }
    public void setRegisteredOn(Timestamp registeredOn) { this.registeredOn = registeredOn; }
}
