-- =====================================================================
--  Adaptive Personalised Learning Path Recommender
--  ADVANCED PRACTICE QUESTIONS
--
--  Run AFTER 02_seed_data.sql :
--      mysql -u root -p < 03_advanced_practice.sql
--
--  WHY THIS FILE EXISTS
--  When a student fails the Golden Assessment the rule engine returns
--  ADVANCED_PRACTICE and tells them to work through harder practice
--  before trying again. Without these rows that advice had nowhere to
--  send them - the practice section only held EASY questions.
--
--  These are question_type = PRACTICE with difficulty = HARD, so no
--  schema change is needed. topic.jsp shows them in their own section.
--  They are deliberately DIFFERENT from the GOLDEN questions, otherwise
--  practising would just be memorising the assessment.
--
--  5 per topic x 8 topics = 40 questions.
-- =====================================================================

USE adaptive_learning;

SET @t_var  = (SELECT topic_id FROM topics WHERE title = 'Variables');
SET @t_cond = (SELECT topic_id FROM topics WHERE title = 'Conditions');
SET @t_loop = (SELECT topic_id FROM topics WHERE title = 'Loops');
SET @t_func = (SELECT topic_id FROM topics WHERE title = 'Functions');
SET @t_oop  = (SELECT topic_id FROM topics WHERE title = 'OOP');
SET @t_file = (SELECT topic_id FROM topics WHERE title = 'Files');
SET @t_exc  = (SELECT topic_id FROM topics WHERE title = 'Exception Handling');
SET @t_mod  = (SELECT topic_id FROM topics WHERE title = 'Modules');

INSERT INTO questions (topic_id, question, option_a, option_b, option_c, option_d, correct_answer, difficulty, question_type) VALUES

-- ---------------- 1. VARIABLES ----------------
(@t_var, 'What is the output of:  print(0.1 + 0.2 == 0.3)', 'False', 'True', '0.3', 'An error is raised', 'A', 'HARD', 'PRACTICE'),
(@t_var, 'What is printed by:  x = 5 ; y = x ; x = 10 ; print(y)', '10', '5', '15', 'None', 'B', 'HARD', 'PRACTICE'),
(@t_var, 'What happens with:  a = "hello" ; a[0] = "H"', 'a becomes "Hello"', 'a stays "hello" with no error', 'A TypeError is raised, strings cannot be changed', 'a becomes "H"', 'C', 'HARD', 'PRACTICE'),
(@t_var, 'What is the output of:  print(bool(0.0), bool("0"))', 'True True', 'True False', 'False False', 'False True', 'D', 'HARD', 'PRACTICE'),
(@t_var, 'What is the output of:  print(10 % 3, -10 % 3)', '1 -1', '3 3', '1 2', '1 1', 'C', 'HARD', 'PRACTICE'),

-- ---------------- 2. CONDITIONS ----------------
(@t_cond, 'What is the output of:  print([] or "default")', 'default', 'an empty list', 'True', 'None', 'A', 'HARD', 'PRACTICE'),
(@t_cond, 'What is the output of:  print(True + True)', 'True', 'An error is raised', '1', '2', 'D', 'HARD', 'PRACTICE'),
(@t_cond, 'What is the output of:  print("apple" < "banana")', 'False', 'True', 'An error is raised', 'None', 'B', 'HARD', 'PRACTICE'),
(@t_cond, 'What is the output of:  x = 0 ; print("yes" if x else "no")', 'yes', 'no', '0', 'An error is raised', 'B', 'HARD', 'PRACTICE'),
(@t_cond, 'In  a and b  , when a is False, is b evaluated?', 'Yes, always', 'It raises an error', 'Only if b is a function', 'No, Python stops early', 'D', 'HARD', 'PRACTICE'),

-- ---------------- 3. LOOPS ----------------
(@t_loop, 'How many times does the body run in:  for i in range(0)', 'never', 'once', 'infinitely', 'It raises an error', 'A', 'HARD', 'PRACTICE'),
(@t_loop, 'What is the value of the sum of range(1, 101)?', '5000', '4950', '5050', '10100', 'C', 'HARD', 'PRACTICE'),
(@t_loop, 'What does  list(enumerate(["a", "b"]))  produce?', '["a", "b"]', '[0, 1]', '[(1, "a"), (2, "b")]', '[(0, "a"), (1, "b")]', 'D', 'HARD', 'PRACTICE'),
(@t_loop, 'A break inside a loop that is nested inside another loop leaves', 'both loops', 'only the outer loop', 'only the inner loop', 'the whole function', 'C', 'HARD', 'PRACTICE'),
(@t_loop, 'What is printed by:  for i in range(3): pass    then    print(i * 2)', '0', '4', '6', 'A name error is raised', 'B', 'HARD', 'PRACTICE'),

-- ---------------- 4. FUNCTIONS ----------------
(@t_func, 'What is the output of:  print((lambda x, y=2: x * y)(3))', '6', '3', '2', 'An error is raised', 'A', 'HARD', 'PRACTICE'),
(@t_func, 'Given  def f(*a): return len(a)  what does  f(1, 2, 3)  return?', '3', '1', '6', 'An error is raised', 'A', 'HARD', 'PRACTICE'),
(@t_func, 'When is the default value of a parameter evaluated?', 'Every time the function is called', 'Once, when the function is defined', 'Only on the first call', 'Never', 'B', 'HARD', 'PRACTICE'),
(@t_func, 'What does  print(f())  show for  def f(): pass  ?', 'nothing at all', '0', 'None', 'An error is raised', 'C', 'HARD', 'PRACTICE'),
(@t_func, 'A function assigns to a variable that also exists outside it, without using global. What happens outside?', 'The outer variable changes', 'The outer variable is deleted', 'An error is raised', 'The outer variable is unchanged', 'D', 'HARD', 'PRACTICE'),

