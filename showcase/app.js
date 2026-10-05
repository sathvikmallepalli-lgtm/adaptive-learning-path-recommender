const topics = [
  {
    title: "Variables",
    description:
      "Store values with names and understand Python's built-in data types.",
    advanced: false,
  },
  {
    title: "Conditions",
    description: "Make decisions with if, elif and else.",
    advanced: false,
  },
  {
    title: "Loops",
    description: "Repeat work with for and while loops.",
    advanced: false,
  },
  {
    title: "Functions",
    description:
      "Write reusable blocks of code with parameters and return values.",
    advanced: false,
  },
  {
    title: "OOP",
    description: "Work with classes, objects, inheritance and methods.",
    advanced: true,
  },
  {
    title: "Files",
    description: "Read and write files safely in Python.",
    advanced: true,
  },
  {
    title: "Exception Handling",
    description: "Handle errors and keep programs running gracefully.",
    advanced: true,
  },
  {
    title: "Modules",
    description: "Organise code into reusable modules and packages.",
    advanced: true,
  },
];
const storageKey = "adaptive-showcase-progress-v1";
const empty = () =>
  topics.map(() => ({
    bestQuiz: 0,
    quizAttempts: 0,
    goldenPassed: false,
    goldenAttempts: 0,
  }));
let progress = empty();
try {
  const saved = JSON.parse(localStorage.getItem(storageKey));
  if (Array.isArray(saved) && saved.length === topics.length)
    progress = saved.map((item) => ({
      bestQuiz: Number.isFinite(item.bestQuiz)
        ? Math.max(0, Math.min(100, item.bestQuiz))
        : 0,
      quizAttempts: Number.isInteger(item.quizAttempts)
        ? Math.max(0, item.quizAttempts)
        : 0,
      goldenPassed: item.goldenPassed === true,
      goldenAttempts: Number.isInteger(item.goldenAttempts)
        ? Math.max(0, item.goldenAttempts)
        : 0,
    }));
} catch (_) {
  /* A damaged local demo state starts fresh. */
}
let selected = 0;
let lastResult = null;
const byId = (id) => document.getElementById(id);
const save = () => {
  try {
    localStorage.setItem(storageKey, JSON.stringify(progress));
  } catch (_) {
    /* Storage is optional. */
  }
};
const isOpen = (index) =>
  index === 0 ||
  (progress[index - 1].bestQuiz >= 50 &&
    (!topics[index].advanced || progress[index - 1].goldenPassed));
const stateLabel = (index) =>
  !isOpen(index)
    ? "Locked"
    : !progress[index].quizAttempts
      ? "Ready to learn"
      : progress[index].bestQuiz < 50
        ? "Needs revision"
        : progress[index].goldenPassed
          ? "Mastered"
          : "Completed";
