Add-Type -AssemblyName System.Drawing

$root = "C:\Users\Eddy\Documents\Flutter Applications\mihlgso_mobile"
$logoPath = "$root\assets\images\logo.jpeg"
$outDir = "$root\docs\store"

$blue = [System.Drawing.Color]::FromArgb(255, 0x10, 0x7B, 0xD9)
$green = [System.Drawing.Color]::FromArgb(255, 0x69, 0xB2, 0x49)

function New-GradientBitmap([int]$w, [int]$h) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $blue, $green, 45)
    $g.FillRectangle($brush, $rect)
    return @{ Bitmap = $bmp; Graphics = $g }
}

function Draw-Logo($g, [int]$cx, [int]$cy, [int]$size) {
    $logo = [System.Drawing.Image]::FromFile($logoPath)
    # Circular white backing plate behind the logo so it reads cleanly on the gradient.
    $pad = [int]($size * 0.12)
    $plateRect = New-Object System.Drawing.Rectangle(($cx - $size/2 - $pad), ($cy - $size/2 - $pad), ($size + $pad*2), ($size + $pad*2))
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillEllipse($whiteBrush, $plateRect)
    $destRect = New-Object System.Drawing.Rectangle(($cx - $size/2), ($cy - $size/2), $size, $size)
    $g.DrawImage($logo, $destRect)
    $logo.Dispose()
}

# --- Play Store icon: 512x512, no transparency ---
$iconSize = 512
$h = New-GradientBitmap $iconSize $iconSize
Draw-Logo $h.Graphics ($iconSize/2) ($iconSize/2) 300
$h.Graphics.Dispose()
$h.Bitmap.Save("$outDir\icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)
$h.Bitmap.Dispose()
Write-Output "Wrote icon-512.png"

# --- Feature graphic: 1024x500 ---
$fw = 1024; $fh = 500
$f = New-GradientBitmap $fw $fh
Draw-Logo $f.Graphics 210 250 220
$titleFont = New-Object System.Drawing.Font("Arial", 64, [System.Drawing.FontStyle]::Bold)
$subFont = New-Object System.Drawing.Font("Arial", 20, [System.Drawing.FontStyle]::Regular)
$whiteBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$f.Graphics.DrawString("MIHLGSO", $titleFont, $whiteBrush2, 400, 165)
$f.Graphics.DrawString("Mafia Island Higher Learning Graduates", $subFont, $whiteBrush2, 400, 265)
$f.Graphics.DrawString("and Students Organization", $subFont, $whiteBrush2, 400, 300)
$f.Graphics.Dispose()
$f.Bitmap.Save("$outDir\feature-graphic-1024x500.png", [System.Drawing.Imaging.ImageFormat]::Png)
$f.Bitmap.Dispose()
Write-Output "Wrote feature-graphic-1024x500.png"
