# controlKit
controlKit is based on Kirigami [gitlab](https://github.com/KDE/kirigami.git)
QtQuick plugins to build user interfaces based on the KDE UX guidelines

## Introduction

controlKit is a set of QtQuick components at the moment targeted for mobile use (in the future desktop as well) targeting both Plasma Mobile and Android. It’s not a whole set of components, all the “Primitive” ones like buttons and textboxes are a job for QtQuickControls (soon QtQuickControls2) but it’s a set of high level components to make the creation of applications that look and feel great on mobile as well as desktop devices and follow the Kirigami Human Interface Guidelines.


## Dependencies
* Cmake
* ECM
* LibExiv2
* KI18n
* Qt5Core
* Qt5Quick
* Qt5Gui
* Qt5Svg
* Qt5QuickControls2
* Qt5Concurrent


## Building and Installing

```sh
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/path/to/prefix
make 
sudo make install
```
Replace `/path/to/prefix` to your installation prefix.
Default is `/usr`.


## Licensing
GPLv3, see [this page](https://www.gnu.org/licenses/gpl-3.0.en.html).

