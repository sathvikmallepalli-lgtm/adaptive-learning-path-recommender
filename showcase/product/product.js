/* Browser product demo. The Java/Tomcat MVP remains the source of truth. */
const storeKey = "adaptive-product-demo-v1";
const app = document.getElementById("app");
let seed;
let state;
let feedback = "";

const esc = (value) =>
  String(value ?? "").replace(
    /[&<>"']/g,
    (char) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[
        char
      ],
  );
const dateText = (value) =>
  new Date(value).toLocaleString("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
  });
const route = () => location.hash.slice(1).split("/").filter(Boolean);
const topicById = (id) => state.topics.find((topic) => topic.id === Number(id));
const orderedTopics = () =>
  [...state.topics].sort((a, b) => a.order - b.order || a.id - b.id);
const nextTopic = (topicId) => {
  const list = orderedTopics();
  return (
    list[list.findIndex((topic) => topic.id === Number(topicId)) + 1] || null
  );
};
const currentStudent = () => state.students[state.user];
const studentAttempts = (studentId = state.user) =>
  state.attempts.filter((attempt) => attempt.student === studentId);
const bestScore = (studentId, topicId, type) =>
  Math.max(
    0,
    ...state.attempts
      .filter(
        (a) =>
          a.student === studentId && a.topicId === topicId && a.type === type,
      )
      .map((a) => a.score),
  );
const quizCount = (studentId, topicId) =>
  state.attempts.filter(
    (a) =>
      a.student === studentId && a.topicId === topicId && a.type === "QUIZ",
  ).length;
const isOpen = (studentId, topicId) => {
  const list = orderedTopics();
  const index = list.findIndex((topic) => topic.id === Number(topicId));
  if (index < 0) return false;
  if (index === 0) return true;
  const previous = list[index - 1];
  return (
    bestScore(studentId, previous.id, "QUIZ") >= 50 &&
    (list[index].difficulty !== "ADVANCED" ||
      bestScore(studentId, previous.id, "GOLDEN") >= 60)
  );
};
const statusOf = (studentId, topicId) => {
  if (!isOpen(studentId, topicId)) return "Locked";
  if (!quizCount(studentId, topicId)) return "Not started";
  if (bestScore(studentId, topicId, "QUIZ") < 50) return "Needs revision";
  if (bestScore(studentId, topicId, "GOLDEN") >= 60) return "Mastered";
  return "Completed";
};
const questionsFor = (topicId, type, difficulty) =>
  state.questions.filter(
    (q) =>
      q.topicId === Number(topicId) &&
      q.type === type &&
      (!difficulty || q.difficulty === difficulty),
  );
const goto = (path) => {
  feedback = "";
  location.hash = path;
  if (location.hash.slice(1) === path) render();
  window.scrollTo(0, 0);
};
const save = () => {
  try {
    localStorage.setItem(storeKey, JSON.stringify(state));
  } catch (_) {
    /* Browser storage is optional. */
  }
};

function recommend(attempt) {
  const topic = topicById(attempt.topicId);
  const next = nextTopic(topic.id);
  const score = attempt.score;
  if (attempt.type === "GOLDEN") {
    return score >= 60
      ? {
          kind: "UNLOCK_ADVANCED",
          headline: "Golden Assessment passed",
          message: `You scored ${score}% in the ${topic.title} Golden Assessment. ${next ? (next.difficulty === "ADVANCED" ? `${next.title} is now unlocked.` : `${next.title} was already open after your quiz pass.`) : "You have finished the whole course."}`,
        }
      : {
          kind: "ADVANCED_PRACTICE",
          headline: "Advanced practice recommended",
          message: `You scored ${score}% in the ${topic.title} Golden Assessment and 60% was needed. Work through the advanced practice questions, then try again.`,
        };
  }
  if (score < 50)
    return {
      kind: "REVISION",
      headline: "Revise this topic",
      message: `You scored ${score}% in ${topic.title}. Read the notes again, practise, then retake the quiz. You need 50% to move on.`,
    };
  if (score <= 80) {
    if (!next)
      return {
        kind: "NEXT_TOPIC",
        headline: "Course complete",
        message: `You scored ${score}% in ${topic.title}, the last topic. Well done.`,
      };
    if (next.difficulty === "ADVANCED")
      return {
        kind: "NEXT_TOPIC",
        headline: "Good work — one more step needed",
        message: `You scored ${score}% in ${topic.title}. ${next.title} is advanced, so score above 80% here and pass the Golden Assessment to open it.`,
      };
    return {
      kind: "NEXT_TOPIC",
      headline: "Move on to the next topic",
      message: `You scored ${score}% in ${topic.title}. Continue with ${next.title}.`,
    };
  }
  const guidance = !next
    ? "This was the last topic."
    : next.difficulty === "ADVANCED"
      ? `Pass the Golden Assessment before ${next.title} opens.`
      : `${next.title} is already open.`;
  return {
    kind: "GOLDEN_ASSESSMENT",
    headline: "Golden Assessment unlocked",
    message: `Excellent — ${score}% in ${topic.title}. ${guidance} The five-question Golden Assessment is now available; score 60% or more to pass.`,
  };
}

function freshState() {
  const now = Date.now();
  const sample = [
    [1, 80],
    [2, 70],
    [3, 80],
    [4, 40],
  ].map(([topicId, score], index) => ({
    id: index + 1,
    student: "rahul",
    topicId,
    type: "QUIZ",
    score,
    correct: score / 10,
    total: 10,
    date: new Date(now - (4 - index) * 86400000).toISOString(),
    answers: null,
    sample: true,
  }));
  return {
    version: 1,
    user: null,
    topics: structuredClone(seed.topics),
    questions: structuredClone(seed.questions),
    students: {
      rahul: { name: "Rahul Sharma" },
      sneha: { name: "Sneha Patil" },
    },
    attempts: sample,
    recommendations: sample.map((attempt) => ({
      id: attempt.id,
      student: "rahul",
      topicId: attempt.topicId,
      attemptId: attempt.id,
      date: attempt.date,
      ...recommendFromSeed(attempt),
    })),
  };
}

