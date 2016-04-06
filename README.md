# Kirigami

Build on Android:
```
mkdir build
cd build

cmake ..  -DCMAKE_TOOLCHAIN_FILE=/path/to/share/ECM/toolchain/Android.cmake -DQTANDROID_EXPORTED_TARGET=kirigamigallery -DANDROID_APK_DIR=../src/qrcexample/ -DCMAKE_PREFIX_PATH=/path/to/Qt-Android/5.5/android_armv7/ -DCMAKE_INSTALL_PREFIX=/path/to/dummy/install/prefix
```

You need a `-DCMAKE_INSTALL_PREFIX` to somewhere in your home, but using an absolute path

```
make
make install
make create-apk-kirigamigallery
```

`kirigamigallery_build_apk/bin/QtApp-debug.apk` will be generated

to directly install on a phone:
```
adb install ./kirigamigallery_build_apk//bin/QtApp-debug.apk
```
