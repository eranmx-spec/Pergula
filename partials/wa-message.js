/* ====================================================================
   מרכיב את ההודעה שנפתחת בוואטסאפ — בכל העמודים ובכל הכפתורים.

   כל הודעה נפתחת בשורת מקור: האתר, העמוד, והכפתור שנלחץ (ערך
   התכונה data-wa). אם הלקוח כבר השאיר פרטים, בטופס או באשף, מצורף
   להודעה גם סיכום שלהם.

   הסיכום נשמר ב-sessionStorage: עובר בין העמודים באותה לשונית,
   ונמחק כשהיא נסגרת.
   ==================================================================== */
window.PERGULA_WA = (function () {
  "use strict";
  var C = window.PERGULA || {};
  var KEY = "pergula-lead";
  // כתובת קבועה ולא location, כדי שגם בדיקה מקובץ מקומי תציג את האתר האמיתי
  var SITE_URL = "http://pergula.online/";
  var PAGES = { "terms.html": "תנאי שימוש", "accessibility.html": "הצהרת נגישות" };

  function sourceLine(where) {
    var file = location.pathname.split("/").pop();
    var parts = ["📍 הגיע מאתר " + SITE_URL, PAGES[file] || "דף הבית"];
    if (where) parts.push(where);
    return parts.join(" · ");
  }

  // lead: { kind: "form" | "wizard", rows: [{label, value}], questions: [] }
  function loadLead() {
    try { return JSON.parse(sessionStorage.getItem(KEY)); } catch (e) { return null; }
  }

  function saveLead(lead) {
    try { sessionStorage.setItem(KEY, JSON.stringify(lead)); } catch (e) { /* ההודעה הנוכחית עדיין תכלול אותו */ }
    refresh(lead);
  }

  // שורות הסיכום עם הדגשות וואטסאפ (*...*)
  function summary(lead) {
    var out = [];
    lead.rows.forEach(function (r) {
      if (r.value && r.value !== "—") out.push("*" + r.label + ":* " + r.value);
    });
    if (lead.questions && lead.questions.length) {
      out.push("", "*שאלות שלי:*");
      lead.questions.forEach(function (q) { out.push("• " + q); });
    }
    return out.join("\n");
  }

  function text(where, lead) {
    lead = lead || loadLead();
    var out = [sourceLine(where), ""];
    if (!lead || !lead.rows) {
      out.push(C.whatsappText || "");
    } else {
      out.push(lead.kind === "wizard"
        ? "היי, מילאתי את אשף הפרויקט באתר. זה הסיכום:"
        : "היי, השארתי פרטים באתר. זה הסיכום:");
      out.push("", summary(lead), "", "אשמח שתחזרו אליי עם הצעת מחיר ותיאום מדידה.");
    }
    return out.join("\n");
  }

  function href(where, lead) {
    return "https://wa.me/" + C.whatsapp + "?text=" + encodeURIComponent(text(where, lead));
  }

  // מעדכן את כל קישורי [data-wa] בעמוד. נקרא אחרי שה-DOM קיים.
  function refresh(lead) {
    lead = lead || loadLead();
    Array.prototype.forEach.call(document.querySelectorAll("[data-wa]"), function (el) {
      el.setAttribute("href", href(el.getAttribute("data-wa"), lead));
    });
  }

  return { text: text, href: href, summary: summary, saveLead: saveLead, refresh: refresh };
})();