function recommendFromSeed(attempt) {
  const topic = seed.topics.find((item) => item.id === attempt.topicId);
  const next = seed.topics.find((item) => item.order === topic.order + 1);
  if (attempt.score < 50)
    return {
      kind: "REVISION",
      headline: "Revise this topic",
      message: `You scored ${attempt.score}% in ${topic.title}. Read the notes again, practise, then retake the quiz. You need 50% to move on.`,
    };
  return {
    kind: "NEXT_TOPIC",
    headline: "Move on to the next topic",
    message: `You scored ${attempt.score}% in ${topic.title}. Continue with ${next?.title || "the course"}.`,
  };
}

function page(title, subtitle, body, active) {
  const teacher = state.user === "teacher";
  const name = teacher ? "Anita Rao" : currentStudent().name;
  const links = teacher
    ? [
        ["dashboard", "■", "Dashboard"],
        ["topics", "☷", "Topics"],
        ["questions", "?", "Questions"],
        ["attempts", "▲", "Attempts"],
        ["recommendations", "☞", "Recommendations"],
      ]
    : [
        ["dashboard", "■", "Dashboard"],
        ["modules", "☷", "Modules"],
        ["recommendations", "☞", "Recommendations"],
        ["progress", "▲", "Progress"],
      ];
  app.innerHTML = `<div class="app"><aside class="sidebar"><a class="brand" href="#dashboard"><span class="brand-mark">A</span><span>Adaptive<br>Learning</span></a><div class="nav-label">${teacher ? "Teaching" : "Learning"}</div><nav>${links.map(([key, icon, label]) => `<a class="nav-item ${active === key ? "active" : ""}" href="#${key}"><span class="nav-icon">${icon}</span>${label}</a>`).join("")}</nav><div class="sidebar-foot"><div class="who"><div class="avatar">${
    teacher
      ? "AR"
      : name
          .split(" ")
          .map((part) => part[0])
          .join("")
  }</div><div><div class="who-name">${esc(name)}</div><div class="who-role">${teacher ? "Teacher" : "Student"}</div></div></div><button class="nav-item" data-action="logout"><span class="nav-icon">↩</span> Switch account</button><button class="reset-link" data-action="reset">Reset browser demo</button></div></aside><main class="content" id="main"><div class="page-head"><h1>${title}</h1><p class="sub">${subtitle}</p></div>${feedback ? `<div class="demo-alert error" role="alert">${esc(feedback)}</div>` : ""}${body}</main></div>`;
  document.title = `${title.replace(/<[^>]+>/g, "")} | MVP Product Demo`;
}

function chooseAccount() {
  app.innerHTML = `<main class="demo-entry" id="main"><section class="demo-intro"><div class="brand"><span class="brand-mark">A</span><span>Adaptive<br>Learning</span></div><h1>Learn Python on a path that reacts to your quiz score.</h1><p>This is the working product flow: read real course notes, answer the seeded questions, get a recommendation, and watch the next module unlock.</p><div class="demo-rule"><b>Below 50%</b><span>Revise and retake</span></div><div class="demo-rule"><b>50–80%</b><span>Continue along the path</span></div><div class="demo-rule"><b>Above 80%</b><span>Take the Golden Assessment</span></div><div class="demo-rule"><b>Golden pass</b><span>Unlock an advanced topic</span></div></section><section class="demo-choose"><h2>Enter the demo</h2><p>Choose a seeded role. Rahul has sample progress; Sneha starts fresh. The teacher view shows the course and student activity.</p><button class="account-card" data-action="login" data-user="rahul"><span class="avatar">RS</span><span><strong>Rahul Sharma</strong><small>Student · sample progress and revision advice</small></span><span class="arrow">↗</span></button><button class="account-card" data-action="login" data-user="sneha"><span class="avatar">SP</span><span><strong>Sneha Patil</strong><small>Student · start from Variables</small></span><span class="arrow">↗</span></button><button class="account-card teacher" data-action="login" data-user="teacher"><span class="avatar">AR</span><span><strong>Anita Rao</strong><small>Teacher · course and student activity</small></span><span class="arrow">↗</span></button><p class="demo-footnote">No passwords or real accounts are used here. This browser copy saves changes only on your device. The Java/Tomcat/MySQL application is available in the repository.</p></section></main>`;
  document.title = "Enter the MVP Product Demo | Adaptive Learning";
}

function stat(label, value, detail = "", gold = false) {
  return `<div class="stat ${gold ? "is-gold" : ""}"><div class="stat-label">${label}</div><div class="stat-value">${value}</div>${detail ? `<div class="text-muted-2 mt-2" style="font-size:12px">${detail}</div>` : ""}</div>`;
}
function attemptTable(attempts, showStudent = false) {
  if (!attempts.length)
    return `<p class="demo-empty">No attempts yet. ${showStudent ? "Open a student account and take a quiz." : "Start with the first module."}</p>`;
  return `<div class="table-wrap"><table class="table-clean"><thead><tr>${showStudent ? "<th>Student</th>" : ""}<th>Topic</th><th>Type</th><th>Correct</th><th>Score</th><th>When</th></tr></thead><tbody>${attempts.map((a) => `<tr>${showStudent ? `<td>${esc(state.students[a.student]?.name || a.student)}</td>` : ""}<td>${esc(topicById(a.topicId)?.title || "Removed topic")}</td><td><span class="pill ${a.type === "GOLDEN" ? "pill-gold" : "pill-idle"}">${a.type === "GOLDEN" ? "Golden" : "Quiz"}</span></td><td class="figure-mono">${a.correct}/${a.total}</td><td><span class="pill ${a.score >= (a.type === "GOLDEN" ? 60 : 50) ? "pill-pass" : "pill-fail"}">${a.score}%</span></td><td class="text-muted-2" style="font-size:12px;white-space:nowrap">${dateText(a.date)}${a.sample ? " · sample" : ""}</td></tr>`).join("")}</tbody></table></div>`;
}

