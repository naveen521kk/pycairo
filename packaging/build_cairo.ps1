param($CAIRO_VERSION, $PREFIX, $arch)

$prev_PATH = $env:PATH
Write-Output "Setting enviroment variable using vswhere"
if ($arch -eq 32) {
    Write-Output "Builing 32 bit-binaries"
    $host_arch = "x86"
    $arch = "x86"
    $env:PLATFORM="x86"
}
else {
    Write-Output "Builing 64 bit-binaries"
    $host_arch = "amd64"
    $arch = "amd64"
    $env:PLATFORM="x64"
}
# from https://github.com/microsoft/vswhere/wiki/Start-Developer-Command-Prompt#using-powershell
$installationPath = vswhere.exe -prerelease -latest -property installationPath
if ($installationPath -and (test-path "$installationPath\Common7\Tools\vsdevcmd.bat")) {
    & "${env:COMSPEC}" /s /c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" -no_logo -host_arch=$host_arch -arch=$arch && set" | foreach-object {
        $name, $value = $_ -split '=', 2
        set-content env:\"$name" $value
    }
}
pip install meson==0.56.* ninja
if ($arch -eq "x86"){
    Write-Output "Getting pkg-config"
    curl -L https://github.com/pkgconf/pkgconf/archive/pkgconf-1.7.0.zip -o pkgconf.zip
    7z x pkgconf.zip
    Move-Item -Path pkgconf-* -Destination pkgconf -Force
    $env:PKG_CONFIG_PATH=""
    meson setup --prefix=C:\build\pkg-config --buildtype=release -Dtests=false pkg_conf_build pkgconf
    meson compile -C pkg_conf_build
    meson install --no-rebuild -C pkg_conf_build
    ln -sf C:\build\pkg-config\bin\pkgconf.exe C:\build\pkg-config\pkg-config
    Rename-Item C:\build\pkg-config\bin\pkgconf.exe pkg-config.exe -Force
}
$env:PATH="C:\build\pkg-config\bin;$env:PATH"

Set-Location "$TEMP"

curl -L https://gitlab.freedesktop.org/cairo/cairo/-/archive/$CAIRO_VERSION/cairo-$($CAIRO_VERSION).tar.gz -o cairo-$($CAIRO_VERSION).tar.gz
tar -xf cairo-$($CAIRO_VERSION).tar.gz
Move-Item cairo-$($CAIRO_VERSION) cairo -Force

$env:PKG_CONFIG_PATH="$PREFIX\$arch\lib\pkgconfig"

Set-Location cairo

meson subprojects download zlib
Set-Location subprojects/zlib-*
meson setup --prefix="$PREFIX\$arch" `
    --default-library=static `
    --buildtype=release `
    --wrap-mode=nofallback `
    _build
meson install -C="_build"
Set-Location ../../

meson subprojects download libpng
Set-Location subprojects/libpng-*
meson setup --prefix="$PREFIX\$arch" `
    --default-library=static `
    --buildtype=release `
    --wrap-mode=nofallback `
    _build
meson install -C="_build"
$fp="$PREFIX\$arch\lib\pkgconfig\libpng.pc"
(Get-Content -Path $fp) -replace '\\','/' | Set-Content -Path $fp
Set-Location ../../

meson subprojects download pixman
Set-Location subprojects/pixman
meson setup --prefix="$PREFIX\$arch" `
    --default-library=static `
    --buildtype=release `
    --wrap-mode=nofallback `
    _build
meson install -C="_build"
Set-Location ../../

meson subprojects download gperf
Set-Location subprojects/gperf
meson setup --prefix="$PREFIX\$arch" `
    --default-library=static `
    --buildtype=release `
    --wrap-mode=nofallback `
    _build
meson install -C="_build"
Set-Location ../../

meson subprojects download expat
Set-Location subprojects/expat-*
meson setup --prefix="$PREFIX\$arch" `
    --default-library=static `
    --buildtype=release `
    --wrap-mode=nofallback `
    _build
meson install -C="_build"
Set-Location ../../

meson subprojects download freetype2
Set-Location subprojects/freetype2
meson setup --prefix="$PREFIX\$arch" `
    --default-library=static `
    --buildtype=release `
    --wrap-mode=nofallback `
    _build
meson install -C="_build"
Set-Location ../../

meson subprojects download fontconfig
Set-Location subprojects/fontconfig
meson setup --prefix="$PREFIX\$arch" `
    --default-library=static `
    --buildtype=release `
    --wrap-mode=nofallback `
    --force-fallback-for=expat `
    _build
meson install -C="_build"
Set-Location ../../


Set-Location ../
meson setup --prefix="$PREFIX\$arch" `
    -Dtee=enabled `
    -Dtests=disabled `
    -Dfreetype=enabled `
    --default-library=static `
    --buildtype=release `
    --wrap-mode=nofallback `
    -Dglib=disabled `
    cairo_builddir `
    cairo

meson compile -C cairo_builddir
meson install --no-rebuild -C cairo_builddir

$env:PATH = $prev_PATH
