$mode = 1

# 1: yesterday folder
# 2: date range folders
# 3: specific date

# mode 1: yesterday ----------------------------
$x = (Get-Date).AddDays(-1)

# mode 2: work days range-----------------------
$stDate = [DateTime] "2025-12-01"
$enDate = [DateTime] "2025-12-13"

# mode 3: specific date ------------------------
$sd = Get-Date("2024-11-20")

if ($mode -eq 3) 
    {
        $x = $sd 
    }

#--- main servers -----------------------------

$source_srv = "\\10.1.1.1\source"
$target_srv = "\\10.1.1.10\target"

$lf = "C:\windows\temp\sync-log.txt"


function Copy-Day([string]$p) 
{
    $t1 = Get-Date

    # Clear-Host

    $sf = $source_srv + $p 
    $tf = $target_srv + $p

    Write-Host "Folder : $sf"
    Write-Host "Hedef  : $tf"
    
    $ff = Get-ChildItem -Path $sf -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
    $total = (Get-ChildItem -Path $sf -Recurse -File -Force -ErrorAction SilentlyContinue).Count
    $copied = 1

    $proc = "Date : $p    |  Total Files: $total"

    Write-Progress -Activity $proc

    foreach ($f in $ff) 
        {
            $fc = (Get-ChildItem -Path $f.FullName -File | Measure-Object).Count
            $source = $f.FullName
            $target = ($f.FullName -replace [regex]::Escape($source_srv), $target_srv )
            Write-Host "source:   $source "
            Write-Host "TARGET:   $target "
            Write-Host "Files :   $fc"
            Write-Host "--------------------------------------------------------------------"

            $percent =  ($copied/$total) * 100
            $percentStr = "% " + $percent.ToString("00.00")

            Write-Progress -Activity $proc -Status "Folder : $fc - $source" -CurrentOperation $percentStr -PercentComplete $percent
            robocopy $source $target /v /r:3 /w:3 /MT:16 /njh /ndl /nfl /njs /np > null
            $copied += $fc 
        }


    $t2 = Get-Date
    $sure = $t2 - $t1
    
    $lm = $t1.ToString() + " | " + " Time : " + [math]::Round($sure.TotalSeconds, 2) + " sec | folder: " + $p
    $lm | Add-Content -Path $lf
    
}


function Day-Folder([DateTime]$dy)
{
    
    $tmp = "\" + $dy.Year.ToString() + "\" + $dy.Month.ToString('00') + "\" + $dy.Day.ToString('00')
    return $tmp 
}

# Clear-Host 


# ---- yesterday --------------------------
switch ( $mode )
{
    {($_ -eq 1) -or ($_ -eq 3)}  # yesterday or specific date
    {
        Copy-Day -p (Day-Folder -dy $x)
        
     }
    2 # range
    {
        $days = @()

        $dd = [DateTime] $stDate
        while ($dd -le $enDate)
            { 
                $days += $dd
                $dd = $dd.AddDays(1)
             }                
     
        foreach ($d in $days)
            {
                Copy-Day -p (Day-Folder -dy $d)
             }
     }
}