function studentDashboard() {
  const list = orderedTopics(),
    attempts = studentAttempts().sort((a, b) => b.id - a.id);
  const done = list.filter(
    (topic) => bestScore(state.user, topic.id, "QUIZ") >= 50,
  ).length;
  const unlocked = list.filter((topic) => isOpen(state.user, topic.id)).length;
  const quizzes = attempts.filter((a) => a.type === "QUIZ");
  const average = quizzes.length
    ? Math.round(
        quizzes.reduce((sum, item) => sum + item.score, 0) / quizzes.length,
      )
    : 0;
  const goldenPassed = list.filter(
    (topic) => bestScore(state.user, topic.id, "GOLDEN") >= 60,
  ).length;
  const current = list.find(
    (topic) =>
      isOpen(state.user, topic.id) &&
      (bestScore(state.user, topic.id, "QUIZ") < 50 ||
        (nextTopic(topic.id)?.difficulty === "ADVANCED" &&
          !isOpen(state.user, nextTopic(topic.id).id))),
  );
  const latest = state.recommendations
    .filter((rec) => rec.student === state.user)
    .sort((a, b) => b.id - a.id)[0];
  const action = current
    ? `<h2 class="section-title mb-2">${esc(current.title)}</h2><p> ${statusOf(state.user, current.id) === "Needs revision" ? `Your best score is ${bestScore(state.user, current.id, "QUIZ")}%. Revise the notes and practice before retaking the quiz.` : bestScore(state.user, current.id, "QUIZ") > 80 ? "Your quiz score opened the Golden Assessment. Pass it to reach the next advanced topic." : bestScore(state.user, current.id, "QUIZ") >= 50 ? "Score above 80% and pass the Golden Assessment to reach the next advanced topic." : "Read the notes, try the practice questions, then take the quiz."}</p><a class="btn btn-primary" href="#topic/${current.id}">Open ${esc(current.title)}</a>`
    : `<h2 class="section-title">Course complete</h2><p>Every topic is complete. Review your progress or practise again.</p><a class="btn btn-primary" href="#progress">View progress</a>`;
  page(
    `Hello, ${esc(currentStudent().name.split(" ")[0])}`,
    "Here is where your learning path stands today.",
    `<div class="stats-grid">${stat("Course complete", `${Math.round((done / (list.length || 1)) * 100)}<small>%</small>`)}${stat("Topics done", `${done}<small> / ${list.length}</small>`, `${unlocked} unlocked`)}${stat("Average score", `${average}<small>%</small>`, `${quizzes.length} quizzes taken`)}${stat("Golden passed", goldenPassed, "unlocks advanced topics", true)}</div><div class="dashboard-grid"><div class="card-soft p-4"><div class="stat-label mb-3">What to do next</div>${action}${latest ? `<div class="mt-4 pt-3 border-top" style="font-size:13px"><div class="stat-label mb-1">Latest result</div>${esc(latest.headline)} · <a href="#recommendations">Read the advice</a></div>` : ""}</div><div class="card-soft"><div class="p-4 pb-2 stat-label">Recent attempts</div>${attemptTable(attempts.slice(0, 5))}<div class="p-3"><a href="#progress">See full history</a></div></div></div>`,
    "dashboard",
  );
}

function modulesPage() {
  const list = orderedTopics();
  const steps = list
    .map((topic, index) => {
      const open = isOpen(state.user, topic.id),
        status = statusOf(state.user, topic.id),
        best = bestScore(state.user, topic.id, "QUIZ");
      const className = !open
        ? "is-locked"
        : status === "Mastered"
          ? "is-mastered"
          : status === "Completed"
            ? "is-done"
            : "is-current";
      const card = `<div class="d-flex justify-content-between align-items-start gap-2"><div><h2 class="topic-title">${esc(topic.title)}</h2><p class="topic-desc">${esc(topic.description)}</p><div class="path-meta"><span class="pill ${topic.difficulty === "ADVANCED" ? "pill-advanced" : "pill-basic"}">${topic.difficulty === "ADVANCED" ? "Advanced" : "Basic"}</span><span>${status}${quizCount(state.user, topic.id) ? ` · best ${best}%` : ""}</span></div></div><span>${open ? "↗" : "⌁"}</span></div>`;
      return `${index === 4 ? `<div class="path-gate"><strong>Golden gate</strong> · Advanced topics open after a quiz score above 80% and a passed Golden Assessment on the previous topic.</div>` : ""}<div class="path-step ${className}"><span class="path-node">${String(index + 1).padStart(2, "0")}</span>${open ? `<a class="topic-card" href="#topic/${topic.id}">${card}</a>` : `<div class="topic-card" aria-disabled="true">${card}</div>`}</div>`;
    })
    .join("");
  page(
    "Your learning path",
    `${list.filter((topic) => isOpen(state.user, topic.id)).length} of ${list.length} topics open. Finish a topic to reach the next one.`,
    `<div class="path">${steps}</div><div class="card-soft p-4 mt-4"><span class="pill pill-fail">Needs revision</span> below 50% &nbsp; <span class="pill pill-pass">Completed</span> at least 50% &nbsp; <span class="pill pill-gold">Golden</span> above 80% opens the advanced test</div>`,
    "modules",
  );
}

function practiceList(items, label) {
  if (!items.length)
    return `<p class="text-muted-2">No practice questions are available.</p>`;
  return items
    .map(
      (q, index) =>
        `<details class="q-card"><summary><span class="q-number">${label} ${index + 1}</span><div class="q-text mb-0">${esc(q.question)}</div></summary><div class="practice-answer">${q.options.map((option, optionIndex) => `<div class="opt ${"ABCD"[optionIndex] === q.correct ? "picked" : ""}"><span class="letter">${"ABCD"[optionIndex]}</span><span>${esc(option)}</span>${"ABCD"[optionIndex] === q.correct ? `<span class="pill pill-pass ms-auto">Correct</span>` : ""}</div>`).join("")}</div></details>`,
    )
    .join("");
}