function render() {
  byId("topic-list").innerHTML = topics
    .map((topic, index) => {
      const open = isOpen(index),
        label = stateLabel(index),
        chosen = selected === index;
      return `<button class="topic-item ${chosen ? "selected" : ""} ${open ? "" : "locked"}" type="button" data-index="${index}" aria-pressed="${chosen}"><span class="topic-number">${String(index + 1).padStart(2, "0")}</span><span class="topic-main"><strong>${topic.title}</strong><small>${topic.advanced ? "Advanced" : "Basic"} · ${label}</small></span><span class="topic-end">${open ? (progress[index].quizAttempts ? progress[index].bestQuiz + "%" : "↗") : "⌁"}</span></button>`;
    })
    .join("");
  byId("progress-count").textContent =
    `${topics.filter((_, i) => isOpen(i)).length} of 8 open`;
  const topic = topics[selected],
    record = progress[selected],
    open = isOpen(selected);
  byId("selected-title").textContent = topic.title;
  byId("selected-difficulty").textContent = topic.advanced
    ? "Advanced"
    : "Basic";
  byId("selected-description").textContent = topic.description;
  byId("topic-state").textContent = open
    ? record.quizAttempts
      ? `Best quiz: ${record.bestQuiz}% · ${record.quizAttempts} simulated attempt${record.quizAttempts === 1 ? "" : "s"}`
      : "Open and ready to study"
    : topic.advanced
      ? "Locked: pass the previous quiz and its Golden Assessment."
      : "Locked: score at least 50% on the previous topic quiz.";
  byId("apply-quiz").disabled = !open;
  byId("quiz-score").disabled = !open;
  byId("golden-box").hidden = !open || record.bestQuiz <= 80;
  if (lastResult) {
    byId("result").className = `result ${lastResult.tone}`;
    byId("result").innerHTML =
      `<span class="result-spark">${lastResult.symbol}</span><div><strong>${lastResult.title}</strong><p>${lastResult.message}</p></div>`;
  } else {
    byId("result").className = "result";
    byId("result").innerHTML =
      `<span class="result-spark">✦</span><div><strong>Start with a result</strong><p>Try 40%, 70% and 90% to see how the recommendation changes.</p></div>`;
  }
}
byId("topic-list").addEventListener("click", (event) => {
  const button = event.target.closest("[data-index]");
  if (!button) return;
  selected = Number(button.dataset.index);
  lastResult = null;
  render();
});
byId("quiz-score").addEventListener("input", (event) => {
  byId("quiz-output").textContent = `${event.target.value}%`;
});
byId("apply-quiz").addEventListener("click", () => {
  if (!isOpen(selected)) return;
  const score = Number(byId("quiz-score").value),
    topic = topics[selected],
    next = topics[selected + 1];
  progress[selected].quizAttempts += 1;
  progress[selected].bestQuiz = Math.max(progress[selected].bestQuiz, score);
  if (score < 50)
    lastResult = {
      tone: "revision",
      symbol: "↺",
      title: "Revise this topic",
      message: `You scored ${score}% in ${topic.title}. Read the notes, practise, then retake the quiz. You need 50% to move on.`,
    };
  else if (score <= 80)
    lastResult = next?.advanced
      ? {
          tone: "next",
          symbol: "↗",
          title: "Good work — one more step needed",
          message: `You scored ${score}%. ${next.title} is advanced: score above 80% here and pass the Golden Assessment to open it.`,
        }
      : {
          tone: "next",
          symbol: "↗",
          title: next ? "Move on to the next topic" : "Course complete",
          message: next
            ? `You scored ${score}%. ${next.title} is now open.`
            : `You scored ${score}% on the final topic.`,
        };
  else
    lastResult = {
      tone: "golden-result",
      symbol: "✦",
      title: "Golden Assessment unlocked",
      message: next?.advanced
        ? `You scored ${score}%. Pass the Golden Assessment to open ${next.title}.`
        : next
          ? `You scored ${score}%. ${next.title} is open; the Golden Assessment is an extra challenge.`
          : `You scored ${score}%. The Golden Assessment is available as an extra challenge.`,
    };
  save();
  render();
});
byId("apply-golden").addEventListener("click", () => {
  if (!isOpen(selected) || progress[selected].bestQuiz <= 80) return;
  const correct = Number(byId("golden-correct").value),
    score = correct * 20,
    next = topics[selected + 1];
  progress[selected].goldenAttempts += 1;
  if (score >= 60) progress[selected].goldenPassed = true;
  lastResult =
    score >= 60
      ? {
          tone: "golden-result",
          symbol: "✦",
          title: "Golden Assessment passed",
          message: next?.advanced
            ? `${correct} of 5 correct (${score}%). ${next.title} is now unlocked.`
            : next
              ? `${correct} of 5 correct (${score}%). ${next.title} was already open after your quiz pass.`
              : `${correct} of 5 correct (${score}%). You have finished the whole course.`,
        }
      : {
          tone: "revision",
          symbol: "↺",
          title: "Advanced practice recommended",
          message: `${correct} of 5 correct (${score}%). You need 3 of 5 to pass. Practise and try again.`,
        };
  save();
  render();
});
byId("reset-progress").addEventListener("click", () => {
  progress = empty();
  selected = 0;
  lastResult = null;
  save();
  render();
});
render();
