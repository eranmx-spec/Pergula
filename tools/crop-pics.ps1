# חותך את שלושת הקולאז'ים שב-pic/ לשתים-עשרה תמונות נפרדות ב-img/.
# כל קולאז' הוא 1408x768: רצועת כותרת בעברית למעלה, ומתחתיה סריג 2x2.
# הרצה חד-פעמית; התוצרים נכנסים ל-git ומוגשים על ידי Pages.

Add-Type -AssemblyName System.Drawing

$src = "C:\Users\user\Desktop\Claude\Projects\Pergula\pic"
$dst = "C:\Users\user\Desktop\Claude\Projects\Pergula\img"
New-Item -ItemType Directory -Force $dst | Out-Null

# גאומטריה של הסריג, בפיקסלים של המקור
$top = 58; $left = 12; $colW = 685; $rowH = 348
$col2 = 711; $row2 = 414

$quadrants = @(
  @{ q = 'tl'; x = $left; y = $top  },
  @{ q = 'tr'; x = $col2; y = $top  },
  @{ q = 'bl'; x = $left; y = $row2 },
  @{ q = 'br'; x = $col2; y = $row2 }
)

# שם קובץ לפי מה שרואים בתמונה, כדי שיהיה אפשר לבחור בלי לפתוח כל אחת
$names = @{
  '1789230432350_tl' = 'pergola-alum-white'
  '1789230432350_tr' = 'pergola-timber-wisteria'
  '1789230432350_bl' = 'pergola-dark-kitchen'
  '1789230432350_br' = 'pergola-curved-pool'
  '1789230498199_tl' = 'fence-slat-deck'
  '1789230498199_tr' = 'railing-white-timber'
  '1789230498199_bl' = 'deck-warm-bamboo'
  '1789230498199_br' = 'pergola-wave-railing'
  '1789234206508_tl' = 'deck-pool-white'
  '1789234206508_tr' = 'pergola-garden-pond'
  '1789234206508_bl' = 'deck-dark-kitchen'
  '1789234206508_br' = 'pergola-curved-palms'
}

$jpeg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
        Where-Object { $_.MimeType -eq 'image/jpeg' }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters 1
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
  [System.Drawing.Imaging.Encoder]::Quality, 82)

foreach ($file in Get-ChildItem "$src\*.png") {
  $img = [System.Drawing.Image]::FromFile($file.FullName)
  $stem = $file.BaseName
  foreach ($qd in $quadrants) {
    $key = "${stem}_$($qd.q)"
    $name = $names[$key]
    if (-not $name) { $name = $key }

    $rect = New-Object System.Drawing.Rectangle($qd.x, $qd.y, $colW, $rowH)
    $crop = New-Object System.Drawing.Bitmap($colW, $rowH)
    $g = [System.Drawing.Graphics]::FromImage($crop)
    $g.InterpolationMode = 'HighQualityBicubic'
    $g.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $colW, $rowH)),
                 $rect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()

    $out = Join-Path $dst "$name.jpg"
    $crop.Save($out, $jpeg, $encParams)
    $crop.Dispose()
    "{0,-26} {1} KB" -f "$name.jpg", [math]::Round((Get-Item $out).Length / 1KB)
  }
  $img.Dispose()
}
