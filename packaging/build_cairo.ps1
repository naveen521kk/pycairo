param($CAIRO_VERSION, $PREFIX, $ARCH)

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
pip install meson==0.56.*
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



meson setup `
    --default-library=static `
    --buildtype=release `
    -Dtee=enabled `
    -Dtests=disabled `
    -Dfreetype=disabled `
    -Dfontconfig=disabled `
    --backend=vs2017 `
    --build.cmake-prefix-path="" `
    --build.pkg-config-path="" `
    -Dglib=disabled `
    cairo_builddir `
    cairo

meson compile -C cairo_builddir
meson install --no-rebuild -C cairo_builddir

$env:PATH = $prev_PATH
