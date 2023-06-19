# Date: 10/22/2013 15:46:38
# Author: Atiq

# resource definition declarations statements for button bmp IDs generated
$resValue=1347
for ($i=1; $i -le 47; $i++, $resValue++) {
    if ($i -lt 10) {
        Write-Host "#define IDB_BMP_EMOTICON_0${i}                $resValue"
    }
    else {
        Write-Host "#define IDB_BMP_EMOTICON_${i}                $resValue"
    }
}
#>

<# resource definition declarations statements for button IDs generated
$resValue=1300
for ($i=1; $i -le 47; $i++, $resValue++) {
    if ($i -lt 10) {
        Write-Host "#define IDC_BUTTON_EMO0${i}                $resValue"
    }
    else {
        Write-Host "#define IDC_BUTTON_EMO${i}                $resValue"
    }
}
#>

<# For use with CBitmapButton
# dimension 16, 14 found by trial and error
$width = 16
$height = 14

$horiz_space = 4
$vert_space = 4

$initX = 4
$initY = 4

$x1=$initX
$y1=$initY

# iterate for currently available 47 emot icons
for ($i=1; $i -le 47; $i++) {
    $x2 = $x1+$width
    $y2 = $y1+$height
    # CONTROL         "",IDC_BUTTON_EMO01,"Button",BS_OWNERDRAW | WS_TABSTOP,5,5,20,20
    if ($i -lt 10) {
        Write-Host "`tCONTROL      `"`",IDC_BUTTON_EMO0$i,`"Button`",BS_OWNERDRAW | WS_TABSTOP,$x1,$y1,$width,$height"
    }
    else {
        Write-Host "`tCONTROL      `"`",IDC_BUTTON_EMO$i,`"Button`",BS_OWNERDRAW | WS_TABSTOP,$x1,$y1,$width,$height"
    }
    $x1 += $width + $horiz_space
    if ($i % 8 -eq 0) {
        $y1 += $height + $vert_space
        $x1 = $initX
    }
}

<# For use with CxSkinButton
# from 1 to 48

$width = 20
$height = 20

$horiz_space = 0
$vert_space = 0

$x1=5
$y1=5

for ($i=1; $i -le 47; $i++) {
    $x2 = $x1+$width
    $y2 = $y1+$height
    if ($i -lt 10) {
        Write-Host "`tPUSHBUTTON      `"`",IDC_BUTTON_EMO0$i,$x1,$y1,$width,$height"
    }
    else {
        Write-Host "`tPUSHBUTTON      `"`",IDC_BUTTON_EMO$i,$x1,$y1,$width,$height"
    }
    $x1 += $width + $horiz_space
    if ($i % 8 -eq 0) {
        $y1 += $height + $vert_space
        $x1 = 5
    }
}

<#
bitmpat statements generated

$bmpDir = "F:\Windows Project\IM Clients\TestEmoCustomControl\res\bmps"
$i=1

foreach ($item in Get-ChildItem $bmpDir)
{
    if (! $item.PSIsContainer) {
    $fName = $item.Name
    if ($i -lt 10) {
        Write-Host "IDB_BMP_EMOTICON_0${i}     BITMAP                  `"res\\bmps\\$fName`""
    }
    else {
        Write-Host "IDB_BMP_EMOTICON_${i}     BITMAP                  `"res\\bmps\\$fName`""
    }
    $i++
    }
}#>


