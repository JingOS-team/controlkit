#!/bin/sh
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

[ -e debian/tests.home ] || mkdir debian/tests.home
if [ -z "$HOME" ] || [ ! -d "$HOME" ]; then
    [ -e debian/tests.home ] || mkdir debian/tests.home
    export HOME="$(pwd)/debian/tests.home"
    trap "rm -rf debian/tests.home" EXIT
fi
mkdir -p "$HOME"/.config || true
mkdir -p "$HOME"/.kde-unit-test || true

export XDG_CACHE_HOME="$HOME"

openbox &
sleep 5
# dh_auto_test
# Why is the add_test in autotests/CMakeLists.txt not doing anything?
qmltestrunner