function topicPage(id) {
  const topic = topicById(id);
  if (!topic || !isOpen(state.user, topic.id)) {
    goto("modules");
    return;
  }
  const practice = questionsFor(topic.id, "PRACTICE").filter(
    (question) => question.difficulty !== "HARD",
  );
  const advanced = questionsFor(topic.id, "PRACTICE", "HARD");
  const quizReady = questionsFor(topic.id, "QUIZ").length >= 10;
  const goldenReady =
    bestScore(state.user, topic.id, "QUIZ") > 80 &&
    questionsFor(topic.id, "GOLDEN").length >= 5;
  const needsAdvanced =
    state.attempts.some(
      (attempt) =>
        attempt.student === state.user &&
        attempt.topicId === topic.id &&
        attempt.type === "GOLDEN",
    ) && bestScore(state.user, topic.id, "GOLDEN") < 60;
  const notes =
    topic.notesMode === "plain"
      ? `<p style="white-space:pre-wrap">${esc(topic.notes)}</p>`
      : topic.notes;
  const sidebar = `<div class="card-soft p-4"><div class="stat-label mb-3">Your next step</div><div class="mb-3">${statusOf(state.user, topic.id)}${quizCount(state.user, topic.id) ? ` · best quiz ${bestScore(state.user, topic.id, "QUIZ")}%` : ""}</div>${quizReady ? `<a class="btn btn-primary w-100 mb-2" href="#quiz/${topic.id}">${quizCount(state.user, topic.id) ? "Retake" : "Start"} the 10-question quiz</a>` : `<p class="demo-alert warn">The quiz needs 10 questions. Ask the teacher to complete it.</p>`}${goldenReady ? `<a class="btn btn-gold w-100" href="#golden/${topic.id}">Take the Golden Assessment</a>` : `<p class="inline-help">Score above 80% in the quiz to open the Golden Assessment.</p>`}<hr><a href="#modules">← All modules</a></div>`;
  page(
    `<span class="figure-mono text-muted-2" style="font-size:19px">${String(topic.order).padStart(2, "0")}</span> ${esc(topic.title)} <span class="pill ${topic.difficulty === "ADVANCED" ? "pill-advanced" : "pill-basic"}">${topic.difficulty === "ADVANCED" ? "Advanced" : "Basic"}</span>`,
    esc(topic.description),
    `<div class="row g-3"><div class="col-lg-8"><div class="card-soft p-4"><div class="stat-label mb-3">Notes</div><div class="notes">${notes || "No notes yet."}</div></div><div class="card-soft p-4 mt-3"><div class="d-flex justify-content-between"><div class="stat-label">Practice</div><small class="text-muted-2">Not scored</small></div><p class="text-muted-2" style="font-size:14px">Open a question to check the answer before the quiz.</p>${practiceList(practice, "Practice")}</div><div class="card-soft p-4 mt-3" id="advancedPractice"><div class="d-flex justify-content-between"><div class="stat-label">Advanced practice</div><span class="pill pill-gold">Harder</span></div><p class="text-muted-2" style="font-size:14px">${needsAdvanced ? "Use these after your Golden attempt, then try again." : "Prepare for the Golden Assessment with harder questions."}</p>${practiceList(advanced, "Advanced")}</div></div><div class="col-lg-4">${sidebar}</div></div>`,
    "modules",
  );
}

function assessmentPage(topicId, type) {
  const topic = topicById(topicId);
  if (!topic || !isOpen(state.user, topic.id)) {
    goto("modules");
    return;
  }
  if (type === "GOLDEN" && bestScore(state.user, topic.id, "QUIZ") <= 80) {
    goto(`topic/${topic.id}`);
    return;
  }
  const questions = questionsFor(topic.id, type).slice(
    0,
    type === "GOLDEN" ? 5 : 10,
  );
  if (questions.length !== (type === "GOLDEN" ? 5 : 10)) {
    goto(`topic/${topic.id}`);
    feedback =
      "The full question set is unavailable. Ask the teacher to complete it.";
    render();
    return;
  }
  const golden = type === "GOLDEN";
  const items = questions
    .map(
      (q, index) =>
        `<section class="q-card ${golden ? "gold" : ""}" id="question-${q.id}"><div class="q-number">${golden ? "Golden question" : "Question"} ${index + 1} of ${questions.length}</div><div class="q-text">${esc(q.question)}</div>${q.options.map((option, optionIndex) => `<label class="opt"><input type="radio" name="q${q.id}" value="${"ABCD"[optionIndex]}"><span class="letter">${"ABCD"[optionIndex]}</span><span>${esc(option)}</span></label>`).join("")}</section>`,
    )
    .join("");
  page(
    `${golden ? "Golden Assessment" : "Topic quiz"} · ${esc(topic.title)}`,
    golden
      ? "Five challenging questions. Answer all five; three correct is a pass."
      : "Ten questions. Answer each one, then submit for a real result.",
    `${golden ? `<div class="golden-banner mb-4"><h2>Golden Assessment · ${esc(topic.title)}</h2><p>You earned this by scoring above 80% in the topic quiz. Score at least 60% to pass.</p></div>` : ""}<div class="row"><div class="col-xl-9"><div class="quiz-progress"><div class="d-flex justify-content-between mb-2"><span class="stat-label mb-0">Answered</span><span class="figure-mono" id="answered-count">0 of ${questions.length}</span></div><div class="quiz-bar ${golden ? "gold" : ""}"><span id="quiz-fill"></span></div></div><form class="quiz-form" data-form="assessment" data-topic="${topic.id}" data-type="${type}">${items}<div class="card-soft p-3 d-flex justify-content-between align-items-center flex-wrap gap-2"><span class="text-muted-2" style="font-size:13px">${golden ? "Three of five correct passes." : "50% passes; above 80% opens Golden."}</span><button class="btn ${golden ? "btn-gold" : "btn-primary"} px-4 py-2" type="submit">Submit ${golden ? "Golden Assessment" : "quiz"}</button></div></form></div><div class="col-xl-3"><div class="card-soft p-3"><div class="stat-label">Before you submit</div><p class="text-muted-2 mb-2" style="font-size:13px">Each answer counts once. Your best score remains on the learning path.</p><a href="#topic/${topic.id}">← Back to notes</a></div></div></div>`,
    "modules",
  );
}

