/* ====================================================================
   תפריט נגישות
   --------------------------------------------------------------------
   ההעדפות נשמרות ב-localStorage של הגולש בלבד ואינן מגיעות לשרת. כל
   קריאה וכתיבה עטופות ב-try/catch, כי בחלון פרטי או כשחסימת אחסון
   מופעלת הגישה עצמה זורקת — והדף חייב לעבוד גם אז.
   ==================================================================== */
(function () {
  "use strict";

  var KEY = "pergula-a11y";
  var FLAGS = ["contrast", "gray", "readable", "links", "nomotion", "cursor", "guide"];
  var root = document.documentElement;

  var openBtn  = document.getElementById("a11y-open");
  var panel    = document.getElementById("a11y-panel");
  var closeBtn = document.getElementById("a11y-close");
  var resetBtn = document.getElementById("a11y-reset");
  var guideEl  = document.querySelector(".read-guide");
  if (!openBtn || !panel) return;

  var state = { size: 0, on: {} };

  function load() {
    try {
      var raw = window.localStorage.getItem(KEY);
      if (!raw) return;
      var s = JSON.parse(raw);
      if (s && typeof s.size === "number" && s.size >= 0 && s.size <= 3) state.size = s.size;
      if (s && s.on) FLAGS.forEach(function (f) { if (s.on[f]) state.on[f] = true; });
    } catch (err) { /* אין אחסון זמין — נשארים בברירת המחדל */ }
  }

  function save() {
    try { window.localStorage.setItem(KEY, JSON.stringify(state)); }
    catch (err) { /* לא קריטי: ההגדרות פשוט לא ישרדו רענון */ }
  }

  function apply() {
    for (var i = 1; i <= 3; i++) root.classList.toggle("a11y-fs-" + i, state.size === i);
    FLAGS.forEach(function (f) { root.classList.toggle("a11y-" + f, !!state.on[f]); });

    Array.prototype.forEach.call(panel.querySelectorAll("[data-a11y-size]"), function (b) {
      b.setAttribute("aria-pressed", String(Number(b.getAttribute("data-a11y-size")) === state.size));
    });
    Array.prototype.forEach.call(panel.querySelectorAll("[data-a11y]"), function (b) {
      b.setAttribute("aria-pressed", String(!!state.on[b.getAttribute("data-a11y")]));
    });
  }

  Array.prototype.forEach.call(panel.querySelectorAll("[data-a11y-size]"), function (b) {
    b.addEventListener("click", function () {
      state.size = Number(b.getAttribute("data-a11y-size"));
      apply(); save();
    });
  });

  Array.prototype.forEach.call(panel.querySelectorAll("[data-a11y]"), function (b) {
    b.addEventListener("click", function () {
      var f = b.getAttribute("data-a11y");
      if (state.on[f]) delete state.on[f]; else state.on[f] = true;
      apply(); save();
    });
  });

  resetBtn.addEventListener("click", function () {
    state = { size: 0, on: {} };
    apply(); save();
    openBtn.focus();
  });

  function openPanel() {
    panel.hidden = false;
    openBtn.setAttribute("aria-expanded", "true");
    var first = panel.querySelector("button");
    if (first) first.focus();
  }

  function closePanel(refocus) {
    panel.hidden = true;
    openBtn.setAttribute("aria-expanded", "false");
    if (refocus) openBtn.focus();
  }

  openBtn.addEventListener("click", function () {
    if (panel.hidden) openPanel(); else closePanel(true);
  });
  closeBtn.addEventListener("click", function () { closePanel(true); });

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && !panel.hidden) closePanel(true);
  });

  document.addEventListener("click", function (e) {
    if (panel.hidden) return;
    if (panel.contains(e.target) || openBtn.contains(e.target)) return;
    closePanel(false);
  });

  // קו הקריאה עוקב אחרי הסמן וגם אחרי המיקוד, כדי שיעבוד בניווט מקלדת
  function moveGuide(y) {
    if (!state.on.guide || !guideEl) return;
    guideEl.style.top = Math.max(0, y - 21) + "px";
  }
  document.addEventListener("mousemove", function (e) { moveGuide(e.clientY); });
  document.addEventListener("focusin", function (e) {
    if (!state.on.guide || !e.target || !e.target.getBoundingClientRect) return;
    var r = e.target.getBoundingClientRect();
    moveGuide(r.top + r.height / 2);
  });

  load();
  apply();
})();
