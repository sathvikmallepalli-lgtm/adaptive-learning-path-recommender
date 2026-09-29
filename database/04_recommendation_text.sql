-- Apply this once to databases created before the recommendation column
-- changed to TEXT. It keeps every existing recommendation and attempt.
USE adaptive_learning;
ALTER TABLE recommendations MODIFY COLUMN recommendation TEXT NOT NULL;
