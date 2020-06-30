set ROOTDIR=%USERPROFILE%\BuildCairo
rmdir /S /Q %ROOTDIR%
mkdir %ROOTDIR%
cd %ROOTDIR%
curl http://www.zlib.net/zlib-1.2.3.tar.gz -o zlib.tgz
curl ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.2.40.tar.gz -o libpng.tgz
curl http://www.cairographics.org/releases/pixman-0.16.2.tar.gz -o pixman.tgz
curl http://www.cairographics.org/releases/cairo-1.8.8.tar.gz -o cairo.tgz
tar -xzf zlib.tgz
tar -xzf libpng.tgz
tar -xzf pixman.tgz
tar -xzf cairo.tgz
move zlib-* zlib
move libpng-* libpng
move pixman-* pixman
move cairo-* cairo
mkdir %ROOTDIR%\zlib\projects\visualc71
cd %ROOTDIR%\zlib\projects\visualc71
copy %ROOTDIR%\libpng\projects\visualc71\zlib.vcproj .
vcbuild /upgrade zlib.vcproj
sed /RuntimeLibrary=/s/2/0/ zlib.vcproj > fixed.vcproj
move /Y fixed.vcproj zlib.vcproj
vcbuild zlib.vcproj "LIB Release"
cd %ROOTDIR%\libpng\projects\visualc71
vcbuild /upgrade libpng.vcproj
sed /RuntimeLibrary=/s/2/0/ libpng.vcproj > fixed.vcproj
move /Y fixed.vcproj libpng.vcproj
vcbuild libpng.vcproj "LIB Release"
cd %ROOTDIR%\pixman\pixman
sed s/-MD/-MT/ Makefile.win32 > Makefile.fixed
move /Y Makefile.fixed Makefile.win32
make -f Makefile.win32 "CFG=release"
set INCLUDE=%INCLUDE%;%ROOTDIR%\zlib
set INCLUDE=%INCLUDE%;%ROOTDIR%\libpng
set INCLUDE=%INCLUDE%;%ROOTDIR%\pixman\pixman
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\boilerplate
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\src

set LIB=%LIB%;%ROOTDIR%\zlib\projects\visualc71\Win32_LIB_Release\Zlib
set LIB=%LIB%;%ROOTDIR%\libpng\projects\visualc71\Win32_LIB_Release
cd %ROOTDIR%\cairo
sed s/-MD/-MT/ build\Makefile.win32.common > build\Makefile.fixed
move /Y build\Makefile.fixed build\Makefile.win32.common
sed s/zdll.lib/zlib.lib/ build\Makefile.win32.common > build\Makefile.fixed
move /Y build\Makefile.fixed build\Makefile.win32.common
make -f Makefile.win32 "CFG=release"
