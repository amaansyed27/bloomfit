
Add-Type -AssemblyName System.Drawing

$sourcePath = "assets\logo\logo_transparent.png"
$destPath = "assets\logo\logo_padded.png"
$paddingFactor = 1.6 # Increase canvas size by 60%

# proper absolute paths
$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Get-Location }
$fullSource = Join-Path $scriptPath $sourcePath
$fullDest = Join-Path $scriptPath $destPath

Write-Host "Reading from: $fullSource"
if (-not (Test-Path $fullSource)) {
    Write-Error "Source file not found!"
    exit 1
}

$img = [System.Drawing.Image]::FromFile($fullSource)
$width = $img.Width
$height = $img.Height

$maxDimension = ($width, $height | Measure-Object -Maximum).Maximum
$newSide = [int]($maxDimension * $paddingFactor)

$bmp = New-Object System.Drawing.Bitmap($newSide, $newSide)
$graph = [System.Drawing.Graphics]::FromImage($bmp)
$graph.Clear([System.Drawing.Color]::Transparent)

# Calculate center position
$x = [int](($newSide - $width) / 2)
$y = [int](($newSide - $height) / 2)

$graph.DrawImage($img, $x, $y, $width, $height)

$bmp.Save($fullDest, [System.Drawing.Imaging.ImageFormat]::Png)

$img.Dispose()
$graph.Dispose()
$bmp.Dispose()

Write-Host "Created padded image at: $fullDest"
