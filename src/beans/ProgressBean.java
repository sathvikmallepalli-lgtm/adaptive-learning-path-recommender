package beans;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import model.TopicProgress;

/**
 * The whole learning path of one student, ready for progress.jsp and
 * modules.jsp to display.
 *
 * The Recommendation Engine fills the list of TopicProgress objects; the
 * summary numbers below are worked out here, in the business layer, so the
 * JSP only has to print them.
 */
public class ProgressBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private int studentId;
    private List<TopicProgress> topics = new ArrayList<TopicProgress>();

    public ProgressBean() {
    }

    public int getTotalTopics() {
        return topics == null ? 0 : topics.size();
    }

    /** A topic counts as completed once the best quiz score reaches 50. */
    public int getCompletedTopics() {
        int n = 0;
        for (TopicProgress t : topics) {
            if (t.getBestQuizScore() >= 50) {
                n++;
            }
        }
        return n;
    }

    public int getUnlockedTopics() {
        int n = 0;
        for (TopicProgress t : topics) {
            if (t.isUnlocked()) {
                n++;
            }
        }
        return n;
    }

    public int getGoldenPassedCount() {
        int n = 0;
        for (TopicProgress t : topics) {
            if (t.isGoldenPassed()) {
                n++;
            }
        }
        return n;
    }

    public int getTotalQuizAttempts() {
        int n = 0;
        for (TopicProgress t : topics) {
            n += t.getQuizAttempts();
        }
        return n;
    }

    /** Percentage of the course finished - drives the big progress bar. */
    public int getOverallPercentage() {
        if (getTotalTopics() == 0) {
            return 0;
        }
        return (int) Math.round((getCompletedTopics() * 100.0) / getTotalTopics());
    }

    /** Average of the best score of every topic actually attempted. */
    public int getAverageScore() {
        int sum = 0;
        int counted = 0;
        for (TopicProgress t : topics) {
            if (t.isAttempted()) {
                sum += t.getBestQuizScore();
                counted++;
            }
        }
        return counted == 0 ? 0 : (int) Math.round((double) sum / counted);
    }

    /** The next actionable topic, including the topic before a locked Golden gate. */
    public TopicProgress getCurrentTopic() {
        for (TopicProgress t : topics) {
            if (t.isUnlocked() && t.getBestQuizScore() < 50) {
                return t;
            }
        }
        for (int i = 1; i < topics.size(); i++) {
            TopicProgress locked = topics.get(i);
            TopicProgress previous = topics.get(i - 1);
            if (!locked.isUnlocked() && previous.isUnlocked()) {
                return previous;
            }
        }
        return null;
    }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public List<TopicProgress> getTopics() { return topics; }
    public void setTopics(List<TopicProgress> topics) { this.topics = topics; }
}
