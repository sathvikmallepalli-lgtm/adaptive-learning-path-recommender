package util;

/**
 * Server side input validation.
 *
 * JavaScript validation in the browser is only for convenience - it can be
 * switched off. Every value that arrives from a form is checked again here
 * before it is used.
 */
public class Validator {

    /** Very simple email pattern: something@something.something */
    private static final String EMAIL_PATTERN =
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";

    public static final int MIN_PASSWORD_LENGTH = 6;

    private Validator() {
    }

    /** @return true when the value is null or contains only spaces */
    public static boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    /** Trims a value and turns null into an empty string. */
    public static String clean(String value) {
        return value == null ? "" : value.trim();
    }

    public static boolean isValidName(String name) {
        String n = clean(name);
        return n.length() >= 2 && n.length() <= 100;
    }

    public static boolean isValidEmail(String email) {
        String e = clean(email);
        return e.length() <= 100 && e.matches(EMAIL_PATTERN);
    }

    public static boolean isValidPassword(String password) {
        return password != null && password.length() >= MIN_PASSWORD_LENGTH;
    }

    /** Answers may only ever be A, B, C or D. */
    public static boolean isValidOption(String answer) {
        return answer != null
            && answer.length() == 1
            && "ABCD".indexOf(answer.toUpperCase()) >= 0;
    }

    /**
     * Safely converts a request parameter to an int.
     *
     * @param value        the text from the form or the URL
     * @param defaultValue returned when the text is missing or not a number
     */
    public static int toInt(String value, int defaultValue) {
        if (isEmpty(value)) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * Escapes the five characters that would otherwise break the HTML page
     * or allow a script to be injected. Every value that came from a user
     * is passed through this before being printed in a JSP.
     */
    public static String escapeHtml(String text) {
        if (text == null) {
            return "";
        }
        StringBuilder out = new StringBuilder(text.length());
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            switch (c) {
                case '&':  out.append("&amp;");  break;
                case '<':  out.append("&lt;");   break;
                case '>':  out.append("&gt;");   break;
                case '"':  out.append("&quot;"); break;
                case '\'': out.append("&#39;");  break;
                default:   out.append(c);
            }
        }
        return out.toString();
    }
}
