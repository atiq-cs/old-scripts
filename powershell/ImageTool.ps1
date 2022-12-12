<#
.SYNOPSIS
  Convert images to bmp format
.DESCRIPTION
  Date: 10/20/2013
  Utilize ImageMagic Binary to convert images (png to bmp output only for now) as a
  helper for Emot Icon generation

.EXAMPLE
  ImageTool

.NOTES
  TODO: to test the new magic binary that replaces convert.exe
  Few notes after trying the binary with few arguments,

  1. Does not work
  - argument '-flatten'

  2. found in commented code segment, at the bottom,
  - example: `-colors 16777216`

  3. to get 24x24 -resize 24x not working, tried on png input images,
     `-resize 24x24`
  tried for input,

    $SourceDir="F:\Windows Project\IM Clients\TestEmoCustomControl\res\emo\toresize"

  output,

    $DestDir="F:\Windows Project\IM Clients\TestEmoCustomControl\res\emo\"

  hence for now, just using `-resize 15x`

  4. For white background, utilize `-background white`
  5. Utilize `-type TrueColorMatte` to force the encoder to write an alpha channel even though the
  image is opaque, if the output format supports transparency.
  ref, http://www.imagemagick.org/script/command-line-options.php#type
#>


# $SourceDir="F:\Windows Project\IM Clients\TestEmoCustomControl\res\emo"
# $DestDir="F:\Windows Project\IM Clients\TestEmoCustomControl\res\bmps\"
$SourceDir="F:\Windows Project\IM Clients\Emoticon Images\Delivery Status"
$DestDir="F:\Windows Project\IM Clients\TestEmoCustomControl\res\deliv\"
$ImageConvertBinary="C:\CPFiles_x64\ImageMagick-7.0.3-Q16\magick.exe"

$InputExt = ".png"

foreach ($item in Get-ChildItem "$SourceDir\*$InputExt")
{
    $fName = $item.Name
    $InputFileBaseName = $fName.Substring(0, $fName.Length - $InputExt.Length)
	$destName = $DestDir + $InputFileBaseName + ".bmp"
    $destName

    # problem with bmp
    # http://www.imagemagick.org/Usage/formats/#bmp
	#& $ImageConvertBinary $item.FullName -type TrueColorMatte BMP3:$destName
    & $ImageConvertBinary -resize 15x $item.FullName -flatten BMP3:$destName
}
