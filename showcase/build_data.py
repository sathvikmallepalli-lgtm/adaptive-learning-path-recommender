"""Export the project's public course seed data for the browser product demo.

Run from any directory: python3 showcase/build_data.py
Only topic content and questions are exported; account rows are deliberately omitted.
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = Path(__file__).resolve().parent / "product" / "data.json"


def without_comments(source):
    output = []
    quoted = False
    i = 0
    while i < len(source):
        char = source[i]
        if char == "'":
            if quoted and i + 1 < len(source) and source[i + 1] == "'":
                output.extend(("'", "'"))
                i += 2
                continue
            quoted = not quoted
        if not quoted and source[i : i + 2] == "--":
            i = source.find("\n", i)
            if i == -1:
                break
            output.append("\n")
        else:
            output.append(char)
        i += 1
    return "".join(output)


def split_outside_quotes(text, delimiter=","):
    chunks = []
    start = 0
    quoted = False
    depth = 0
    i = 0
    while i < len(text):
        char = text[i]
        if char == "'":
            if quoted and i + 1 < len(text) and text[i + 1] == "'":
                i += 2
                continue
            quoted = not quoted
        elif not quoted:
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
            elif char == delimiter and depth == 0:
                chunks.append(text[start:i].strip())
                start = i + 1
        i += 1
    chunks.append(text[start:].strip())
    return chunks


def decode(token):
    if token.startswith("'") and token.endswith("'"):
        return token[1:-1].replace("''", "'").replace("\\n", "\n")
    if token.isdigit():
        return int(token)
    return token


def rows(source, table):
    pattern = re.compile(rf"INSERT INTO {table}\s*\([^;]*?\)\s*VALUES", re.I | re.S)
    for match in pattern.finditer(source):
        tail = source[match.end() :]
        statement = split_outside_quotes(tail, ";")[0]
        for tuple_text in split_outside_quotes(statement):
            tuple_text = tuple_text.strip()
            if tuple_text:
                assert tuple_text.startswith("(") and tuple_text.endswith(")"), tuple_text[:100]
                yield [decode(field) for field in split_outside_quotes(tuple_text[1:-1])]


seed = without_comments((ROOT / "database/02_seed_data.sql").read_text())
extra = without_comments((ROOT / "database/03_advanced_practice.sql").read_text())
topics = [
    {"id": index + 1, "title": row[0], "description": row[1], "difficulty": row[2], "order": row[3], "notes": row[4]}
    for index, row in enumerate(rows(seed, "topics"))
]
aliases = {"@t_var": 1, "@t_cond": 2, "@t_loop": 3, "@t_func": 4, "@t_oop": 5, "@t_file": 6, "@t_exc": 7, "@t_mod": 8}
questions = []
for index, row in enumerate([*rows(seed, "questions"), *rows(extra, "questions")]):
    assert len(row) == 9 and row[0] in aliases, row
    questions.append({"id": index + 1, "topicId": aliases[row[0]], "question": row[1], "options": row[2:6], "correct": row[6], "difficulty": row[7], "type": row[8]})

assert len(topics) == 8, len(topics)
assert len(questions) == 200, len(questions)
for topic in topics:
    own = [question for question in questions if question["topicId"] == topic["id"]]
    assert len(own) == 25, (topic["title"], len(own))
    assert sum(question["type"] == "QUIZ" for question in own) == 10
    assert sum(question["type"] == "GOLDEN" for question in own) == 5
    assert sum(question["type"] == "PRACTICE" for question in own) == 10

OUTPUT.parent.mkdir(exist_ok=True)
OUTPUT.write_text(json.dumps({"topics": topics, "questions": questions}, ensure_ascii=False, separators=(",", ":")) + "\n")
print(f"Exported {len(topics)} topics and {len(questions)} questions to {OUTPUT}")
