/* ====================================================================
   ממלא קישורי וואטסאפ ומספרים מתוך window.PERGULA, וכן את פרטי רכז
   הנגישות בהצהרת הנגישות. משמש את עמודי המסמכים; בדף הראשי הלוגיקה
   הזו כבר חלק מהסקריפט הראשי.
   ==================================================================== */
(function () {
  "use strict";
  var C = window.PERGULA || {};
  var href = "https://wa.me/" + C.whatsapp + "?text=" + encodeURIComponent(C.whatsappText || "");

  Array.prototype.forEach.call(document.querySelectorAll("[data-wa]"), function (el) {
    el.setAttribute("href", href);
  });
  Array.prototype.forEach.call(document.querySelectorAll("[data-wa-num]"), function (el) {
    el.textContent = C.whatsappDisplay || "";
  });

  // פרטי רכז הנגישות. נשארים „להשלמה" כל עוד לא הוזנו ב-config.js,
  // כדי שלא ייראה כאילו הדרישה מולאה כשהיא לא.
  var map = { name: C.a11yContactName, phone: C.a11yContactPhone, email: C.a11yContactEmail };
  Array.prototype.forEach.call(document.querySelectorAll("[data-a11y-contact]"), function (el) {
    var v = map[el.getAttribute("data-a11y-contact")];
    if (!v) return;
    el.textContent = v;
    el.removeAttribute("data-fill");
  });
})();
