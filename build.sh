#!/usr/bin/env bash
# בונה את שלושת העמודים המתפרסמים:
#   index.html         מ- page.body.html
#   terms.html         מ- docs/terms.body.html
#   accessibility.html מ- docs/accessibility.body.html
#
# מקורות האמת הם page.body.html, docs/*.body.html ו-partials/.
# אין לערוך את קבצי ה-html שנבנים — הם נדרסים בכל הרצה.
set -euo pipefail
cd "$(dirname "$0")"

SITE_URL="https://pergula.online"
STYLE=$(sed -n '/^<style>$/,/^<\/style>$/p' page.body.html)
A11Y_UI=$(cat partials/a11y-ui.html)
CONFIG_JS=$(cat partials/config.js; echo; cat partials/wa-message.js)
A11Y_JS=$(cat partials/a11y.js)
WA_JS=$(cat partials/wa-links.js)

if [ -z "$STYLE" ]; then echo "שגיאה: לא נמצא בלוק <style> ב-page.body.html" >&2; exit 1; fi

# ---------------------------------------------------------------- head
# $1 title · $2 description · $3 canonical path · $4 extra head lines
emit_head () {
  cat <<HEAD
<!doctype html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$1</title>
<meta name="description" content="$2">
<meta name="theme-color" content="#7A4A21">
<link rel="canonical" href="$SITE_URL$3">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 34 34'%3E%3Crect width='34' height='34' fill='%237A4A21'/%3E%3Cg fill='%23FAF4EC'%3E%3Crect x='4' y='9' width='26' height='2.6'/%3E%3Crect x='4' y='22.4' width='26' height='2.6'/%3E%3C/g%3E%3Cg fill='%23FAF4EC' opacity='.6'%3E%3Crect x='7' y='5' width='2.4' height='24'/%3E%3Crect x='14' y='5' width='2.4' height='24'/%3E%3Crect x='21' y='5' width='2.4' height='24'/%3E%3C/g%3E%3C/svg%3E">
$4
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Frank+Ruhl+Libre:wght@500;700;900&family=Assistant:wght@300;400;600;700&family=Heebo:wght@400;500;700&display=swap">
$STYLE
HEAD
}

# --------------------------------------------------------------- index
SPLIT=$(grep -n -F '<div class="page" lang="he">' page.body.html | head -1 | cut -d: -f1)
BODY=$(tail -n +"$SPLIT" page.body.html)

{
  emit_head \
    "עץ וצל" \
    "פרגולות, דקים, מעקות עץ וגדרות בתכנון אישי — ייצור בנגרייה עצמית, מדידה בבית ללא עלות ואחריות 5 שנים על השלד." \
    "/" \
    "$(cat <<'OG'
<meta property="og:type" content="website">
<meta property="og:locale" content="he_IL">
<meta property="og:url" content="https://pergula.online/">
<meta property="og:title" content="עץ וצל — פרגולות, דקים, מעקות וגדרות">
<meta property="og:description" content="מתוכננים למידות המרפסת או החצר שלכם, מיוצרים בנגרייה שלנו ומורכבים בהתקנה אחת.">
<meta property="og:image" content="https://pergula.online/img/pergola-wave-railing.jpg">
<meta name="twitter:card" content="summary_large_image">
OG
)"
  echo '</head>'
  echo '<body>'
  # ההגדרות חייבות להיטען לפני סקריפט הדף, שקורא מ-window.PERGULA
  echo '<script>'
  echo "$CONFIG_JS"
  echo '</script>'
  echo "$A11Y_UI"
  # סקריפט הדף הראשי מגיע כחלק מ-$BODY
  echo "$BODY"
  echo '<script>'
  echo "$A11Y_JS"
  echo '</script>'
  echo '</body>'
  echo '</html>'
} > index.html

