# Kirigami

Build the gallery example app on Android:
```
mkdir build
cd build

cmake ..  -DCMAKE_TOOLCHAIN_FILE=/path/to/share/ECM/toolchain/Android.cmake -DQTANDROID_EXPORTED_TARGET=kirigami2gallery -DANDROID_APK_DIR=../examples/android/ -DCMAKE_PREFIX_PATH=/path/to/Qt5.7.0/5.7/android_armv7/ -DCMAKE_INSTALL_PREFIX=/path/to/dummy/install/prefix -DBUILD_EXAMPLES=ON
```

You need a `-DCMAKE_INSTALL_PREFIX` to somewhere in your home, but using an absolute path

If you have a local checkout of the breeze-icons repo, you can avoid the cloning of the build dir
by passing also `-DBREEZEICONS_DIR=/path/to/existing/sources/of/breeze-icons`

```
make
make install
make create-apk-kirigami2gallery
```

`kirigamigallery_build_apk/bin/QtApp-debug.apk` will be generated

to directly install on a phone:
```
adb install -r ./kirigami2gallery_build_apk/bin/QtApp-debug.apk
```

# Build on your application Android, ship it together Kirigami

1) Build kirigami
```

use the same procedure mentioned above (but without BUILD_EXAMPLES switch

cd into kirigami sources directory.

mkdir build
cd build

cmake ..  -DCMAKE_TOOLCHAIN_FILE=/path/to/share/ECM/toolchain/Android.cmake -DQTANDROID_EXPORTED_TARGET=kirigami2gallery -DANDROID_APK_DIR=../examples/android/ -DCMAKE_PREFIX_PATH=/path/to/Qt5.7.0/5.7/android_armv7/ -DCMAKE_INSTALL_PREFIX=/path/to/dummy/install/prefix

```
make
make install
```
(note, omit the make create-apk-kirigami2gallery step)

2) Build your application
```
This guide assumes you build your application with CMake and use Extra-cmake-modules from KDE frameworks.


cd into your application sources directory.

mkdir build
cd build

cmake ..  -DCMAKE_TOOLCHAIN_FILE=/path/to/share/ECM/toolchain/Android.cmake -DQTANDROID_EXPORTED_TARGET=kirigami2gallery -DANDROID_APK_DIR=../examples/android/ -DCMAKE_PREFIX_PATH=/path/to/Qt5.7.0/5.7/android_armv7/ -DCMAKE_INSTALL_PREFIX=/path/to/dummy/install/prefix

Note, -DCMAKE_INSTALL_PREFIX folder will be the same as where kirigami was installed, since you need to create an apk package that contains both the kirigami build and the build of your application.

```
make
make install
make create-apk-yourapp
```

where make create-apk-yourapp dependes from the actual name of your application

