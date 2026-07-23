# Initialisation.
New-Variable -Name failure -Value 1 -Option Constant
New-Variable -Name success -Value 0 -Option Constant

# Compile LaTeX files with LuaLaTeX.

# Get a handle on the directory holding the LaTeX files.
$dirLatex = Join-Path -Path $PSScriptRoot -ChildPath "latex"
if (-not (Test-Path -Path $dirLatex -PathType Container)) {
    Write-Output "Directory $dirLatex doesn't exist, exiting."
    exit $failure
}

# Get a handle on the directory holding the image assets.
$dirAssets = Split-Path -Parent $PSScriptRoot
$dirAssets = Join-Path -Path $dirAssets -ChildPath "assets"
if (-not (Test-Path -Path $dirAssets -PathType Container)) {
    Write-Output "Directory $dirAssets doesn't exist, exiting."
    exit $failure
}

# Process the LaTeX-defined equations in the directory.
$files = Get-ChildItem -Path $dirLatex -File -Filter "*.tex"
foreach ($file in $files) {

    # Compile each LaTeX file in the directory with LuaLaTeX.
    # The LaTeX files don't use a Table of Contents, cross-references, page numbers, etc.
    # Therefore, execute a single compilation pass.
    lualatex -interaction=nonstopmode --output-directory=$dirLatex $file.FullName

    # Convert PDF files to SVG files with pdftocairo.
    $prefixLocal = Join-Path -Path $dirLatex -ChildPath "$($file.BaseName)"
    $pathSVG = Join-Path -Path $dirAssets -ChildPath "$($file.BaseName).svg"
    pdftocairo -svg "$prefixLocal.pdf" $pathSVG

    # Clean up unneeded conversion by-products.
    Remove-Item -Path "$prefixLocal.aux", "$prefixLocal.log", "$prefixLocal.pdf" -ErrorAction SilentlyContinue

    # Insert ARIA roles, with MathSpeak labels, into the SVG files.
    # Assumes presence of files "equation01.svg" to "equation10.svg".
    [xml]$svg = Get-Content $pathSVG
    $svg.svg.SetAttribute("role", "math")
    switch ($($file.BaseName)) {
        "equation01" {
            $svg.svg.SetAttribute("aria-label", "normal upper Delta x equals x Sub f Base minus x Sub i")
            break
        }
        "equation02" {
            $svg.svg.SetAttribute("aria-label", "v squared equals l g tangent theta sine theta")
            break
        }
        "equation03" {
            $svg.svg.SetAttribute("aria-label", "a equals StartFrac v Sub f Base minus v Sub i Base Over t EndFrac")
            break
        }
        "equation04" {
            $svg.svg.SetAttribute("aria-label", "x equals u t plus one half a t squared")
            break
        }
        "equation05" {
            $svg.svg.SetAttribute("aria-label", "v Sub x Base overbar equals StartFrac normal upper Delta x Over normal upper Delta t EndFrac equals StartFrac x Sub f Base minus x Sub i Base #Over normal upper Delta t EndFrac")
            break
        }
        "equation06" {
            $svg.svg.SetAttribute("aria-label", "upper W equals one half k x squared")
            break
        }
        "equation07" {
            $svg.svg.SetAttribute("aria-label", "upper F equals m a")
            break
        }
        "equation08" {
            $svg.svg.SetAttribute("aria-label", "upper F Sub c Base equals StartFrac m v squared Over r EndFrac")
            break
        }
        "equation09" {
            $svg.svg.SetAttribute("aria-label", "a Sub c Base equals StartFrac v squared Over r EndFrac")
            break
        }
        "equation10" {
            $svg.svg.SetAttribute("aria-label", "upper E Sub k Base equals one half m v squared")
            break
        }
    }
    $svg.Save($pathSVG)
}