function latestRecommendation() {
  return state.recommendations
    .filter((rec) => rec.student === state.user)
    .sort((a, b) => b.id - a.id)[0];
}
function recommendationPage() {
  const recent = latestRecommendation();
  const history = state.recommendations
    .filter((rec) => rec.student === state.user)
    .sort((a, b) => b.id - a.id);
  const attempt =
    recent && state.attempts.find((a) => a.id === recent.attemptId);
  let actions = `<a class="btn btn-outline-secondary" href="#modules">See the path</a>`;
  if (recent && attempt) {
    const next = nextTopic(recent.topicId);
    if (recent.kind === "GOLDEN_ASSESSMENT")
      actions = `<a class="btn btn-gold" href="#golden/${recent.topicId}">Start Golden Assessment</a>${next && isOpen(state.user, next.id) ? `<a class="btn btn-primary" href="#topic/${next.id}">Continue with ${esc(next.title)}</a>` : ""}`;
    else if (recent.kind === "UNLOCK_ADVANCED")
      actions = `${next ? `<a class="btn btn-primary" href="#topic/${next.id}">Open ${esc(next.title)}</a>` : ""}<a class="btn btn-outline-secondary" href="#modules">See the path</a>`;
    else if (recent.kind === "ADVANCED_PRACTICE")
      actions = `<a class="btn btn-primary" href="#topic/${recent.topicId}">Go to advanced practice</a><a class="btn btn-gold" href="#golden/${recent.topicId}">Try Golden again</a>`;
    else if (recent.kind === "NEXT_TOPIC")
      actions =
        next && isOpen(state.user, next.id)
          ? `<a class="btn btn-primary" href="#topic/${next.id}">Continue with ${esc(next.title)}</a>`
          : `<a class="btn btn-primary" href="#quiz/${recent.topicId}">Retake for a higher score</a>`;
    else
      actions = `<a class="btn btn-primary" href="#topic/${recent.topicId}">Read the notes again</a><a class="btn btn-outline-secondary" href="#quiz/${recent.topicId}">Retake quiz</a>`;
  }
  const lead =
    recent && attempt
      ? `<div class="card-soft p-4 mb-4"><div class="row align-items-center g-4"><div class="col-md-auto text-center"><div class="score-ring" style="--ring-colour:${recent.kind === "REVISION" ? "var(--coral)" : recent.kind === "GOLDEN_ASSESSMENT" || attempt.type === "GOLDEN" ? "var(--gold)" : "var(--jade)"};--pct:${attempt.score}"><div><div class="score-value">${attempt.score}%</div><div class="score-sub">${attempt.correct}/${attempt.total}</div></div></div><div class="mt-2"><span class="pill ${attempt.type === "GOLDEN" ? "pill-gold" : "pill-idle"}">${attempt.type === "GOLDEN" ? "Golden Assessment" : "Topic quiz"}</span></div></div><div class="col-md"><div class="stat-label mb-2">${esc(topicById(recent.topicId)?.title)}</div><h2 class="section-title">${esc(recent.headline)}</h2><p style="line-height:1.6">${esc(recent.message)}</p><div class="demo-actions result-actions">${actions}</div></div></div>${
          attempt.answers
            ? `<div class="answer-review"><h3 class="section-title">Review your answers</h3>${attempt.answers
                .map((answer) => {
                  const q = state.questions.find(
                    (item) => item.id === answer.id,
                  );
                  return q
                    ? `<details><summary>${esc(q.question)} ${answer.chosen === q.correct ? "✓" : "✕"}</summary><p>Your answer: ${esc(q.options["ABCD".indexOf(answer.chosen)])}. Correct: ${esc(q.options["ABCD".indexOf(q.correct)])}.</p></details>`
                    : "";
                })
                .join("")}</div>`
            : ""
        }</div>`
      : `<div class="card-soft p-4 mb-4">No recommendation yet. <a href="#modules">Start the learning path.</a></div>`;
  page(
    "Recommendation",
    "Decided by the rules, from the score you earned.",
    `${lead}<div class="card-soft"><div class="p-4 pb-2 stat-label">Advice history</div>${history.length ? `<div class="table-wrap"><table class="table-clean"><thead><tr><th>Topic</th><th>Recommendation</th><th>When</th></tr></thead><tbody>${history.map((rec) => `<tr><td>${esc(topicById(rec.topicId)?.title || "Removed topic")}</td><td><strong>${esc(rec.headline)}</strong><div class="text-muted-2" style="font-size:12px">${esc(rec.message)}</div></td><td class="text-muted-2" style="white-space:nowrap;font-size:12px">${dateText(rec.date)}</td></tr>`).join("")}</tbody></table></div>` : `<p class="demo-empty">Recommendations appear after an assessment.</p>`}</div>`,
    "recommendations",
  );
}

function progressPage() {
  const list = orderedTopics(),
    attempts = studentAttempts().sort((a, b) => b.id - a.id);
  const quiz = attempts.filter((a) => a.type === "QUIZ");
  const done = list.filter(
    (topic) => bestScore(state.user, topic.id, "QUIZ") >= 50,
  ).length;
  const average = quiz.length
    ? Math.round(
        quiz.reduce((sum, attempt) => sum + attempt.score, 0) / quiz.length,
      )
    : 0;
  const bars = list
    .map((topic) => {
      const open = isOpen(state.user, topic.id),
        best = bestScore(state.user, topic.id, "QUIZ"),
        golden = bestScore(state.user, topic.id, "GOLDEN") >= 60;
      return `<div class="mb-3"><div class="d-flex justify-content-between align-items-center mb-1 flex-wrap gap-2"><div class="d-flex align-items-center gap-2"><span class="figure-mono text-muted-2">${String(topic.order).padStart(2, "0")}</span><strong>${esc(topic.title)}</strong><span class="pill ${topic.difficulty === "ADVANCED" ? "pill-advanced" : "pill-basic"}">${topic.difficulty}</span>${golden ? `<span class="pill pill-gold">Golden passed</span>` : ""}</div><span class="figure-mono">${open ? `${best}%` : "—"}</span></div><div class="progress" style="height:7px"><div class="progress-bar" role="progressbar" aria-label="${esc(topic.title)} best score" aria-valuenow="${best}" aria-valuemin="0" aria-valuemax="100" style="width:${open ? best : 0}%;background:${golden ? "var(--gold)" : best >= 50 ? "var(--jade)" : best ? "var(--coral)" : "var(--line)"}"></div></div></div>`;
    })
    .join("");
  page(
    "Your progress",
    "Best score per topic, and every attempt you have made.",
    `<div class="stats-grid">${stat("Course complete", `${Math.round((done / (list.length || 1)) * 100)}<small>%</small>`)}${stat("Average score", `${average}<small>%</small>`)}${stat("Quizzes taken", quiz.length)}${stat("Golden passed", list.filter((topic) => bestScore(state.user, topic.id, "GOLDEN") >= 60).length, "", true)}</div><div class="card-soft p-4 mb-4"><div class="stat-label mb-3">Topic by topic</div>${bars}</div><div class="card-soft"><div class="p-4 pb-2 stat-label">Every attempt · ${attempts.length}</div>${attemptTable(attempts)}</div>`,
    "progress",
  );
}

