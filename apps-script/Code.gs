/**
 * מקבל פניות מדף הנחיתה וכותב אותן כשורה חדשה בגיליון הלידים.
 *
 * הגיליון: "לידים - פרגולות, דקים, מעקות וגדרות"
 * https://docs.google.com/spreadsheets/d/1X851yBAkmOK_9Ot2pQ87wOxbtfpTXI_LiTva4icnFJI/edit
 *
 * התקנה: ראו README.md בשורש הפרויקט.
 */

var SHEET_ID = '1X851yBAkmOK_9Ot2pQ87wOxbtfpTXI_LiTva4icnFJI';

var HEADERS = [
  'תאריך ושעה',
  'שם מלא',
  'טלפון',
  'יישוב / כתובת',
  'סוג הפרויקט',
  'הערות',
  'מקור'
];

function doPost(e) {
  // נעילה כדי ששתי פניות בו-זמנית לא ידרסו אותה שורה
  var lock = LockService.getScriptLock();
  lock.waitLock(20000);

  try {
    var data = JSON.parse(e.postData.contents);
    var sheet = SpreadsheetApp.openById(SHEET_ID).getSheets()[0];

    if (sheet.getLastRow() === 0) {
      sheet.appendRow(HEADERS);
    }

    sheet.appendRow([
      new Date(),
      data.name || '',
      // גרש מוביל שומר על ה-0 בתחילת מספר הטלפון
      "'" + (data.phone || ''),
      data.address || '',
      data.project || '',
      data.notes || '',
      data.source || ''
    ]);

    return json({ ok: true });
  } catch (err) {
    return json({ ok: false, error: String(err) });
  } finally {
    lock.releaseLock();
  }
}

// פתיחת הכתובת בדפדפן מאשרת שה-Web App חי
function doGet() {
  return json({ ok: true, service: 'pergula-leads' });
}

function json(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * הרצה חד-פעמית מתוך העורך כדי לוודא שהחיבור לגיליון עובד.
 * מוסיפה שורת בדיקה — מחקו אותה אחר כך מהגיליון.
 */
function testAppend() {
  doPost({ postData: { contents: JSON.stringify({
    name: 'בדיקה',
    phone: '0500000000',
    address: 'בדיקה',
    project: 'פרגולה',
    notes: 'שורת בדיקה — אפשר למחוק',
    source: 'apps-script-test'
  }) } });
}