-- ---------------- 5. OOP ----------------
(@t_oop, 'What happens if the constructor returns a value other than None?', 'It is ignored', 'The value becomes the object', 'A TypeError is raised', 'The class is deleted', 'C', 'HARD', 'PRACTICE'),
(@t_oop, 'A variable named __balance inside a class is actually stored under which name?', 'the class name joined to it, such as _Account__balance', '__balance', 'balance', 'It is not stored at all', 'A', 'HARD', 'PRACTICE'),
(@t_oop, 'What is the difference between a class attribute and an instance attribute?', 'There is none', 'An instance attribute is shared by every object', 'A class attribute cannot be read', 'A class attribute is shared by every object, an instance attribute belongs to one object', 'D', 'HARD', 'PRACTICE'),
(@t_oop, 'Which is true of  type(obj) == Person  compared with  isinstance(obj, Person)  ?', 'They always agree', 'isinstance also returns True for objects of a child class', 'type() also returns True for a child class', 'Neither works with inheritance', 'B', 'HARD', 'PRACTICE'),
(@t_oop, 'What does a method decorated with @staticmethod NOT receive?', 'any arguments', 'the self parameter', 'a return value', 'access to the module', 'B', 'HARD', 'PRACTICE'),

-- ---------------- 6. FILES ----------------
(@t_file, 'After a  with open(...) as f  block ends, what is the state of f?', 'still open', 'reopened in append mode', 'deleted', 'closed automatically', 'D', 'HARD', 'PRACTICE'),
(@t_file, 'What happens when you call read() on a file opened in w mode?', 'An UnsupportedOperation error is raised', 'It returns the file content', 'It returns an empty string', 'It switches the file to r mode', 'A', 'HARD', 'PRACTICE'),
(@t_file, 'Do the strings returned by readlines() keep the newline character at the end?', 'No, they are stripped', 'Only the last line keeps it', 'Yes, each line keeps its newline', 'Only in binary mode', 'C', 'HARD', 'PRACTICE'),
(@t_file, 'Where is the file pointer when a file is opened in a mode?', 'at the beginning', 'the file is emptied first', 'in the middle', 'at the end of the existing content', 'D', 'HARD', 'PRACTICE'),
(@t_file, 'What is the default mode of  open("data.txt")  when no mode is given?', 'w', 'a', 'r', 'rb', 'C', 'HARD', 'PRACTICE'),

-- ---------------- 7. EXCEPTION HANDLING ----------------
(@t_exc, 'A bare  raise  written inside an except block does what?', 'starts a new blank exception', 'raises the exception that is currently being handled', 'stops the program silently', 'is a syntax error', 'B', 'HARD', 'PRACTICE'),
(@t_exc, 'Which exception does a failed  assert  statement raise?', 'AssertionError', 'ValueError', 'TypeError', 'RuntimeError', 'A', 'HARD', 'PRACTICE'),
(@t_exc, 'An exception is raised inside a try block that is nested in another try. Which except is checked first?', 'the inner one', 'the outer one', 'both at the same time', 'neither', 'A', 'HARD', 'PRACTICE'),
(@t_exc, 'What does  except Exception as e:  followed by  print(e)  display?', 'the line number only', 'the error message carried by the exception', 'the whole traceback', 'nothing', 'B', 'HARD', 'PRACTICE'),
(@t_exc, 'Can a finally block change the value that a try block already decided to return?', 'No, never', 'Only for integers', 'Yes, if finally has its own return statement', 'It raises an error', 'C', 'HARD', 'PRACTICE'),

-- ---------------- 8. MODULES ----------------
(@t_mod, 'What is stored inside the __pycache__ folder?', 'the source code', 'installed packages', 'error logs', 'the compiled bytecode of imported modules', 'D', 'HARD', 'PRACTICE'),
(@t_mod, 'What does the dictionary sys.modules hold?', 'every installed package', 'the search path', 'the modules already imported in this program', 'the standard library', 'C', 'HARD', 'PRACTICE'),
(@t_mod, 'A module defines a list named __all__. What does it control?', 'which names  from module import *  brings in', 'the order of the functions', 'the module version', 'nothing at all', 'A', 'HARD', 'PRACTICE'),
(@t_mod, 'What does a leading dot mean in  from .helper import clean  ?', 'a hidden module', 'a syntax error', 'a private function', 'a relative import from the same package', 'D', 'HARD', 'PRACTICE'),
(@t_mod, 'A module was edited while the program is still running. What brings in the new version without restarting?', 'importing it a second time', 'importlib.reload(module)', 'deleting the variable', 'nothing, a restart is required', 'B', 'HARD', 'PRACTICE');

-- Verification
-- SELECT difficulty, COUNT(*) FROM questions WHERE question_type='PRACTICE' GROUP BY difficulty;
--   expect EASY 40, HARD 40
