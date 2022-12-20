#Requires -RunAsAdministrator
Set-ExecutionPolicy Unrestricted -Confirm:$false

try{

set-location (Split-Path -Path $psISE.CurrentFile.FullPath)

}

catch{

Set-Location $PSScriptRoot

}

function Randomize-List
{
   Param(
     [array]$InputList
   )

   return $InputList | Get-Random -Count $InputList.Count;
}


cls
write-host ""
write-host ----------- BONUSHUNT -----------
write-host ""
write-host ""

$filename = ".\BonusHunt_Sorsolas.csv"

$data = Import-Csv .\data.csv -Delimiter ";" -Encoding Default
$playerlist = Import-Csv .\playerlist.csv -Delimiter ";" -Encoding Default

Write-Host "Add meg a kezdőösszeget: " -ForegroundColor Yellow -NoNewline
$kezdoosszeg = Read-Host
cls

#write-host A kezdőösszeg $kezdoosszeg Ft
$playerlista = Randomize-List $playerlist.Név

$data = Randomize-List $data


For ($i=0; $i -lt ($data.Count - ($data.Count % $playerlist.Count)); $i++) 

{

$data[$i].Player = $playerlista[$i % $playerlista.Count]
}

$data = $data

$data | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | % {$_.Replace('"','')} | Out-File $filename

##########################
#kezdődik a játék

<#
write-host "Játékosok: "  $playerlist.Név
write-host "Bónuszok: " $data.Játék
#>


foreach ($player in $playerlist)
{

$player.Pont = 0

}

$össznyeremény = 0
$összretrigger = 0

foreach ($game in $data)

{
    #cls
    if ($game.Player.Length -gt 0)
    {
        [console]::ResetColor()
        write-host ""
        write-host ----------- BONUSHUNT -----------
        write-host ""
        $playerlist | select Név, pont| Sort-Object -Property Pont -Descending | ft
        write-host ---------------------------------
        write-host ""
        write-host "A következő játék: " -nonewline
        write-host $($game.Játék) -ForegroundColor Yellow
        write-host "Vendor: " -nonewline
        write-host $($game.Vendor) -f Yellow
        write-host "Alaptét: "-NoNewline
        write-host $($game.alaptét) Ft -f Yellow
        write-host "Játékos: "-NoNewline
        write-host $($game.Player) -f Yellow
        write-host ""


        #Null Variables
        $nyeremény = $null
        $retrigger = $null


        while ($nyeremény.Length -eq 0)
        {
        Write-Host "Mennyi lett a nyeremény? (Ft) " -ForegroundColor Yellow -NoNewline
        $nyeremény = Read-Host
        }
        write-host ""

        while ($retrigger.Length -eq 0)
        {
        Write-Host "Mennyi retrigger volt? " -ForegroundColor Yellow -NoNewline
        $retrigger = Read-Host 
        }
        write-host ""

        if ($retrigger -ne 0) {$összretrigger = $összretrigger + $retrigger}
        
        $game.Nyeremény = $nyeremény
        $össznyeremény = $össznyeremény + $nyeremény
        $game.Szorzo = $nyeremény/$game.Alaptét

        if ($game.Szorzo -eq 0) {$game.Pont = -4}
        elseif ($game.Szorzo -lt 5) {$game.Pont = -3}
        elseif ($game.Szorzo -lt 10) {$game.Pont = -2}
        elseif ($game.Szorzo -lt 20) {$game.Pont = -1}
        elseif ($game.Szorzo -lt 30) {$game.Pont = 0}
        elseif ($game.Szorzo -lt 60) {$game.Pont = 1}
        elseif ($game.Szorzo -lt 100) {$game.Pont = 2}
        elseif ($game.Szorzo -lt 200) {$game.Pont = 3}
        elseif ($game.Szorzo -lt 300) {$game.Pont = 4}
        elseif ($game.Szorzo -lt 500) {$game.Pont = 5}
        elseif ($game.Szorzo -lt 1000) {$game.Pont = 7}
        elseif ($game.Szorzo -gt 1000) {$game.Pont = 10}

        $game.Szorzo = [math]::Round($game.Szorzo,2)

        #if ((!($playerlist | where {$_.Név -eq $player}).Pont)){$game.Pont = 0}
        [int]($playerlist | where {$_.Név -eq $game.player}).Pont = [int]($playerlist | where {$_.Név -eq $game.player}).Pont + [int]$game.Pont


        write-host "Szorzó: " $game.Szorzo "x"
        write-host "Pont: " $game.Pont
        write-host $game.Player "összpontszáma: " (($playerlist | where {$_.Név -eq $game.player}).Pont)
        write-host ""
        write-host "--------------------------------"
        write-host ""
        write-host ""
        write-host "Nyomj egy entert a következő játékhoz!" -f Yellow
        read-host
        cls
    }

    else

    {

        $game.Player = "Földi"

    }

    $filename = ".\Eredmeny.csv"
    $data | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | % {$_.Replace('"','')} | Out-File $filename -Force
    $playerlist | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | % {$_.Replace('"','')} | Out-File ".\PlayerEredmeny.csv" -Force

}

