#https://github.com/preshing/cairo-windows/releases/download/with-tee/cairo-windows-1.17.2.zip
curl -L https://github.com/preshing/cairo-windows/releases/download/with-tee/cairo-windows-$CAIRO_VERSION.zip -o cairocomplied.zip
7z x cairocomplied.zip
mv cairo-windows-$CAIRO_VERSION cairocomplied
