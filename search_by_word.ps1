<#
.SYNOPSIS
Ieško nurodyto žodžio .txt faile ir skaičiuoja suradimų skaičių.

.DESCRIPTION
Ši funkcija skaito įvestą .txt failą ir skaičiuoja suradimų skaičių pagal įvestą žodį.
Pateikiami eilučių, kuriose yra ieškomas žodis, numeriai ir šio žodžio pasikartojimų skaičius tose eilutėse.
Pagal pageidavimą, paskaičiuojamas bendras pasikartojančio žodžio skaičius.
Taip pat ši funkcija iš pradžių gali patikrinti, ar tekstinis failas tuščias, ir nutraukti paiešką.

.PARAMETER path
Adresas pasirinkto .txt failo, kuriame yra ieškomas žodis.
Parametras yra būtinas. Galimas pagalbos (patikslinimo) pranešimas.
Parametras negali būti 'null' ar 'empty' ir turi būti .txt formato.

.PARAMETER word
Žodis, kuris yra ieškomas faile.
Parametras yra būtinas. Galimas pagalbos (patikslinimo) pranešimas.
Šis parametras gali paimti vieną ar kelias reikšmes iš konvejerio objekto.
Parametras negali būti 'null' ar 'empty' ( "" ).

.PARAMETER isFileEmpty
Switch parametras, kuris patikrina, ar failas yra tuščias ar ne, ir apie tai praneša.
Jei failas tuščias, nutraukia funkcijos darbą.

.INPUTS
System.String. Word-InAFile priima tik string tipo parametrus 'path' ir 'word'.

.OUTPUTS
Word-InAFile funkcija išveda string ir/arba int tipo rezultatus.

.EXAMPLE
C:\PS> Word-InAFile  -word "text" -path "C:\Users\Patricija\Desktop\pavyzdys.txt"
Pradedama nurodyto žodžio paieška .txt faile.
Faile 'C:\Users\Patricija\Desktop\pavyzdys.txt' ieškomas žodis 'text'
Eil.	Rasta
1:		1
2:		1
4:		1
9:		1
10:		3
12:		1
16:		1
Paieška baigta.

.EXAMPLE
C:\PS> Word-InAFile  -word "text" -path "C:\Users\Patricija\Desktop\pavyzdys.txt" -IncludeTotalCount
Pradedama nurodyto žodžio paieška .txt faile.
Faile 'C:\Users\Patricija\Desktop\pavyzdys.txt' ieškomas žodis 'text'
Eil.	Rasta
1:		1
2:		1
4:		1
9:		1
10:		3
12:		1
16:		1
-----------------
Total count: 9
Paieška baigta.

.EXAMPLE
C:\PS> Word-InAFile  -word "text" -path "C:\Users\Patricija\Desktop\pavyzdys.txt" -IncludeTotalCount -isFileEmpty
Pradedama nurodyto žodžio paieška .txt faile.
Faile 'C:\Users\Patricija\Desktop\pavyzdys.txt' ieškomas žodis 'text'
Tekstinis failas nėra tuščias.
Eil.	Rasta
1:		1
2:		1
4:		1
9:		1
10:		3
12:		1
16:		1
-----------------
Total count: 9
Paieška baigta.

.EXAMPLE
C:\PS> "text", "neratokiozodzio", "file" | Word-InAFile -path "C:\Users\Patricija\Desktop\pavyzdys.txt" -IncludeTotalCount -isFileEmpty
Pradedama nurodyto žodžio paieška .txt faile.
Faile 'C:\Users\Patricija\Desktop\pavyzdys.txt' ieškomas žodis 'text'
Tekstinis failas nėra tuščias.
Eil.	Rasta
1:		1
2:		1
4:		1
9:		1
10:		3
12:		1
16:		1
-----------------
Total count: 9
Faile 'C:\Users\Patricija\Desktop\pavyzdys.txt' ieškomas žodis 'neratokiozodzio'
Tekstinis failas nėra tuščias.
Eil.	Rasta
-----------------
Total count: 0
Faile 'C:\Users\Patricija\Desktop\pavyzdys.txt' ieškomas žodis 'file'
Tekstinis failas nėra tuščias.
Eil.	Rasta
1:		1
3:		2
5:		1
9:		1
11:		2
13:		2
-----------------
Total count: 9
Paieška baigta.