function teacherDashboard() {
  const attempts = [...state.attempts].sort((a, b) => b.id - a.id);
  const gold = attempts.filter((a) => a.type === "GOLDEN");
  page(
    "Hello, Anita",
    "Course activity across the demonstration students.",
    `<div class="stats-grid">${stat("Students", Object.keys(state.students).length)}${stat("Topics", state.topics.length)}${stat("Attempts", attempts.length)}${stat("Golden passed", `${gold.filter((a) => a.score >= 60).length}<small> / ${gold.length}</small>`, "", true)}</div><div class="dashboard-grid"><div class="card-soft p-4"><div class="stat-label mb-3">Manage the course</div><div class="d-grid gap-2"><a class="btn btn-primary" href="#topics">Topics</a><a class="btn btn-outline-secondary" href="#questions">Questions</a><a class="btn btn-outline-secondary" href="#attempts">Student attempts</a><a class="btn btn-outline-secondary" href="#recommendations">Recommendations (${state.recommendations.length})</a></div><p class="inline-help mt-3 mb-0">Edits are saved in this browser demo only. The Java app stores teacher edits in MySQL.</p></div><div class="card-soft"><div class="p-4 pb-2 d-flex justify-content-between"><div class="stat-label">Latest attempts</div><a href="#attempts" style="font-size:13px">See all</a></div>${attemptTable(attempts.slice(0, 6), true)}</div></div>`,
    "dashboard",
  );
}

function teacherTopics() {
  const rows = orderedTopics()
    .map(
      (topic) =>
        `<tr><td class="figure-mono">${String(topic.order).padStart(2, "0")}</td><td><strong>${esc(topic.title)}</strong><div class="text-muted-2" style="font-size:12px">${esc(topic.description)}</div></td><td><span class="pill ${topic.difficulty === "ADVANCED" ? "pill-advanced" : "pill-basic"}">${topic.difficulty}</span></td><td class="figure-mono">${state.questions.filter((q) => q.topicId === topic.id).length}</td><td><div class="teacher-actions"><a class="btn btn-outline-secondary btn-sm" href="#topic-admin/${topic.id}">Edit</a><button class="btn btn-outline-danger btn-sm" data-action="delete-topic" data-id="${topic.id}">Delete</button></div></td></tr>`,
    )
    .join("");
  page(
    "Manage topics",
    "The order of the topics is the learning path. Advanced topics sit behind a Golden gate.",
    `<div class="demo-toolbar"><span class="text-muted-2">${state.topics.length} topics</span><a class="btn btn-primary" href="#topic-admin/new">Add a topic</a></div><div class="card-soft table-wrap"><table class="table-clean"><thead><tr><th>Order</th><th>Topic</th><th>Level</th><th>Questions</th><th>Manage</th></tr></thead><tbody>${rows}</tbody></table></div>`,
    "topics",
  );
}

function teacherTopicForm(id) {
  const existing = id !== "new" ? topicById(id) : null;
  if (id !== "new" && !existing) {
    goto("topics");
    return;
  }
  const notesValue = existing
    ? existing.notesMode === "plain"
      ? existing.notes
      : new DOMParser()
          .parseFromString(existing.notes, "text/html")
          .body.textContent.trim()
    : "";
  page(
    existing ? `Edit ${esc(existing.title)}` : "Add a topic",
    "Changes are stored in this browser demo.",
    `<div class="card-soft p-4" style="max-width:760px"><form class="teacher-form" data-form="topic" data-id="${existing?.id || "new"}"><div class="form-row"><div class="form-group"><label for="topic-title">Title</label><input class="form-control" id="topic-title" name="title" required maxlength="100" value="${esc(existing?.title || "")}"></div><div class="form-group"><label for="topic-order">Position</label><input class="form-control" id="topic-order" name="order" type="number" min="1" max="99" required value="${existing?.order || orderedTopics().length + 1}"></div></div><div class="form-group"><label for="topic-description">Description</label><textarea class="form-control" id="topic-description" name="description" required maxlength="400">${esc(existing?.description || "")}</textarea></div><div class="form-group"><label for="topic-difficulty">Difficulty</label><select class="form-select" id="topic-difficulty" name="difficulty"><option value="BASIC" ${existing?.difficulty === "ADVANCED" ? "" : "selected"}>Basic</option><option value="ADVANCED" ${existing?.difficulty === "ADVANCED" ? "selected" : ""}>Advanced</option></select></div><div class="form-group"><label for="topic-notes">Notes</label><textarea class="form-control" id="topic-notes" name="notes" style="min-height:220px">${esc(notesValue)}</textarea><p class="inline-help mt-1">Edited notes are shown as plain text for safety. The original Java app supports teacher-authored HTML.</p></div><div class="demo-actions"><button class="btn btn-primary" type="submit">Save topic</button><a class="btn btn-outline-secondary" href="#topics">Cancel</a></div></form></div>`,
    "topics",
  );
}

function teacherQuestions(topicId) {
  const topic = topicById(topicId) || orderedTopics()[0];
  if (!topic) {
    page(
      "Manage questions",
      "Add a topic first.",
      `<a class="btn btn-primary" href="#topic-admin/new">Add a topic</a>`,
      "questions",
    );
    return;
  }
  const list = state.questions.filter((q) => q.topicId === topic.id);
  const select = `<label for="question-topic" class="form-label">Topic</label><select class="form-select" id="question-topic">${orderedTopics()
    .map(
      (item) =>
        `<option value="${item.id}" ${item.id === topic.id ? "selected" : ""}>${esc(item.title)}</option>`,
    )
    .join("")}</select>`;
  const rows = list
    .map(
      (q) =>
        `<tr><td><strong>${esc(q.question)}</strong><div class="text-muted-2" style="font-size:12px">Correct: ${q.correct} · ${esc(q.options["ABCD".indexOf(q.correct)])}</div></td><td><span class="pill ${q.type === "GOLDEN" ? "pill-gold" : "pill-idle"}">${q.type}</span></td><td>${q.difficulty}</td><td><div class="teacher-actions"><a class="btn btn-outline-secondary btn-sm" href="#question-admin/${q.id}">Edit</a><button class="btn btn-outline-danger btn-sm" data-action="delete-question" data-id="${q.id}">Delete</button></div></td></tr>`,
    )
    .join("");
  page(
    "Manage questions",
    "Practice is unscored. The ten-question quiz drives advice; five Golden questions guard the advanced path.",
    `<div class="demo-toolbar"><div style="min-width:230px">${select}</div><a class="btn btn-primary" href="#question-admin/new/${topic.id}">Add a question</a></div><div class="card-soft"><div class="p-4 pb-2"><div class="stat-label">${esc(topic.title)} · ${list.length} questions</div></div><div class="table-wrap"><table class="table-clean"><thead><tr><th>Question</th><th>Type</th><th>Difficulty</th><th>Manage</th></tr></thead><tbody>${rows}</tbody></table></div></div>`,
    "questions",
  );
}