foreach ($player in $playerlist)

{

$player.'Nyeremény átlag' = [Math]::Round((($data | Where-Object {$_.Player -like $player.Név}).Nyeremény | Measure-Object -Average).Average,2)
$player.'Szorzó átlag' = [Math]::Round((($data | Where-Object {$_.Player -like $player.Név}).Szorzo | Measure-Object -Average).Average,2)

}

foreach ($leftGame in $data | where {$_.Player -eq "Földi"})

{

        write-host ""
        write-host ----------- BONUSHUNT -----------
        write-host ""
        $playerlist | select Név, pont| Sort-Object -Property Pont -Descending | ft
        write-host ---------------------------------
        write-host ""
        write-host "A következő játék: " -nonewline
        write-host $($game.Játék) -ForegroundColor Yellow
        write-host "Vendor: " -nonewline
        write-host $($game.Vendor) -f Yellow
        write-host "Alaptét: "-NoNewline
        write-host $($game.alaptét) Ft -f Yellow
        write-host "Játékos: "-NoNewline
        write-host $($game.Player) -f Yellow
        write-host ""


        #Null Variables
        $nyeremény = $null
        $retrigger = $null


        while ($nyeremény.Length -eq 0)
        {
        Write-Host "Mennyi lett a nyeremény? (Ft) " -ForegroundColor Yellow -NoNewline
        $nyeremény = Read-Host
        }
        write-host ""

        while ($retrigger.Length -eq 0)
        {
        Write-Host "Mennyi retrigger volt? " -ForegroundColor Yellow -NoNewline
        $retrigger = Read-Host 
        }
        write-host ""

        if ($retrigger -ne 0) {$összretrigger = $összretrigger + $retrigger}
        
        $game.Nyeremény = $nyeremény
        $össznyeremény = $össznyeremény + $nyeremény
        $game.Szorzo = $nyeremény/$game.Alaptét

        $game.Szorzo = [math]::Round($game.Szorzo,2)

        #if ((!($playerlist | where {$_.Név -eq $player}).Pont)){$game.Pont = 0}

        
        write-host "Szorzó: " $game.Szorzo "x"
        write-host ""
        write-host "--------------------------------"
        write-host ""
        write-host ""
        write-host "Nyomj egy entert a következő játékhoz!" -f Yellow
        read-host
        cls

}



$playerlist | Sort-Object -Property 'Pont' -Descending
write-host ----------- BONUSHUNT EREDMÉNY -----------
write-host
write-host Retriggerek száma: $összretrigger
write-host Kezdőösszeg: $kezdoosszeg Ft
write-host Nyeremény: $össznyeremény Ft

$profit = $össznyeremény - $kezdoosszeg 

if ($profit -gt 0)

{
write-host Profit: $profit Ft -f Green
}

else

{

write-host Profit: $profit Ft -ForegroundColor Red

}

write-host ""

$max = $data | Sort-Object -Property Szorzo -Descending | select -First 1 | select Játék, Szorzo, Player
write-host Legnagyobb szorzó:
write-host Játék: $max.Játék
write-host Szorzó: $max.Szorzo x
write-host Player: $max.Player
write-host 
$min = $data | Sort-Object -Property Szorzo | select -First 1 | select Játék, Szorzo, Player
write-host Legkisebb szorzó
write-host Játék: $min.Játék
write-host Szorzó: $min.Szorzo x
write-host Player: $min.Player
write-host 

$100xfolott = ($data | where {$_.Szorzo -gt 100}).Length
$5xalatt = ($data | where {$_.Szorzo -lt 5}).Length
write-host 100x fölöttiek száma: $100xfolott
write-host 5x alattiak száma: $5xalatt
write-host 