# ------------------------------------------------------- doc pages CSS
DOC_CSS=$(cat <<'CSS'
<style>
/* עמודי מסמך: טיפוגרפיה לקריאה רצופה, על אותם גוונים של הדף הראשי */
.doc{
  direction:rtl;background:var(--bg);color:var(--ink);
  font-family:"Assistant","Segoe UI",system-ui,sans-serif;font-size:17px;line-height:1.75;
}
.doc-wrap{max-width:760px;margin-inline:auto;padding:26px 22px 80px}
.doc-nav{display:flex;align-items:center;justify-content:space-between;gap:16px;
  max-width:760px;margin-inline:auto;padding:16px 22px}
.doc-nav a.back{font-family:"Heebo",sans-serif;font-size:14.5px;font-weight:500;
  color:var(--ink);text-decoration:none;border:1px solid var(--line);border-radius:999px;padding:8px 16px}
.doc-nav a.back:hover{background:var(--surface);border-color:var(--ink-soft)}
.doc h1{font-family:"Frank Ruhl Libre",Georgia,serif;font-weight:900;font-size:clamp(30px,4.4vw,44px);
  line-height:1.15;letter-spacing:-.015em;margin:0 0 10px;text-wrap:balance}
.doc h2{font-family:"Frank Ruhl Libre",Georgia,serif;font-weight:700;font-size:22px;
  line-height:1.25;margin:38px 0 12px;padding-top:18px;border-top:1px solid var(--line-soft);text-wrap:balance}
.doc p{margin:0 0 14px}
.doc ul{margin:0 0 16px;padding-inline-start:22px}
.doc li{margin-bottom:8px}
.doc b{font-weight:700}
.doc code{font-family:ui-monospace,"Courier New",monospace;font-size:.9em;
  background:var(--surface-2);border:1px solid var(--line-soft);border-radius:3px;padding:1px 5px}
.doc a{color:var(--accent);text-decoration:underline;text-underline-offset:2px}
.doc :focus-visible{outline:2.5px solid var(--honey);outline-offset:3px;border-radius:2px}
.doc-eyebrow{font-family:"Heebo",sans-serif;font-size:12px;font-weight:500;letter-spacing:.14em;
  color:var(--muted);margin:0 0 12px}
.doc-updated{font-family:"Heebo",sans-serif;font-size:13px;color:var(--muted);margin:0 0 26px}
.doc-lede{font-size:19px;color:var(--ink-soft);font-weight:300;
  border-inline-start:3px solid var(--accent);padding-inline-start:16px;margin-bottom:34px}
.doc-flag{background:var(--honey-quiet);border:1px solid var(--honey);border-radius:var(--radius);
  padding:16px 18px;margin-top:40px;font-size:14.5px;line-height:1.7}
.doc-contact{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:18px 20px;margin-top:26px}
.doc-grp{font-family:"Heebo",sans-serif;font-size:11.5px;font-weight:700;letter-spacing:.1em;
  color:var(--muted);margin:0 0 10px}
.doc-kv{list-style:none;padding:0;margin:0;border-top:1px solid var(--line-soft)}
.doc-kv li{display:flex;justify-content:space-between;gap:16px;padding:10px 0;
  border-bottom:1px solid var(--line-soft);margin:0;font-size:15px}
.doc-kv span{color:var(--muted)}
.doc-kv b{font-family:"Heebo",sans-serif;font-weight:500;text-align:end}
.doc-kv b[data-fill]{color:var(--honey);font-weight:700}
.doc-foot{max-width:760px;margin-inline:auto;padding:22px;border-top:1px solid var(--line-soft);
  font-size:13px;color:var(--muted);display:flex;flex-wrap:wrap;gap:10px 22px;justify-content:space-between}
.doc-foot a{color:var(--muted)}
@media (max-width:620px){.doc{font-size:16px}.doc h2{font-size:20px}}
</style>
CSS
)

# $1 outfile · $2 body file · $3 title · $4 description · $5 canonical
build_doc () {
  {
    emit_head "$3" "$4" "$5" '<meta name="robots" content="index,follow">'
    echo "$DOC_CSS"
    echo '</head>'
    echo '<body class="doc">'
    echo '<script>'
    echo "$CONFIG_JS"
    echo '</script>'
    echo "$A11Y_UI"
    cat <<NAV
<nav class="doc-nav" aria-label="ניווט">
  <span style="font-family:'Frank Ruhl Libre',Georgia,serif;font-weight:900;font-size:19px">עץ וצל</span>
  <a class="back" href="index.html">חזרה לדף הראשי &#8592;</a>
</nav>
<main id="main" class="doc-wrap">
NAV
    cat "$2"
    cat <<FOOT
</main>
<footer class="doc-foot">
  <span><a href="index.html">דף ראשי</a> · <a href="terms.html">תנאי שימוש</a> · <a href="accessibility.html">הצהרת נגישות</a></span>
  <span>עץ וצל · נגרות חוץ</span>
</footer>
FOOT
    echo '<script>'
    echo "$WA_JS"
    echo "$A11Y_JS"
    echo '</script>'
    echo '</body>'
    echo '</html>'
  } > "$1"
}

build_doc terms.html docs/terms.body.html \
  "תנאי שימוש" \
  "תנאי השימוש באתר: מהות האתר, אחריות על ביצוע העבודה, מחירים, תמונות להמחשה ופרטיות." \
  "/terms.html"

build_doc accessibility.html docs/accessibility.body.html \
  "הצהרת נגישות" \
  "הצהרת נגישות לפי תקנות שוויון זכויות לאנשים עם מוגבלות ות״י 5568, כולל מה הונגש ודרכי פנייה." \
  "/accessibility.html"

for f in index.html terms.html accessibility.html; do
  printf '%-22s %s בתים\n' "$f" "$(wc -c < "$f")"
done