function teacherQuestionForm(id, newTopicId) {
  const existing =
    id !== "new" ? state.questions.find((q) => q.id === Number(id)) : null;
  if (id !== "new" && !existing) {
    goto("questions");
    return;
  }
  const topicId =
    existing?.topicId || Number(newTopicId) || orderedTopics()[0]?.id;
  const options = existing?.options || ["", "", "", ""];
  page(
    existing ? "Edit question" : "Add a question",
    "Changes are stored in this browser demo.",
    `<div class="card-soft p-4" style="max-width:760px"><form class="teacher-form" data-form="question" data-id="${existing?.id || "new"}"><div class="form-row"><div class="form-group"><label for="question-topic-id">Topic</label><select class="form-select" id="question-topic-id" name="topicId">${orderedTopics()
      .map(
        (topic) =>
          `<option value="${topic.id}" ${topic.id === topicId ? "selected" : ""}>${esc(topic.title)}</option>`,
      )
      .join(
        "",
      )}</select></div><div class="form-group"><label for="question-type">Type</label><select class="form-select" id="question-type" name="type">${["PRACTICE", "QUIZ", "GOLDEN"].map((type) => `<option value="${type}" ${type === (existing?.type || "QUIZ") ? "selected" : ""}>${type}</option>`).join("")}</select></div></div><div class="form-row"><div class="form-group"><label for="question-difficulty">Difficulty</label><select class="form-select" id="question-difficulty" name="difficulty">${["EASY", "MEDIUM", "HARD"].map((level) => `<option value="${level}" ${level === (existing?.difficulty || "EASY") ? "selected" : ""}>${level}</option>`).join("")}</select></div><div class="form-group"><label for="question-correct">Correct answer</label><select class="form-select" id="question-correct" name="correct">${["A", "B", "C", "D"].map((letter) => `<option value="${letter}" ${letter === (existing?.correct || "A") ? "selected" : ""}>${letter}</option>`).join("")}</select></div></div><div class="form-group"><label for="question-text">Question</label><textarea class="form-control" id="question-text" name="question" required maxlength="1000">${esc(existing?.question || "")}</textarea></div>${options.map((option, index) => `<div class="form-group"><label for="option-${index}">Option ${"ABCD"[index]}</label><input class="form-control" id="option-${index}" name="option${index}" required maxlength="500" value="${esc(option)}"></div>`).join("")}<div class="demo-actions"><button class="btn btn-primary" type="submit">Save question</button><a class="btn btn-outline-secondary" href="#questions/${topicId}">Cancel</a></div></form></div>`,
    "questions",
  );
}

function teacherAttempts() {
  page(
    "Student attempts",
    "Every quiz and Golden result recorded in this browser demo.",
    `<div class="card-soft"><div class="p-4 pb-2 stat-label">${state.attempts.length} attempts</div>${attemptTable(
      [...state.attempts].sort((a, b) => b.id - a.id),
      true,
    )}</div>`,
    "attempts",
  );
}

function teacherRecommendations() {
  const rows = [...state.recommendations].sort((a, b) => b.id - a.id);
  page(
    "Student recommendations",
    "Advice generated from each actual answer score using the MVP rules.",
    `<div class="card-soft"><div class="p-4 pb-2 stat-label">${rows.length} recommendations</div>${rows.length ? `<div class="table-wrap"><table class="table-clean"><thead><tr><th>Student</th><th>Topic</th><th>Decision</th><th>When</th></tr></thead><tbody>${rows.map((rec) => `<tr><td>${esc(state.students[rec.student]?.name)}</td><td>${esc(topicById(rec.topicId)?.title || "Removed topic")}</td><td><strong>${esc(rec.headline)}</strong><div class="text-muted-2" style="font-size:12px">${esc(rec.message)}</div></td><td class="text-muted-2" style="white-space:nowrap;font-size:12px">${dateText(rec.date)}</td></tr>`).join("")}</tbody></table></div>` : `<p class="demo-empty">No recommendations yet.</p>`}</div>`,
    "recommendations",
  );
}

function render() {
  if (!seed || !state) return;
  if (!state.user) {
    chooseAccount();
    return;
  }
  const [screen = "dashboard", arg, more] = route();
  if (state.user === "teacher") {
    if (screen === "topics") teacherTopics();
    else if (screen === "topic-admin") teacherTopicForm(arg || "new");
    else if (screen === "questions") teacherQuestions(arg);
    else if (screen === "question-admin")
      teacherQuestionForm(arg || "new", more);
    else if (screen === "attempts") teacherAttempts();
    else if (screen === "recommendations") teacherRecommendations();
    else teacherDashboard();
  } else {
    if (screen === "modules") modulesPage();
    else if (screen === "topic") topicPage(arg);
    else if (screen === "quiz") assessmentPage(arg, "QUIZ");
    else if (screen === "golden") assessmentPage(arg, "GOLDEN");
    else if (screen === "recommendations") recommendationPage();
    else if (screen === "progress") progressPage();
    else studentDashboard();
  }
}

