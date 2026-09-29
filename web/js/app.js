/* =====================================================================
   Adaptive Personalised Learning Path Recommender
   app.js - the only JavaScript in the project.

   IMPORTANT: nothing here is security. Every rule this file applies is
   applied again on the server by Validator and by the servlets. This file
   exists to make the pages pleasant to use, not to protect them.
   ===================================================================== */
(function () {
    "use strict";

    document.addEventListener("DOMContentLoaded", function () {
        setUpQuiz();
        setUpRegisterForm();
        setUpLoginForm();
        setUpConfirmButtons();
        setUpScoreRing();
    });

    /* -----------------------------------------------------------------
       1. QUIZ
          - highlights the option that was chosen
          - fills the progress bar as questions are answered
          - warns before submitting a partly finished quiz
       ----------------------------------------------------------------- */
    function setUpQuiz() {
        var form = document.getElementById("quizForm");
        if (!form) {
            return;
        }

        var cards = form.querySelectorAll(".q-card");
        var bar = document.getElementById("quizBarFill");
        var counter = document.getElementById("quizAnswered");
        var total = cards.length;

        function refresh() {
            var answered = 0;
            for (var i = 0; i < cards.length; i++) {
                var card = cards[i];
                var picked = card.querySelector("input[type=radio]:checked");

                // clear the previous highlight
                var opts = card.querySelectorAll(".opt");
                for (var j = 0; j < opts.length; j++) {
                    opts[j].classList.remove("picked");
                }

                if (picked) {
                    answered++;
                    card.classList.add("answered");
                    var label = picked.closest(".opt");
                    if (label) {
                        label.classList.add("picked");
                    }
                } else {
                    card.classList.remove("answered");
                }
            }
            if (bar) {
                bar.style.width = (total === 0 ? 0 : (answered / total) * 100) + "%";
            }
            if (counter) {
                counter.textContent = answered + " of " + total;
            }
        }

        form.addEventListener("change", function (e) {
            if (e.target && e.target.type === "radio") {
                refresh();
            }
        });

        form.addEventListener("submit", function (e) {
            var answered = form.querySelectorAll("input[type=radio]:checked").length;
            if (answered < total) {
                var left = total - answered;
                var ok = window.confirm(
                    "You have not answered " + left + " question" + (left === 1 ? "" : "s") +
                    ". Unanswered questions are marked wrong.\n\nSubmit anyway?");
                if (!ok) {
                    e.preventDefault();
                    return;
                }
            }
            // stop a double click from submitting the quiz twice
            var button = document.getElementById("quizSubmit");
            if (button) {
                button.disabled = true;
                button.textContent = "Checking your answers...";
            }
        });

        refresh();
    }

    /* -----------------------------------------------------------------
       2. REGISTRATION FORM
       ----------------------------------------------------------------- */
    function setUpRegisterForm() {
        var form = document.getElementById("registerForm");
        if (!form) {
            return;
        }

        var password = form.querySelector("#password");
        var confirm = form.querySelector("#confirmPassword");
        var note = document.getElementById("passwordNote");

        function checkMatch() {
            if (!confirm.value) {
                note.textContent = "";
                confirm.setCustomValidity("");
                return;
            }
            if (password.value !== confirm.value) {
                note.textContent = "The two passwords do not match.";
                note.className = "small mt-1 text-danger";
                confirm.setCustomValidity("Passwords do not match");
            } else {
                note.textContent = "Passwords match.";
                note.className = "small mt-1 text-success";
                confirm.setCustomValidity("");
            }
        }

        if (password && confirm && note) {
            password.addEventListener("input", checkMatch);
            confirm.addEventListener("input", checkMatch);
        }

        form.addEventListener("submit", function (e) {
            if (password.value.length < 6) {
                e.preventDefault();
                note.textContent = "The password must be at least 6 characters long.";
                note.className = "small mt-1 text-danger";
                password.focus();
            }
        });
    }

    /* -----------------------------------------------------------------
       3. LOGIN FORM - fills in a demo account when one is clicked
       ----------------------------------------------------------------- */
    function setUpLoginForm() {
        var buttons = document.querySelectorAll("[data-demo-email]");
        for (var i = 0; i < buttons.length; i++) {
            buttons[i].addEventListener("click", function () {
                var email = document.getElementById("email");
                var password = document.getElementById("password");
                var role = document.querySelector(
                    "input[name=role][value=" + this.getAttribute("data-demo-role") + "]");
                if (email)    { email.value = this.getAttribute("data-demo-email"); }
                if (password) { password.value = this.getAttribute("data-demo-password"); }
                if (role)     { role.checked = true; }
                if (email)    { email.focus(); }
            });
        }
    }

    /* -----------------------------------------------------------------
       4. Ask before anything is deleted
       ----------------------------------------------------------------- */
    function setUpConfirmButtons() {
        var forms = document.querySelectorAll("form[data-confirm]");
        for (var i = 0; i < forms.length; i++) {
            forms[i].addEventListener("submit", function (e) {
                if (!window.confirm(this.getAttribute("data-confirm"))) {
                    e.preventDefault();
                }
            });
        }
    }

    /* -----------------------------------------------------------------
       5. Animate the score ring once, unless reduced motion was asked for
       ----------------------------------------------------------------- */
    function setUpScoreRing() {
        var ring = document.getElementById("scoreRing");
        if (!ring) {
            return;
        }
        var target = parseInt(ring.getAttribute("data-score"), 10) || 0;

        if (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
            ring.style.setProperty("--pct", target);
            return;
        }

        var current = 0;
        var step = Math.max(1, Math.round(target / 28));
        var timer = setInterval(function () {
            current += step;
            if (current >= target) {
                current = target;
                clearInterval(timer);
            }
            ring.style.setProperty("--pct", current);
        }, 18);
    }
})();