.EXAMPLE
C:\PS> "text", "neratokiozodzio", "file" | Word-InAFile -path "C:\Users\Patricija\Desktop\empty.txt" -IncludeTotalCount -isFileEmpty
Pradedama nurodyto žodžio paieška .txt faile.
Faile 'C:\Users\Patricija\Desktop\empty.txt' ieškomas žodis 'text'
Tekstinis failas tuščias.
Faile 'C:\Users\Patricija\Desktop\empty.txt' ieškomas žodis 'neratokiozodzio'
Tekstinis failas tuščias.
Faile 'C:\Users\Patricija\Desktop\empty.txt' ieškomas žodis 'file'
Tekstinis failas tuščias.
Paieška baigta.
#>
function Word-InAFile {
 [CmdletBinding(PositionalBinding = $False, SupportsPaging = $true)]
 Param
 (
 [Parameter(Mandatory = $True, HelpMessage = 'Nurodykite tekstinio failo adresą:')]
 [ValidateNotNullOrEmpty()]
 [ValidatePattern("\.txt$")]
 [string]
 $path,
 [Parameter(Mandatory = $True, HelpMessage = 'Nurodykite ieškomą žodį:', ValueFromPipeline = $True)]
 [ValidateNotNullOrEmpty()]
 [string]
 $word,
 [switch]
 $isFileEmpty
 )
 Begin{ Write-Host "Pradedama nurodyto žodžio paieška .txt faile." -ForegroundColor Cyan }
 Process{
 if (-not (Test-Path $path)){
    Write-Host "Nurodytas failas nerastas: $path" -ForegroundColor Red
    return
 }
 Write-Host "Faile '$path' ieškomas žodis '$word'" -ForegroundColor Yellow
 $lines = Get-Content $path
 if ($isFileEmpty){
    if ($lines.Count -eq 0){
    Write-Host "Tekstinis failas tuščias." -ForegroundColor DarkRed
    return }
    else { Write-Host "Tekstinis failas nėra tuščias." -ForegroundColor DarkGreen }
 }
 $wordCount = 0
 Write-Host "Eil.`tRasta" -ForegroundColor Green
 for ($i = 0; $i -lt $lines.Length; $i++){ 
    $matches = [regex]::Matches($lines[$i], "(?i)$word")
    $countInLine = $matches.Count

    if ($lines[$i] -like "*$word*"){
        Write-Host "$($i + 1):`t`t$countInLine"
        $wordCount += $countInLine
    }
 }
 if ($PSCmdlet.PagingParameters.IncludeTotalCount){
    Write-Host "-----------------"
    [double]$Accuracy = 1.0
    $PSCmdlet.PagingParameters.NewTotalCount($wordCount, $Accuracy)
 }
 
 }
 End{ Write-Host "Paieška baigta." -ForegroundColor Magenta }
} 
Word-InAFile  -word "text" -path "C:\Users\Patricija\Desktop\search_by_word\pavyzdys.txt"
Word-InAFile  -word "text" -path "C:\Users\Patricija\Desktop\search_by_word\pavyzdys.txt" -IncludeTotalCount
Word-InAFile  -word "text" -path "C:\Users\Patricija\Desktop\search_by_word\pavyzdys.txt" -IncludeTotalCount -isFileEmpty
Word-InAFile -IncludeTotalCount -word "text" -path "C:\Users\Patricija\Desktop\search_by_word\pavyzdys.txt"
"text", "neratokiozodzio", "file" | Word-InAFile -path "C:\Users\Patricija\Desktop\search_by_word\pavyzdys.txt" -IncludeTotalCount -isFileEmpty
"text", "neratokiozodzio", "file" | Word-InAFile -path "C:\Users\Patricija\Desktop\search_by_word\empty.txt" -IncludeTotalCount -isFileEmpty
Word-InAFile

Get-Help Word-InAFile -Full
Get-Help Word-InAFile -ShowWindow

#cd C:\Users\Patricija\Desktop\search_by_word