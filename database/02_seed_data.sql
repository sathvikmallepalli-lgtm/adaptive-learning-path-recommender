-- =====================================================================
--  Adaptive Personalised Learning Path Recommender
--  Step 3(b) : SEED DATA
--
--  Run AFTER 01_schema.sql :   mysql -u root -p < 02_seed_data.sql
--
--  Contents
--    * 2 teacher accounts
--    * 2 demo student accounts
--    * 8 topics with notes
--    * 160 questions  (per topic: 5 PRACTICE + 10 QUIZ + 5 GOLDEN)
--
--  Demo logins  (passwords are stored as SHA-256, shown here in plain
--               text only so the project can be demonstrated)
--    Teacher : anita.rao@college.edu   / teacher123
--    Teacher : vikram.nair@college.edu / teacher123
--    Student : rahul@student.edu       / student123
--    Student : sneha@student.edu       / student123
-- =====================================================================

USE adaptive_learning;


-- ---------------------------------------------------------------------
-- Teachers   (password = teacher123)
-- ---------------------------------------------------------------------
INSERT INTO teachers (name, email, password) VALUES
('Anita Rao',   'anita.rao@college.edu',   'cde383eee8ee7a4400adf7a15f716f179a2eb97646b37e089eb8d6d04e663416'),
('Vikram Nair', 'vikram.nair@college.edu', 'cde383eee8ee7a4400adf7a15f716f179a2eb97646b37e089eb8d6d04e663416');


-- ---------------------------------------------------------------------
-- Demo students   (password = student123)
-- ---------------------------------------------------------------------
INSERT INTO students (name, email, password) VALUES
('Rahul Sharma', 'rahul@student.edu', '703b0a3d6ad75b649a28adde7d83c6251da457549263bc7ff45ec709b0a8448b'),
('Sneha Patil',  'sneha@student.edu', '703b0a3d6ad75b649a28adde7d83c6251da457549263bc7ff45ec709b0a8448b');


