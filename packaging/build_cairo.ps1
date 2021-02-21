param($CAIRO_VERSION, $PREFIX, $ARCH)

$prev_PATH = $env:PATH
Write-Output "Setting enviroment variable using vswhere"
if ($arch -eq 32) {
    Write-Output "Builing 32 bit-binaries"
    $host_arch = "x86"
    $arch = "x86"
}
else {
    Write-Output "Builing 64 bit-binaries"
    $host_arch = "amd64"
    $arch = "amd64"
}
# from https://github.com/microsoft/vswhere/wiki/Start-Developer-Command-Prompt#using-powershell
$installationPath = vswhere.exe -prerelease -latest -property installationPath
if ($installationPath -and (test-path "$installationPath\Common7\Tools\vsdevcmd.bat")) {
    & "${env:COMSPEC}" /s /c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" -no_logo -host_arch=$host_arch -arch=$arch && set" | foreach-object {
        $name, $value = $_ -split '=', 2
        set-content env:\"$name" $value
    }
}
Set-Location "$TEMP"

curl -L https://gitlab.freedesktop.org/cairo/cairo/-/archive/$CAIRO_VERSION/cairo-$($CAIRO_VERSION).tar.gz -o cairo-$($CAIRO_VERSION).tar.gz
tar -xf cairo-$($CAIRO_VERSION).tar.gz
Move-Item cairo-$($CAIRO_VERSION) cairo -Force

pip install meson==0.57.1 ninja==1.10.0.post2

meson setup `
    --default-library=static `
    --buildtype=release `
    -Dtee=enabled `
    -Dtests=disabled `
    cairobuild_dir

meson compile -C cairo_builddir
meson install --no-rebuild -C cairo_builddir

$env:PATH = $prev_PATH
