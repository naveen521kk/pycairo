
cp cairocomplied/lib/x86/cairo.dll cairo/cairo.dll
curl -L https://aka.ms/nugetclidl -o nuget.exe
./nuget install pythonx86 -Version $PYVER -OutputDirectory pythonx86
./pythonx86/pythonx86.$PYVER/tools/python.exe -m venv buildcairo
source buildcairo/Scripts/activate
python -m pip install --upgrade pip
python -m pip install --upgrade wheel
python -m pip install --upgrade setuptools
python -m pip install pytest
python -m pip install --upgrade mypy || true
export INCLUDE="$PWD/cairocomplied/include/"
export LIB="$PWD/cairocomplied/lib/x86/"
cmd.exe //c "RefreshEnv.cmd"
python setup.py bdist_wheel
python -m pip install dist/WHEELSNAMEx32
python testcairo.py