-- ---------------------------------------------------------------------
-- Topics 1 - 8
-- Topics 1-4 are BASIC, topics 5-8 are ADVANCED.
-- The notes column holds simple HTML that topic.jsp renders directly.
-- ---------------------------------------------------------------------
INSERT INTO topics (title, description, difficulty, topic_order, notes) VALUES
('Variables',
 'Storing data in memory using names, and the built-in data types of Python.',
 'BASIC', 1,
 '<h4>What is a Variable?</h4>
  <p>A variable is a name that refers to a value stored in memory. Python does not need a type declaration - the type is decided by the value you assign.</p>
  <pre>name = "Rahul"      # str
age  = 19            # int
cgpa = 8.75          # float
passed = True        # bool</pre>
  <h4>Rules for naming</h4>
  <ul>
    <li>Must start with a letter or an underscore.</li>
    <li>Can contain letters, digits and underscores only.</li>
    <li>Names are case sensitive: <code>age</code> and <code>Age</code> are different.</li>
    <li>Reserved keywords such as <code>if</code>, <code>for</code>, <code>class</code> cannot be used.</li>
  </ul>
  <h4>Checking and changing the type</h4>
  <pre>x = 10
print(type(x))       # &lt;class int&gt;
y = str(x)           # type casting, y is now "10"</pre>
  <h4>Multiple assignment</h4>
  <pre>a, b, c = 1, 2, 3
p = q = 0</pre>
  <p>Python variables are references. Assigning one variable to another makes both names point at the same object.</p>'),

('Conditions',
 'Making decisions in a program using if, elif and else.',
 'BASIC', 2,
 '<h4>The if statement</h4>
  <p>A condition is an expression that evaluates to <code>True</code> or <code>False</code>. The indented block runs only when the condition is True.</p>
  <pre>marks = 72
if marks &gt;= 40:
    print("Pass")</pre>
  <h4>if - else</h4>
  <pre>if marks &gt;= 40:
    print("Pass")
else:
    print("Fail")</pre>
  <h4>if - elif - else</h4>
  <pre>if marks &gt;= 75:
    grade = "Distinction"
elif marks &gt;= 60:
    grade = "First Class"
elif marks &gt;= 40:
    grade = "Pass"
else:
    grade = "Fail"</pre>
  <h4>Operators you will use</h4>
  <ul>
    <li>Comparison: <code>== != &gt; &lt; &gt;= &lt;=</code></li>
    <li>Logical: <code>and</code>, <code>or</code>, <code>not</code></li>
    <li>Membership: <code>in</code>, <code>not in</code></li>
  </ul>
  <p><b>Important:</b> indentation is not decoration in Python - it is what defines the block. Mixing tabs and spaces causes errors.</p>'),

('Loops',
 'Repeating work with for and while loops, and controlling them with break and continue.',
 'BASIC', 3,
 '<h4>The for loop</h4>
  <p>A <code>for</code> loop walks through the items of a sequence.</p>
  <pre>for subject in ["Maths", "Physics", "WT"]:
    print(subject)

for i in range(5):        # 0 1 2 3 4
    print(i)

for i in range(1, 11, 2): # 1 3 5 7 9
    print(i)</pre>
  <h4>The while loop</h4>
  <p>A <code>while</code> loop repeats as long as its condition stays True.</p>
  <pre>n = 5
fact = 1
while n &gt; 0:
    fact = fact * n
    n = n - 1
print(fact)               # 120</pre>
  <h4>break, continue and else</h4>
  <ul>
    <li><code>break</code> leaves the loop immediately.</li>
    <li><code>continue</code> skips to the next repetition.</li>
    <li>A loop may have an <code>else</code> block that runs only if the loop finished without a break.</li>
  </ul>
  <h4>Nested loops</h4>
  <pre>for i in range(1, 4):
    for j in range(1, 4):
        print(i * j, end=" ")
    print()</pre>'),

('Functions',
 'Writing reusable blocks of code with parameters, return values and scope.',
 'BASIC', 4,
 '<h4>Defining and calling</h4>
  <pre>def greet(name):
    return "Hello " + name

message = greet("Sneha")
print(message)</pre>
  <h4>Parameters</h4>
  <ul>
    <li><b>Positional:</b> matched by order.</li>
    <li><b>Default:</b> <code>def area(l, b=1)</code> - b may be omitted.</li>
    <li><b>Keyword:</b> <code>area(b=4, l=3)</code> - matched by name.</li>
    <li><b>Variable length:</b> <code>*args</code> collects extra positional values, <code>**kwargs</code> collects extra keyword values.</li>
  </ul>
  <pre>def total(*numbers):
    s = 0
    for n in numbers:
        s = s + n
    return s

print(total(1, 2, 3, 4))   # 10</pre>
  <h4>Scope</h4>
  <p>A variable created inside a function is <b>local</b> and disappears when the function ends. Use the <code>global</code> keyword only when you really must change a module level variable.</p>
  <h4>Lambda</h4>
  <pre>square = lambda x: x * x
print(square(6))           # 36</pre>
  <p>A function that has no <code>return</code> statement returns <code>None</code>.</p>'),

('OOP',
 'Classes, objects, constructors, inheritance and polymorphism in Python.',
 'ADVANCED', 5,
 '<h4>Class and object</h4>
  <p>A class is a blueprint. An object is one instance built from that blueprint.</p>
  <pre>class Student:
    def __init__(self, name, marks):   # constructor
        self.name  = name
        self.marks = marks

    def display(self):
        print(self.name, self.marks)

s1 = Student("Rahul", 88)
s1.display()</pre>
  <h4>self</h4>
  <p><code>self</code> is the reference to the current object. It is the first parameter of every instance method and Python passes it automatically.</p>
  <h4>The four pillars</h4>
  <ul>
    <li><b>Encapsulation</b> - data and the methods that work on it live together. A name written as <code>__balance</code> is treated as private.</li>
    <li><b>Inheritance</b> - a child class reuses a parent class.</li>
    <li><b>Polymorphism</b> - the same method name behaves differently in different classes (method overriding).</li>
    <li><b>Abstraction</b> - hide the implementation, expose only what is needed.</li>
  </ul>
  <pre>class Person:
    def show(self):
        print("I am a person")

class Teacher(Person):          # inheritance
    def show(self):             # overriding
        print("I am a teacher")

Teacher().show()                # I am a teacher</pre>'),

('Files',
 'Reading from and writing to files, file modes and the with statement.',
 'ADVANCED', 6,
 '<h4>Opening a file</h4>
  <pre>f = open("data.txt", "r")
content = f.read()
f.close()</pre>
  <h4>File modes</h4>
  <ul>
    <li><code>r</code> - read, error if the file does not exist.</li>
    <li><code>w</code> - write, creates the file, <b>erases existing content</b>.</li>
    <li><code>a</code> - append, adds at the end, creates the file if needed.</li>
    <li><code>r+</code> - read and write.</li>
    <li>Add <code>b</code> for binary files, for example <code>rb</code>.</li>
  </ul>
  <h4>The with statement (recommended)</h4>
  <p><code>with</code> closes the file automatically, even if an error occurs.</p>
  <pre>with open("marks.txt", "w") as f:
    f.write("Rahul,88\\n")
    f.write("Sneha,92\\n")

with open("marks.txt", "r") as f:
    for line in f:
        print(line.strip())</pre>
  <h4>Useful methods</h4>
  <ul>
    <li><code>read()</code> - whole file as one string.</li>
    <li><code>readline()</code> - one line.</li>
    <li><code>readlines()</code> - a list of all lines.</li>
    <li><code>write()</code> / <code>writelines()</code> - write text.</li>
  </ul>'),

('Exception Handling',
 'Handling runtime errors safely with try, except, else and finally.',
 'ADVANCED', 7,
 '<h4>Why handle exceptions?</h4>
  <p>An exception is an error detected while the program is running. If it is not handled the program stops. Handling it lets the program recover and show a clear message.</p>
  <pre>try:
    n = int(input("Enter a number: "))
    print(100 / n)
except ValueError:
    print("That was not a number")
except ZeroDivisionError:
    print("Cannot divide by zero")
else:
    print("Calculation finished")
finally:
    print("This always runs")</pre>
  <h4>The blocks</h4>
  <ul>
    <li><code>try</code> - the code that might fail.</li>
    <li><code>except</code> - runs when a matching error occurs.</li>
    <li><code>else</code> - runs only when no exception occurred.</li>
    <li><code>finally</code> - always runs, used to release resources.</li>
  </ul>
  <h4>Common built-in exceptions</h4>
  <p><code>ValueError</code>, <code>TypeError</code>, <code>ZeroDivisionError</code>, <code>IndexError</code>, <code>KeyError</code>, <code>FileNotFoundError</code></p>
  <h4>Raising your own</h4>
  <pre>def set_age(age):
    if age &lt; 0:
        raise ValueError("Age cannot be negative")
    return age</pre>'),

('Modules',
 'Splitting a program into modules and packages, and importing them.',
 'ADVANCED', 8,
 '<h4>What is a module?</h4>
  <p>A module is simply a <code>.py</code> file containing functions, classes and variables that can be reused in another file.</p>
  <pre># file: calc.py
def add(a, b):
    return a + b

PI = 3.14159</pre>
  <h4>Importing</h4>
  <pre>import calc
print(calc.add(2, 3))

from calc import add, PI
print(add(2, 3))

import calc as c              # alias
from calc import *            # imports everything (avoid this)</pre>
  <h4>Standard library modules</h4>
  <ul>
    <li><code>math</code> - sqrt, pow, factorial, pi</li>
    <li><code>random</code> - randint, choice, shuffle</li>
    <li><code>datetime</code> - date and time handling</li>
    <li><code>os</code> - files and folders</li>
  </ul>
  <h4>Packages</h4>
  <p>A package is a folder of modules. Older versions of Python required an <code>__init__.py</code> file to mark the folder as a package.</p>
  <pre>if __name__ == "__main__":
    print("Running directly, not imported")</pre>');


-- =====================================================================
--  QUESTIONS
--  Topic ids are looked up by title so this script keeps working even
--  if the AUTO_INCREMENT values are different on another machine.
-- =====================================================================
SET @t_var  = (SELECT topic_id FROM topics WHERE title = 'Variables');
SET @t_cond = (SELECT topic_id FROM topics WHERE title = 'Conditions');
SET @t_loop = (SELECT topic_id FROM topics WHERE title = 'Loops');
SET @t_func = (SELECT topic_id FROM topics WHERE title = 'Functions');
SET @t_oop  = (SELECT topic_id FROM topics WHERE title = 'OOP');
SET @t_file = (SELECT topic_id FROM topics WHERE title = 'Files');
SET @t_exc  = (SELECT topic_id FROM topics WHERE title = 'Exception Handling');
SET @t_mod  = (SELECT topic_id FROM topics WHERE title = 'Modules');


-- ---------------------------------------------------------------------
-- TOPIC 1 : VARIABLES
-- ---------------------------------------------------------------------
INSERT INTO questions (topic_id, question, option_a, option_b, option_c, option_d, correct_answer, difficulty, question_type) VALUES
-- Practice
(@t_var, 'Which of these is a valid variable name in Python?', 'my_marks', '2marks', 'my marks', 'class', 'A', 'EASY', 'PRACTICE'),
(@t_var, 'What is the data type of the value assigned by  x = 3.5 ?', 'int', 'float', 'str', 'bool', 'B', 'EASY', 'PRACTICE'),
(@t_var, 'Which built-in function tells you the data type of a variable?', 'typeof()', 'datatype()', 'type()', 'gettype()', 'C', 'EASY', 'PRACTICE'),
(@t_var, 'Which of these values is of type bool?', 'the text "True"', 'the number 1', 'the list [True]', 'True', 'D', 'EASY', 'PRACTICE'),
(@t_var, 'What does the statement  x = y = 5  do?', 'Only x becomes 5', 'Only y becomes 5', 'Both x and y become 5', 'It causes a syntax error', 'C', 'EASY', 'PRACTICE'),
-- Quiz
(@t_var, 'Python is a dynamically typed language. What does this mean?', 'The type of a variable is decided by the value assigned to it', 'The type must be written before every variable', 'All variables are of type string', 'Types cannot change at run time', 'A', 'EASY', 'QUIZ'),
(@t_var, 'Which of these is NOT a valid variable name?', 'total_marks', '_count', 'rankOne', '1st_rank', 'D', 'EASY', 'QUIZ'),
(@t_var, 'After  x = "10"  and  y = int(x) , what is the type of y?', 'str', 'int', 'float', 'It raises an error', 'B', 'EASY', 'QUIZ'),
(@t_var, 'What is the output of:  a = 5 ; b = 2 ; print(a // b)', '2.5', '2', '3', '2.0', 'B', 'MEDIUM', 'QUIZ'),
(@t_var, 'Which of these CANNOT be used as a variable name because it is a keyword?', 'marks', 'value', 'total', 'for', 'D', 'EASY', 'QUIZ'),
(@t_var, 'What happens when you run:  a = 10  and then  a = "ten"  ?', 'a now refers to a string', 'A type error is raised', 'a stays an integer', 'Python prints a warning', 'A', 'MEDIUM', 'QUIZ'),
(@t_var, 'What is the data type of the result of  10 / 2  in Python 3?', 'int', 'str', 'float', 'bool', 'C', 'MEDIUM', 'QUIZ'),
(@t_var, 'Which symbol starts a single line comment in Python?', '//', '/* */', 'the HTML comment tag', '#', 'D', 'EASY', 'QUIZ'),
(@t_var, 'What is the value of x after:  x = 7 ; x += 3', '7', '73', '10', '3', 'C', 'EASY', 'QUIZ'),
(@t_var, 'Variable names in Python are', 'case insensitive', 'case sensitive', 'always uppercase', 'always lowercase', 'B', 'EASY', 'QUIZ'),
-- Golden
(@t_var, 'What is printed by:  a = [1, 2, 3] ; b = a ; b.append(4) ; print(len(a))', '4', '3', '0', 'An error is raised', 'A', 'HARD', 'GOLDEN'),
(@t_var, 'What is the output of:  print(type(5) == type(5.0))', 'False', 'True', 'None', 'An error is raised', 'A', 'HARD', 'GOLDEN'),
(@t_var, 'Which statement about Python variables is correct?', 'A variable stores the value directly inside itself', 'A variable is a name that refers to an object in memory', 'A variable must be declared with its type before use', 'A variable can hold only one data type for its whole life', 'B', 'HARD', 'GOLDEN'),
(@t_var, 'What is printed by:  a, b = 1, 2 ; a, b = b, a ; print(a)', '1', '3', '2', 'An error is raised', 'C', 'HARD', 'GOLDEN'),
(@t_var, 'What is the output of:  print("5" * 3)', '15', 'A type error is raised', '5 5 5', '555', 'D', 'HARD', 'GOLDEN');


-- ---------------------------------------------------------------------
-- TOPIC 2 : CONDITIONS
-- ---------------------------------------------------------------------
INSERT INTO questions (topic_id, question, option_a, option_b, option_c, option_d, correct_answer, difficulty, question_type) VALUES
-- Practice
(@t_cond, 'Which keyword begins a conditional statement in Python?', 'when', 'check', 'if', 'cond', 'C', 'EASY', 'PRACTICE'),
(@t_cond, 'Which symbol must appear at the end of an if condition line?', 'a colon', 'a semicolon', 'a full stop', 'nothing', 'A', 'EASY', 'PRACTICE'),
(@t_cond, 'What is the Python keyword for "else if"?', 'elseif', 'elsif', 'else if', 'elif', 'D', 'EASY', 'PRACTICE'),
(@t_cond, 'What decides which statements belong to an if block?', 'curly braces', 'indentation', 'a semicolon', 'parentheses', 'B', 'EASY', 'PRACTICE'),
(@t_cond, 'Which operator checks whether two values are equal?', 'a single =', 'a double ==', 'a triple ===', 'the word eq', 'B', 'EASY', 'PRACTICE'),
-- Quiz
(@t_cond, 'What is the output of:  print(10 > 5 and 5 > 10)', 'True', 'An error is raised', 'None', 'False', 'D', 'EASY', 'QUIZ'),
(@t_cond, 'Which of these is the logical AND operator in Python?', 'and', 'the double ampersand', 'a single ampersand', 'AND in capitals', 'A', 'EASY', 'QUIZ'),
(@t_cond, 'What does this print:  if 0: print("A")  else: print("B")', 'A', 'Nothing', 'B', 'An error is raised', 'C', 'MEDIUM', 'QUIZ'),
(@t_cond, 'Which of these values is treated as False in a condition?', 'the text "0"', 'the number -1', 'the text "False"', 'an empty list', 'D', 'MEDIUM', 'QUIZ'),
(@t_cond, 'What does this print:  x = 5 ; print("yes" if x > 3 else "no")', 'True', 'no', 'yes', 'An error is raised', 'C', 'MEDIUM', 'QUIZ'),
(@t_cond, 'What is the value of:  not (True and False)', 'False', 'True', 'None', 'An error is raised', 'B', 'MEDIUM', 'QUIZ'),
(@t_cond, 'Which line is written correctly?', 'if x == 5:', 'if x = 5:', 'if (x = 5)', 'if x equals 5:', 'A', 'EASY', 'QUIZ'),
(@t_cond, 'How many elif blocks may follow a single if?', 'any number', 'at most two', 'exactly one', 'none if else is used', 'A', 'EASY', 'QUIZ'),
(@t_cond, 'What is the output of:  print(3 in [1, 2, 3])', 'False', 'True', '3', 'An error is raised', 'B', 'EASY', 'QUIZ'),
(@t_cond, 'To write an if inside another if, the inner block must be', 'written on the same line', 'placed in curly braces', 'indented one level deeper', 'ended with a semicolon', 'C', 'EASY', 'QUIZ'),
-- Golden
(@t_cond, 'What is the output of:  print(1 == True)', 'None', 'False', 'An error is raised', 'True', 'D', 'HARD', 'GOLDEN'),
(@t_cond, 'With x = 15, what value does r get:  if x > 10: r = "High"  elif x > 5: r = "Medium"  else: r = "Low"', 'Low', 'Medium', 'High', 'Both High and Medium', 'C', 'HARD', 'GOLDEN'),
(@t_cond, 'What is the output of:  print(bool("False"))', 'True', 'False', 'An error is raised', 'None', 'A', 'HARD', 'GOLDEN'),
(@t_cond, 'What is the output of the chained comparison:  print(5 > 3 > 1)', '5', 'False', 'A syntax error', 'True', 'D', 'HARD', 'GOLDEN'),
(@t_cond, 'What is the output of:  print(None == False)', 'True', 'False', 'None', 'An error is raised', 'B', 'HARD', 'GOLDEN');


-- ---------------------------------------------------------------------
-- TOPIC 3 : LOOPS
-- ---------------------------------------------------------------------
INSERT INTO questions (topic_id, question, option_a, option_b, option_c, option_d, correct_answer, difficulty, question_type) VALUES
-- Practice
(@t_loop, 'What sequence of numbers does range(5) produce?', '1 to 5', '0 to 4', '0 to 5', '1 to 4', 'B', 'EASY', 'PRACTICE'),
(@t_loop, 'Which loop is normally used when the number of repetitions is already known?', 'while', 'repeat', 'do while', 'for', 'D', 'EASY', 'PRACTICE'),
(@t_loop, 'What does the break statement do?', 'Leaves the loop immediately', 'Skips the current repetition', 'Restarts the loop', 'Ends the program', 'A', 'EASY', 'PRACTICE'),
(@t_loop, 'What does the continue statement do?', 'Leaves the loop', 'Pauses the program', 'Skips to the next repetition', 'Repeats the same value again', 'C', 'EASY', 'PRACTICE'),
(@t_loop, 'A while loop keeps running as long as its condition is', 'False', 'None', 'zero', 'True', 'D', 'EASY', 'PRACTICE'),
-- Quiz
(@t_loop, 'How many times does the body run in:  for i in range(1, 5)', '3', '5', '4', '6', 'C', 'EASY', 'QUIZ'),
(@t_loop, 'Which numbers does range(2, 10, 3) produce?', '2 4 6 8', '2 5 8', '3 6 9', '2 5 8 11', 'B', 'MEDIUM', 'QUIZ'),
(@t_loop, 'What is printed by:  for i in range(3): print(i, end="")', '012', '123', '0 1 2', '0123', 'A', 'MEDIUM', 'QUIZ'),
(@t_loop, 'What happens with  while True:  and no break inside the loop?', 'It runs forever', 'It never runs', 'It runs once', 'It raises an error', 'A', 'EASY', 'QUIZ'),
(@t_loop, 'How do you loop over the keys of a dictionary d?', 'for k in d.values()', 'for k in d', 'for k in range(d)', 'for k of d', 'B', 'MEDIUM', 'QUIZ'),
(@t_loop, 'When does the else block of a for loop run?', 'Always', 'Only if the loop body never ran', 'Only if the loop finished without a break', 'Only if a break was used', 'C', 'MEDIUM', 'QUIZ'),
(@t_loop, 'What is the sum of all values produced by range(1, 4)?', '4', '3', '10', '6', 'D', 'EASY', 'QUIZ'),
(@t_loop, 'A loop of 3 repetitions contains a loop of 2 repetitions. How many times does the inner body run in total?', '3', '5', '6', '2', 'C', 'MEDIUM', 'QUIZ'),
(@t_loop, 'What is the output of:  print(len(range(0, 10, 2)))', '5', '4', '6', '10', 'A', 'MEDIUM', 'QUIZ'),
(@t_loop, 'Using continue inside a while loop can cause an endless loop when', 'the condition is True', 'the loop is nested', 'break is also used', 'the statement that updates the counter gets skipped', 'D', 'MEDIUM', 'QUIZ'),
-- Golden
(@t_loop, 'What is printed by:  for i in range(5, 0, -1): print(i, end=" ")', '5 4 3 2 1 0', '5 4 3 2 1', '1 2 3 4 5', 'Nothing', 'B', 'HARD', 'GOLDEN'),
(@t_loop, 'What is printed by:  i = 0  while i < 3: i += 1   else: print("done")', 'Nothing', 'done', 'An error is raised', 'done printed three times', 'B', 'HARD', 'GOLDEN'),
(@t_loop, 'What is printed by:  for i in range(3): pass    then    print(i)', '0', 'A name error is raised', '3', '2', 'D', 'HARD', 'GOLDEN'),
(@t_loop, 'What is the length of  list(range(3)) * 2 ?', '6', '3', '2', '5', 'A', 'HARD', 'GOLDEN'),
(@t_loop, 'A for loop has an else block and the loop exits because of a break. What happens to the else block?', 'It runs after the break', 'It runs before the break', 'It is skipped', 'An error is raised', 'C', 'HARD', 'GOLDEN');


-- ---------------------------------------------------------------------
-- TOPIC 4 : FUNCTIONS
-- ---------------------------------------------------------------------
INSERT INTO questions (topic_id, question, option_a, option_b, option_c, option_d, correct_answer, difficulty, question_type) VALUES
-- Practice
(@t_func, 'Which keyword is used to define a function in Python?', 'function', 'fun', 'define', 'def', 'D', 'EASY', 'PRACTICE'),
(@t_func, 'What does a function return if it has no return statement?', '0', 'An empty string', 'None', 'It raises an error', 'C', 'EASY', 'PRACTICE'),
(@t_func, 'Which keyword sends a value back to the caller?', 'send', 'return', 'give', 'out', 'B', 'EASY', 'PRACTICE'),
(@t_func, 'The values you pass to a function when calling it are called', 'arguments', 'parameters', 'variables', 'objects', 'A', 'EASY', 'PRACTICE'),
(@t_func, 'The lambda keyword creates', 'a small anonymous function', 'a loop', 'a class', 'a module', 'A', 'EASY', 'PRACTICE'),
-- Quiz
(@t_func, 'Given  def f(a, b=2)  what is the value of b when you call  f(3)  ?', '3', '2', '0', 'It raises an error', 'B', 'EASY', 'QUIZ'),
(@t_func, 'In a function definition, what does *args collect?', 'Only integer arguments', 'Extra keyword arguments as a dictionary', 'Extra positional arguments as a tuple', 'Nothing, it is invalid', 'C', 'MEDIUM', 'QUIZ'),
(@t_func, 'Inside a function, **kwargs is available as a', 'list', 'tuple', 'set', 'dictionary', 'D', 'MEDIUM', 'QUIZ'),
(@t_func, 'A variable created inside a function is', 'global', 'shared by all functions', 'local to that function', 'automatically returned', 'C', 'EASY', 'QUIZ'),
(@t_func, 'Given  def area(l, b)  which call is valid?', 'area(b=3, l=4)', 'area(l=4, 3)', 'area(3 4)', 'area l=4 b=3', 'A', 'MEDIUM', 'QUIZ'),
(@t_func, 'Recursion means that a function', 'has many parameters', 'is defined inside a class', 'returns two values', 'calls itself', 'D', 'EASY', 'QUIZ'),
(@t_func, 'Which of these is a built-in Python function?', 'size()', 'len()', 'count_of()', 'length()', 'B', 'EASY', 'QUIZ'),
(@t_func, 'What does  def f(): return 1, 2  return?', 'The number 1 only', 'A tuple (1, 2)', 'A list [1, 2]', 'An error', 'B', 'MEDIUM', 'QUIZ'),
(@t_func, 'In a function definition, parameters with default values must be written', 'before all other parameters', 'only as the second parameter', 'anywhere', 'after all parameters without defaults', 'D', 'MEDIUM', 'QUIZ'),
(@t_func, 'The global keyword is used to', 'change a module level variable from inside a function', 'create a new local variable', 'import a module', 'delete a variable', 'A', 'MEDIUM', 'QUIZ'),
-- Golden
(@t_func, 'With  def f(x, lst=[]): lst.append(x); return lst  what does the SECOND call  f(2)  return after  f(1)  was already called?', '[2]', '[1]', '[1, 2]', 'An empty list', 'C', 'HARD', 'GOLDEN'),
(@t_func, 'What is printed by:  def f(): print(1); return; print(2)      then      f()', 'Nothing', '2', '1 and then 2', '1', 'D', 'HARD', 'GOLDEN'),
(@t_func, 'What is the result of:  list(map(lambda x: x * 2, [1, 2, 3]))', '[1, 2, 3]', '[1, 4, 9]', '[2, 4, 6]', 'An error is raised', 'C', 'HARD', 'GOLDEN'),
(@t_func, 'A function defined inside another function can read the outer function variables. This behaviour is called', 'inheritance', 'a closure', 'overloading', 'recursion', 'B', 'HARD', 'GOLDEN'),
(@t_func, 'A recursive factorial function that has no base case will', 'raise a RecursionError', 'return 0', 'return 1', 'run only once', 'A', 'HARD', 'GOLDEN');


-- ---------------------------------------------------------------------
-- TOPIC 5 : OOP
-- ---------------------------------------------------------------------
INSERT INTO questions (topic_id, question, option_a, option_b, option_c, option_d, correct_answer, difficulty, question_type) VALUES
-- Practice
(@t_oop, 'Which keyword is used to create a class in Python?', 'class', 'struct', 'object', 'define', 'A', 'EASY', 'PRACTICE'),
(@t_oop, 'What is an object?', 'A blueprint for a class', 'An instance created from a class', 'A type of loop', 'A built-in function', 'B', 'EASY', 'PRACTICE'),
(@t_oop, 'Which method acts as the constructor in Python?', 'init', 'main', 'the double underscore init method', 'new', 'C', 'EASY', 'PRACTICE'),
(@t_oop, 'What is the first parameter of every instance method?', 'this', 'cls', 'obj', 'self', 'D', 'EASY', 'PRACTICE'),
(@t_oop, 'Wrapping data and the methods that work on it into one unit is called', 'inheritance', 'polymorphism', 'encapsulation', 'recursion', 'C', 'EASY', 'PRACTICE'),
-- Quiz
(@t_oop, 'What does the constructor do?', 'Runs automatically when an object is created', 'Deletes the object', 'Must be called by hand', 'Returns the class name', 'A', 'EASY', 'QUIZ'),
(@t_oop, 'A class Teacher is written as  class Teacher(Person)  . What does this mean?', 'Teacher is a parameter of Person', 'Teacher is a copy of Person', 'Person inherits from Teacher', 'Teacher inherits from Person', 'D', 'EASY', 'QUIZ'),
(@t_oop, 'Writing a method in the child class with the same name as one in the parent class is called', 'overloading', 'overriding', 'encapsulation', 'abstraction', 'B', 'MEDIUM', 'QUIZ'),
(@t_oop, 'A variable written with two leading underscores inside a class is treated as', 'public', 'private', 'global', 'constant', 'B', 'MEDIUM', 'QUIZ'),
(@t_oop, 'Which pillar of OOP lets the same method name behave differently in different classes?', 'encapsulation', 'inheritance', 'abstraction', 'polymorphism', 'D', 'MEDIUM', 'QUIZ'),
(@t_oop, 'How do you create an object of the class Student?', 'Student()', 'new Student()', 'create Student', 'Student.new()', 'A', 'EASY', 'QUIZ'),
(@t_oop, 'Attributes defined with self inside the constructor are', 'shared by every object of the class', 'read only', 'separate for each object', 'automatically printed', 'C', 'MEDIUM', 'QUIZ'),
(@t_oop, 'What does Python pass automatically as the self argument?', 'The class itself', 'Nothing', 'The parent class', 'The current object', 'D', 'EASY', 'QUIZ'),
(@t_oop, 'Which function is used inside a child class to call a method of the parent class?', 'parent()', 'base()', 'super()', 'this()', 'C', 'MEDIUM', 'QUIZ'),
(@t_oop, 'Hiding the internal implementation and showing only what is necessary is called', 'inheritance', 'abstraction', 'recursion', 'iteration', 'B', 'EASY', 'QUIZ'),
-- Golden
(@t_oop, 'A class attribute is defined outside any method. If one object changes it using  ClassName.attr = 5  , the new value is seen by', 'every object of the class', 'only that object', 'no object', 'only objects created later', 'A', 'HARD', 'GOLDEN'),
(@t_oop, 'A class defines the double underscore str method. When is it used?', 'When the object is converted to a string, for example by print()', 'When the object is deleted', 'When the object is created', 'When the object is compared', 'A', 'HARD', 'GOLDEN'),
(@t_oop, 'Python supports a class inheriting from more than one parent class. This is called', 'multilevel inheritance', 'multiple inheritance', 'hybrid overloading', 'not supported in Python', 'B', 'HARD', 'GOLDEN'),
(@t_oop, 'A child class defines its own constructor but never calls super(). What happens to the parent constructor?', 'It runs first automatically', 'It runs after the child constructor', 'It does not run at all', 'An error is raised', 'C', 'HARD', 'GOLDEN'),
(@t_oop, 'What does  isinstance(obj, Person)  return when obj was created from a class that inherits from Person?', 'An error is raised', 'False', 'The class name', 'True', 'D', 'HARD', 'GOLDEN');


-- ---------------------------------------------------------------------
-- TOPIC 6 : FILES
-- ---------------------------------------------------------------------
INSERT INTO questions (topic_id, question, option_a, option_b, option_c, option_d, correct_answer, difficulty, question_type) VALUES
-- Practice
(@t_file, 'Which function opens a file in Python?', 'file()', 'read()', 'open()', 'load()', 'C', 'EASY', 'PRACTICE'),
(@t_file, 'Which mode opens a file only for reading?', 'r', 'w', 'a', 'x', 'A', 'EASY', 'PRACTICE'),
(@t_file, 'Which method should be called when you are finished with a file?', 'end()', 'exit()', 'stop()', 'close()', 'D', 'EASY', 'PRACTICE'),
(@t_file, 'Which mode adds new content at the end of an existing file?', 'r', 'a', 'w', 'b', 'B', 'EASY', 'PRACTICE'),
(@t_file, 'Which statement closes the file automatically?', 'for', 'with', 'try', 'def', 'B', 'EASY', 'PRACTICE'),
-- Quiz
(@t_file, 'What happens if you open an existing file in w mode?', 'The old content is kept', 'The file is opened for reading', 'An error is raised', 'The old content is erased', 'D', 'MEDIUM', 'QUIZ'),
(@t_file, 'What does read() return?', 'The whole file as a single string', 'One line of the file', 'A list of lines', 'The number of characters', 'A', 'EASY', 'QUIZ'),
(@t_file, 'What does readlines() return?', 'A single string', 'One line', 'A list of all the lines', 'The file size', 'C', 'MEDIUM', 'QUIZ'),
(@t_file, 'Opening a file in r mode when the file does not exist causes', 'the file to be created', 'the program to wait', 'an empty string to be returned', 'a FileNotFoundError', 'D', 'MEDIUM', 'QUIZ'),
(@t_file, 'Which letter is added to a file mode to work with binary files?', 'x', 'n', 'b', 'i', 'C', 'EASY', 'QUIZ'),
(@t_file, 'Why is the with statement preferred for file handling?', 'It runs faster', 'It closes the file even if an error occurs', 'It allows two modes at once', 'It compresses the file', 'B', 'MEDIUM', 'QUIZ'),
(@t_file, 'What does the strip() method usually remove when reading lines?', 'Leading and trailing whitespace including the newline', 'All spaces inside the line', 'Every vowel', 'The first character', 'A', 'MEDIUM', 'QUIZ'),
(@t_file, 'Which method writes a list of strings to a file?', 'writelines()', 'write()', 'writeall()', 'append()', 'A', 'MEDIUM', 'QUIZ'),
(@t_file, 'Looping with  for line in f  reads the file', 'all at once into memory', 'one line at a time', 'backwards', 'only the first line', 'B', 'MEDIUM', 'QUIZ'),
(@t_file, 'Which mode opens a file for both reading and writing?', 'r', 'w', 'r+', 'a', 'C', 'MEDIUM', 'QUIZ'),
-- Golden
(@t_file, 'After  f.read()  has been called once, what does a second  f.read()  return on the same open file?', 'The whole file again', 'An error is raised', 'The last line', 'An empty string', 'D', 'HARD', 'GOLDEN'),
(@t_file, 'Which method moves the file pointer back to the beginning?', 'reset()', 'rewind()', 'seek(0)', 'start()', 'C', 'HARD', 'GOLDEN'),
(@t_file, 'What does the tell() method return?', 'The current position of the file pointer', 'The file name', 'The number of lines', 'The file mode', 'A', 'HARD', 'GOLDEN'),
(@t_file, 'Does write() add a newline character at the end automatically?', 'Yes, always', 'Only for binary files', 'Only in a mode', 'No, you must add it yourself', 'D', 'HARD', 'GOLDEN'),
(@t_file, 'Which mode creates a new file but raises an error if the file already exists?', 'w', 'x', 'a', 'r+', 'B', 'HARD', 'GOLDEN');


-- ---------------------------------------------------------------------
-- TOPIC 7 : EXCEPTION HANDLING
-- ---------------------------------------------------------------------
INSERT INTO questions (topic_id, question, option_a, option_b, option_c, option_d, correct_answer, difficulty, question_type) VALUES
-- Practice
(@t_exc, 'Which block contains the code that might cause an error?', 'except', 'try', 'finally', 'else', 'B', 'EASY', 'PRACTICE'),
(@t_exc, 'Which block runs when an error actually occurs?', 'try', 'finally', 'else', 'except', 'D', 'EASY', 'PRACTICE'),
(@t_exc, 'Which block always runs, whether or not an error occurred?', 'finally', 'except', 'else', 'try', 'A', 'EASY', 'PRACTICE'),
(@t_exc, 'Which error is raised by  10 / 0  ?', 'ValueError', 'TypeError', 'ZeroDivisionError', 'IndexError', 'C', 'EASY', 'PRACTICE'),
(@t_exc, 'Which keyword lets you throw an exception yourself?', 'throw', 'panic', 'error', 'raise', 'D', 'EASY', 'PRACTICE'),
-- Quiz
(@t_exc, 'Which error is raised by  int("abc")  ?', 'TypeError', 'NameError', 'ValueError', 'KeyError', 'C', 'MEDIUM', 'QUIZ'),
(@t_exc, 'When does the else block of a try statement run?', 'Always', 'Only if no exception was raised', 'Only if an exception was raised', 'Never', 'B', 'MEDIUM', 'QUIZ'),
(@t_exc, 'What happens if an exception is not handled anywhere?', 'The program stops and shows a traceback', 'It is ignored', 'It becomes a warning', 'Python retries the statement', 'A', 'EASY', 'QUIZ'),
(@t_exc, 'Which error is raised when you use an index outside the range of a list?', 'IndexError', 'KeyError', 'ValueError', 'RangeError', 'A', 'MEDIUM', 'QUIZ'),
(@t_exc, 'Which error is raised when a dictionary key does not exist?', 'IndexError', 'KeyError', 'NameError', 'ValueError', 'B', 'MEDIUM', 'QUIZ'),
(@t_exc, 'Can a single try block have more than one except block?', 'No, only one is allowed', 'Only if finally is used', 'Yes, one for each type of error', 'Only two are allowed', 'C', 'EASY', 'QUIZ'),
(@t_exc, 'What is the main reason to use finally?', 'To print the error', 'To stop the program', 'To retry the code', 'To release resources such as files or connections', 'D', 'MEDIUM', 'QUIZ'),
(@t_exc, 'Which error is raised by  "5" + 5  ?', 'ValueError', 'SyntaxError', 'TypeError', 'NameError', 'C', 'MEDIUM', 'QUIZ'),
(@t_exc, 'Which error is raised when you use a variable that was never defined?', 'NameError', 'ValueError', 'KeyError', 'TypeError', 'A', 'MEDIUM', 'QUIZ'),
(@t_exc, 'Writing  except:  with no exception type is discouraged because', 'it is a syntax error', 'it cannot be combined with finally', 'it runs twice', 'it hides every error including ones you did not expect', 'D', 'MEDIUM', 'QUIZ'),
-- Golden
(@t_exc, 'A try block has a return statement and a finally block. Does the finally block still run?', 'No, return exits first', 'Yes, finally runs before the value is returned', 'Only if there was an exception', 'It raises an error', 'B', 'HARD', 'GOLDEN'),
(@t_exc, 'Which is the base class of almost all built-in exceptions in Python?', 'Error', 'Exception', 'BaseError', 'Throwable', 'B', 'HARD', 'GOLDEN'),
(@t_exc, 'To create your own exception class, it should inherit from', 'object', 'BaseError', 'Error', 'Exception', 'D', 'HARD', 'GOLDEN'),
(@t_exc, 'If  except Exception  is written before  except ValueError  , what happens to the ValueError block?', 'It is never reached, because Exception matches first', 'It runs first', 'Both run', 'A syntax error is raised', 'A', 'HARD', 'GOLDEN'),
(@t_exc, 'What does  except (ValueError, TypeError) as e:  do?', 'Catches only ValueError', 'Raises both errors', 'Catches either error and stores it in e', 'It is invalid syntax', 'C', 'HARD', 'GOLDEN');


-- ---------------------------------------------------------------------
-- TOPIC 8 : MODULES
-- ---------------------------------------------------------------------
INSERT INTO questions (topic_id, question, option_a, option_b, option_c, option_d, correct_answer, difficulty, question_type) VALUES
-- Practice
(@t_mod, 'What is a Python module?', 'A folder of images', 'A database table', 'A type of loop', 'A file containing Python code that can be reused', 'D', 'EASY', 'PRACTICE'),
(@t_mod, 'Which keyword brings a module into your program?', 'include', 'using', 'import', 'require', 'C', 'EASY', 'PRACTICE'),
(@t_mod, 'Which module provides sqrt and pi?', 'random', 'math', 'os', 'sys', 'B', 'EASY', 'PRACTICE'),
(@t_mod, 'Which module provides randint and shuffle?', 'random', 'math', 'time', 'json', 'A', 'EASY', 'PRACTICE'),
(@t_mod, 'What file extension does a Python module have?', '.py', '.pym', '.mod', '.python', 'A', 'EASY', 'PRACTICE'),
-- Quiz
(@t_mod, 'What does  from math import sqrt  allow you to write?', 'math.sqrt(9)', 'sqrt(9)', 'import sqrt(9)', 'math(9)', 'B', 'MEDIUM', 'QUIZ'),
(@t_mod, 'What does  import math as m  create?', 'A copy of the module', 'A new module file', 'A shorter alias for the module', 'An error', 'C', 'EASY', 'QUIZ'),
(@t_mod, 'A folder containing several related modules is called a', 'library file', 'class', 'script', 'package', 'D', 'EASY', 'QUIZ'),
(@t_mod, 'Why is  from module import *  discouraged?', 'It is slower to type', 'It only works once', 'It can silently overwrite names already in your program', 'It is a syntax error', 'C', 'MEDIUM', 'QUIZ'),
(@t_mod, 'Which module is used to work with files and folders of the operating system?', 'os', 'math', 'random', 'string', 'A', 'EASY', 'QUIZ'),
(@t_mod, 'What is the value of the name variable when a file is run directly?', 'the file name', 'the module name', 'None', '__main__', 'D', 'MEDIUM', 'QUIZ'),
(@t_mod, 'Which module would you use to work with dates and times?', 'calendar only', 'datetime', 'os', 'sys', 'B', 'EASY', 'QUIZ'),
(@t_mod, 'How many times is a module executed if it is imported in three different files of the same program?', 'Three times', 'Once, then it is reused from the cache', 'Never', 'It raises an error', 'B', 'MEDIUM', 'QUIZ'),
(@t_mod, 'Which command installs a third party module?', 'python install', 'module add', 'import install', 'pip install', 'D', 'EASY', 'QUIZ'),
(@t_mod, 'What does the dir() function return when given a module?', 'A list of the names defined inside it', 'Its file path', 'Its size', 'Its version', 'A', 'MEDIUM', 'QUIZ'),
-- Golden
(@t_mod, 'In older versions of Python, which file had to be present for a folder to be treated as a package?', 'main.py', 'setup.py', 'the double underscore init file', 'package.py', 'C', 'HARD', 'GOLDEN'),
(@t_mod, 'Which list does Python search to find a module you are importing?', 'os.path', 'import.path', 'module.list', 'sys.path', 'D', 'HARD', 'GOLDEN'),
(@t_mod, 'What is the purpose of  if __name__ == "__main__":  ?', 'To rename the module', 'To import every module', 'To run code only when the file is executed directly and not when it is imported', 'To define the entry class', 'C', 'HARD', 'GOLDEN'),
(@t_mod, 'What is a circular import?', 'A module imported inside a for loop', 'A module that imports itself in a loop with another module', 'Importing the same module twice', 'Importing a package', 'B', 'HARD', 'GOLDEN'),
(@t_mod, 'Changing a module file while the program is running has no effect unless you', 'restart or reload the module', 'delete the cache folder by hand every time', 'rename the module', 'reinstall Python', 'A', 'HARD', 'GOLDEN');


-- =====================================================================
--  Verification - run these after the script to confirm the seed data
-- =====================================================================
-- SELECT COUNT(*) AS topics FROM topics;                    -- expect 8
-- SELECT COUNT(*) AS questions FROM questions;              -- expect 160
-- SELECT t.title, q.question_type, COUNT(*)
--   FROM questions q JOIN topics t ON t.topic_id = q.topic_id
--  GROUP BY t.topic_order, q.question_type ORDER BY t.topic_order;
