package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Turns a plain text password into a SHA-256 hex string.
 *
 * Passwords are never stored in the database as plain text. When a student
 * registers we store the hash; when the student logs in we hash what was
 * typed and compare the two hashes.
 *
 * MessageDigest is part of the JDK, so no extra library is needed.
 */
public class PasswordUtil {

    private PasswordUtil() {
    }

    /**
     * @param plainPassword the password typed by the user
     * @return a 64 character lowercase hex string, or null if the input is null
     */
    public static String hash(String plainPassword) {
        if (plainPassword == null) {
            return null;
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(plainPassword.getBytes(StandardCharsets.UTF_8));

            // Convert the 32 bytes into 64 hex characters
            StringBuilder hex = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) {
                String h = Integer.toHexString(0xff & b);
                if (h.length() == 1) {
                    hex.append('0');       // keep every byte two characters wide
                }
                hex.append(h);
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            // SHA-256 is guaranteed to exist in every Java version
            throw new IllegalStateException("SHA-256 algorithm not available", e);
        }
    }

    /**
     * @param plainPassword what the user just typed
     * @param storedHash    the 64 character hash read from the database
     * @return true when they match
     */
    public static boolean matches(String plainPassword, String storedHash) {
        String h = hash(plainPassword);
        return h != null && h.equalsIgnoreCase(storedHash);
    }
}
