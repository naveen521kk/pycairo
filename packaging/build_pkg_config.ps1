
$prev_PATH = $env:PATH
Write-Output "Setting enviroment variable using vswhere"
$host_arch = "amd64"
$arch = "amd64"
$env:PLATFORM="x64"

# from https://github.com/microsoft/vswhere/wiki/Start-Developer-Command-Prompt#using-powershell
$installationPath = vswhere.exe -prerelease -latest -property installationPath
if ($installationPath -and (test-path "$installationPath\Common7\Tools\vsdevcmd.bat")) {
    & "${env:COMSPEC}" /s /c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" -no_logo -host_arch=$host_arch -arch=$arch && set" | foreach-object {
        $name, $value = $_ -split '=', 2
        set-content env:\"$name" $value
    }
}
pip install meson==0.56.* ninja
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
$env:PATH="C:\build\pkg-config\bin;$env:PATH"
