package beans;

import java.io.Serializable;

/**
 * A teacher account. Teachers are created by the seed script, so there is
 * no registration screen for them.
 */
public class TeacherBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private int teacherId;
    private String name;
    private String email;
    private String password;    // SHA-256 hash

    public TeacherBean() {
    }

    public String getFirstName() {
        if (name == null || name.trim().isEmpty()) {
            return "Teacher";
        }
        return name.trim().split("\\s+")[0];
    }

    public String getInitials() {
        if (name == null || name.trim().isEmpty()) {
            return "T";
        }
        String[] parts = name.trim().split("\\s+");
        String first = parts[0].substring(0, 1);
        String second = parts.length > 1 ? parts[parts.length - 1].substring(0, 1) : "";
        return (first + second).toUpperCase();
    }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
