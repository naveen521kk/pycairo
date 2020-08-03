pip install meson
pip install ninja
curl http://www.cairographics.org/releases/cairo-1.8.8.tar.gz -o cairo.tgz
curl -L https://github.com/preshing/cairo-windows/releases/download/$CAIRO_VERSION/cairo-windows-$CAIRO_VERSION.zip -o cairocomplied.zip
7z x cairocomplied.zip
7z x cairo.tgz
cd cairo
meson compile
cmd //c tree
cd ../
mv cairo-windows-$CAIRO_VERSION cairocomplied