document.addEventListener("click", (event) => {
  const control = event.target.closest("[data-action]");
  if (!control || !state) return;
  const action = control.dataset.action;
  if (action === "login") {
    state.user = control.dataset.user;
    save();
    goto("dashboard");
  } else if (action === "logout") {
    state.user = null;
    save();
    location.hash = "";
    render();
    window.scrollTo(0, 0);
  } else if (action === "reset") {
    if (
      !confirm(
        "Reset the browser demo? Your quiz attempts and course edits on this device will be removed.",
      )
    )
      return;
    state = freshState();
    save();
    location.hash = "";
    render();
    window.scrollTo(0, 0);
  } else if (action === "delete-topic") {
    const id = Number(control.dataset.id);
    if (
      !confirm(
        `Delete ${topicById(id)?.title || "this topic"} and its questions from this browser demo?`,
      )
    )
      return;
    state.topics = state.topics.filter((topic) => topic.id !== id);
    state.questions = state.questions.filter(
      (question) => question.topicId !== id,
    );
    state.attempts = state.attempts.filter((attempt) => attempt.topicId !== id);
    state.recommendations = state.recommendations.filter(
      (rec) => rec.topicId !== id,
    );
    save();
    render();
  } else if (action === "delete-question") {
    const id = Number(control.dataset.id);
    const question = state.questions.find((item) => item.id === id);
    if (!question || !confirm("Delete this question from the browser demo?"))
      return;
    state.questions = state.questions.filter((item) => item.id !== id);
    save();
    render();
  }
});

document.addEventListener("change", (event) => {
  if (event.target.id === "question-topic") {
    goto(`questions/${event.target.value}`);
    return;
  }
  if (event.target.matches(".quiz-form input[type=radio]")) {
    const form = event.target.closest(".quiz-form");
    const total = form.querySelectorAll(".q-card").length;
    const answered = new Set(
      [...form.querySelectorAll("input[type=radio]:checked")].map(
        (input) => input.name,
      ),
    ).size;
    document.getElementById("answered-count").textContent =
      `${answered} of ${total}`;
    document.getElementById("quiz-fill").style.width =
      `${Math.round((answered / total) * 100)}%`;
    event.target.closest(".q-card")?.classList.add("answered");
    form.querySelector(".demo-alert.error")?.remove();
  }
});

document.addEventListener("submit", (event) => {
  const form = event.target;
  if (!form.matches("[data-form]")) return;
  event.preventDefault();
  if (form.dataset.form === "assessment") {
    const topicId = Number(form.dataset.topic),
      type = form.dataset.type;
    if (
      !isOpen(state.user, topicId) ||
      (type === "GOLDEN" && bestScore(state.user, topicId, "QUIZ") <= 80)
    ) {
      goto("modules");
      return;
    }
    const questions = questionsFor(topicId, type).slice(
      0,
      type === "GOLDEN" ? 5 : 10,
    );
    const values = new FormData(form);
    const missing = questions.find((q) => !values.get(`q${q.id}`));
    if (missing) {
      form.querySelector(".demo-alert.error")?.remove();
      const error = document.createElement("div");
      error.className = "demo-alert error";
      error.setAttribute("role", "alert");
      error.textContent = "Answer every question before submitting.";
      form.prepend(error);
      document
        .getElementById(`question-${missing.id}`)
        ?.scrollIntoView({ behavior: "smooth", block: "center" });
      return;
    }
    const answers = questions.map((q) => ({
      id: q.id,
      chosen: values.get(`q${q.id}`),
    }));
    const correct = answers.filter(
      (answer) =>
        state.questions.find((q) => q.id === answer.id)?.correct ===
        answer.chosen,
    ).length;
    const attempt = {
      id: Math.max(0, ...state.attempts.map((a) => a.id)) + 1,
      student: state.user,
      topicId,
      type,
      score: Math.round((correct / questions.length) * 100),
      correct,
      total: questions.length,
      date: new Date().toISOString(),
      answers,
    };
    state.attempts.push(attempt);
    state.recommendations.push({
      id: Math.max(0, ...state.recommendations.map((rec) => rec.id)) + 1,
      student: state.user,
      topicId,
      attemptId: attempt.id,
      date: attempt.date,
      ...recommend(attempt),
    });
    save();
    goto("recommendations");
  } else if (form.dataset.form === "topic") {
    const values = new FormData(form);
    const id =
      form.dataset.id === "new"
        ? Math.max(0, ...state.topics.map((topic) => topic.id)) + 1
        : Number(form.dataset.id);
    const topic = {
      id,
      title: String(values.get("title")).trim(),
      description: String(values.get("description")).trim(),
      difficulty: values.get("difficulty"),
      order: Number(values.get("order")),
      notes: String(values.get("notes")).trim(),
      notesMode: "plain",
    };
    if (
      !topic.title ||
      !topic.description ||
      !Number.isInteger(topic.order) ||
      topic.order < 1
    )
      return;
    const existing = state.topics.findIndex((item) => item.id === id);
    if (existing >= 0) state.topics[existing] = topic;
    else state.topics.push(topic);
    save();
    goto("topics");
  } else if (form.dataset.form === "question") {
    const values = new FormData(form);
    const id =
      form.dataset.id === "new"
        ? Math.max(0, ...state.questions.map((q) => q.id)) + 1
        : Number(form.dataset.id);
    const question = {
      id,
      topicId: Number(values.get("topicId")),
      type: values.get("type"),
      difficulty: values.get("difficulty"),
      correct: values.get("correct"),
      question: String(values.get("question")).trim(),
      options: [0, 1, 2, 3].map((index) =>
        String(values.get(`option${index}`)).trim(),
      ),
    };
    if (
      !topicById(question.topicId) ||
      !question.question ||
      question.options.some((option) => !option)
    )
      return;
    const existing = state.questions.findIndex((item) => item.id === id);
    if (existing >= 0) state.questions[existing] = question;
    else state.questions.push(question);
    save();
    goto(`questions/${question.topicId}`);
  }
});

window.addEventListener("hashchange", () => {
  feedback = "";
  render();
  window.scrollTo(0, 0);
});

fetch("data.json")
  .then((response) => {
    if (!response.ok) throw new Error("Course data could not be loaded.");
    return response.json();
  })
  .then((data) => {
    if (data.topics?.length !== 8 || data.questions?.length !== 200)
      throw new Error("Course data is incomplete.");
    seed = data;
    try {
      const saved = JSON.parse(localStorage.getItem(storeKey));
      state =
        saved?.version === 1 &&
        Array.isArray(saved.topics) &&
        Array.isArray(saved.questions) &&
        Array.isArray(saved.attempts) &&
        saved.students
          ? saved
          : freshState();
    } catch (_) {
      state = freshState();
    }
    render();
  })
  .catch((error) => {
    app.innerHTML = `<main class="loading-page" id="main"><h1>Course data unavailable</h1><p>${esc(error.message)}</p><button class="btn btn-primary" onclick="location.reload()">Try again</button></main>`;
  });
