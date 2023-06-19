# Date: 04/13/2012 03:16:20
# Author: Atiq

Write-Host "Using COM to access office document`n--------------------------------------"

$FilePath=$env:scriptdir+"\..\WordList\Base Wordlist.docx"
$objWord = New-Object -Com Word.Application
# [ref]$SaveFormat = "microsoft.office.interop.word.WdSaveFormat" -as [type]

$objWord.Visible = $false #set this to true for debugging
# In visible mode
#$objWord.Visible = $true

$missing = [System.Reflection.Missing]::Value

# Open Document in Read Only Mode
Write-Host "Opening document $FilePath in read only mode"
$objDoc = $objWord.Documents.Open($FilePath, $missing, $true)

# workaround for the error...
$wdPrintView=3
#$objDoc.ActiveWindow.View = $wdPrintView
$objView = $objDoc.ActiveWindow.View 
$objView.Type = $wdPrintView
#$Doc = $Word.Documents["Test-Doc.docx"]

# Search for text
$objSelection = $objWord.selection
#$objSelection.Find.ClearFormatting()

# If we only need bold styled words
#$Selection.Find.Font.Bold = $true

$FindText = $args[0]
$MatchCase = $False 
$MatchWholeWord = $False 
$MatchWildcards = $False 
$MatchSoundsLike = $False 
$MatchAllWordForms = $False 
$Forward = $True 
$Wrap = $wdFindContinue
$Format = $False 
$wdReplaceNone = 0 
$ReplaceWith = ""
$wdFindContinue = 1

$i = 1
$j = 1
 
while($objSelection.Find.Execute($FindText,$MatchCase,$MatchWholeWord, `
    $MatchWildcards,$MatchSoundsLike,$MatchAllWordForms,$Forward, `
    $Wrap,$Format,$ReplaceWith,$wdReplaceNone, $missing, $missing, $missing)) {
    
    $bld = $objSelection.Font.Bold
    <#if ($objSelection.Font.Bold) {
        Write-Host "`nWord $findText found in title $i."
        $i = $i + 1
    }
    else {#>
        $str = $objSelection.Start
        $en = $objSelection.End
    
        $objSelection.Start = $str - 1
        $objSelection.End = $str
        $txt = $objSelection.Text
        #Write-Host "pre`: `"$txt`""
        
        if ($txt.Equals("`r") -and $bld) {
            Write-Host "`nWord $findText found in title $i."
            $i = $i + 1
        }
        elseif ($txt.Equals(" ")) {
            Write-Host "`nWord $findText found inside sentence $j."
            $j = $j+1
        }
        else {
            $objSelection.Start = $en
            $objSelection.End = $en + 1
            $txt = $objSelection.Text
            #Write-Host "next char`: `"$txt`""
            
            $ch = $txt[0]
            if ($txt.Equals(".") -or $txt.Equals(" ") -or $txt.Equals(",") -or $txt.Equals(";") -or $txt.Equals(" ") -or [char]::isletter($ch)) {
                Write-Host "`nWord $findText found inside sentence $j."
                $j = $j+1
                
            }
            else {
                Write-Host "`nWord $findText found in an odd place, next char: $txt"
                $j = $j+1
            }
        }
        $objSelection.Start = $str
        $objSelection.End = $en

    #}
}

if ($i -eq 1 -and $j -eq 1) {
    Write-Host "`nWord $findText not found in document."
}
    
<#if ($Selection.Find.Execute($findText)) {
    #$Selection.Start = $Selection.Start - 4
    #$Selection.End = $Selection.End + 40
    #$text = $Selection.Text
    $snt = $Selection.Sentences.Count
    Write-Host "count $snt"
    
    if ($Selection.Font.Bold) {
        Write-Host "`nWord $findText found in title.`n"
    }
    else {
        Write-Host "`nWord $findText found inside sentence.`n"
    }
    
    #$cn = $Selection.Parent.TextPosition
    
    <#$ri = $pfmt.RightIndent
    Write-Host "Right indent $ri"
    $pfmt = $Selection.Find.ParagraphFormat 
    $li = $pfmt.SpaceBefore
    Write-Host "space before $li"
    <#if ($Selection.Format) {
        Write-Host "Format included"
    }
    else {
        Write-Host "Not included"
    }

    #$ft = $font.NameOther
    #Write-Host "`"$ft`""
    
    #$selection.typeText("test..")
}
else {
    Write-Host "`nWord $findText not found in document!`n"
}#>

# Closing time
#$Doc.SaveAs([ref]$FilePath, [ref]$saveFormat::wdFormatDocument)
$objDoc.Close() #close the document
$objWord.Quit() #and the instance of Word

Write-Host "`nDocument closed, word instance quitted."
