#!/usr/bin/env bash
# בונה את index.html (הדף שמתפרסם) מתוך page.body.html.
# page.body.html הוא מקור האמת היחיד — אל תערכו את index.html ידנית.
set -euo pipefail
cd "$(dirname "$0")"

SRC=page.body.html
OUT=index.html
MARK='<div class="page" lang="he">'

split_line=$(grep -n -F "$MARK" "$SRC" | head -1 | cut -d: -f1)
head_part=$(head -n $((split_line - 1)) "$SRC")
body_part=$(tail -n +"$split_line" "$SRC")

cat > "$OUT" <<HEAD
<!doctype html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="פרגולות, דקים, מעקות עץ וגדרות בתכנון אישי — ייצור בנגרייה עצמית, מדידה בבית ללא עלות ואחריות 5 שנים על השלד.">
<meta name="theme-color" content="#7A4A21">
<link rel="canonical" href="https://pergula.online/">
<meta property="og:type" content="website">
<meta property="og:locale" content="he_IL">
<meta property="og:url" content="https://pergula.online/">
<meta property="og:title" content="עץ וצל — פרגולות, דקים, מעקות וגדרות">
<meta property="og:description" content="מתוכננים למידות המרפסת או החצר שלכם, מיוצרים בנגרייה שלנו ומורכבים בהתקנה אחת.">
<meta property="og:image" content="https://pergula.online/img/pergola-wave-railing.jpg">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 34 34'%3E%3Crect width='34' height='34' fill='%237A4A21'/%3E%3Cg fill='%23FAF4EC'%3E%3Crect x='4' y='9' width='26' height='2.6'/%3E%3Crect x='4' y='22.4' width='26' height='2.6'/%3E%3C/g%3E%3Cg fill='%23FAF4EC' opacity='.6'%3E%3Crect x='7' y='5' width='2.4' height='24'/%3E%3Crect x='14' y='5' width='2.4' height='24'/%3E%3Crect x='21' y='5' width='2.4' height='24'/%3E%3C/g%3E%3C/svg%3E">
$head_part
</head>
<body>
$body_part
</body>
</html>
HEAD

echo "נבנה $OUT ($(wc -c < "$OUT") בתים)"
