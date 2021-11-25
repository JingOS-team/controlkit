import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.14 as Kirigami
import QtTest 1.0

Kirigami.PageRow {
    id: root
    TestCase {
        name: "AvatarTests"
        function test_latin_name() {
            compare(Kirigami.NameUtils.isStringUnsuitableForInitials("Nate Martin"), false)
            compare(Kirigami.NameUtils.initialsFromString("Nate Martin"), "NM")

            compare(Kirigami.NameUtils.isStringUnsuitableForInitials("Kalanoka"), false)
            compare(Kirigami.NameUtils.initialsFromString("Kalanoka"), "K")

            compare(Kirigami.NameUtils.isStringUnsuitableForInitials("Why would anyone use such a long not name in the field of the Name"), false)
            compare(Kirigami.NameUtils.initialsFromString("Why would anyone use such a long not name in the field of the Name"), "WN")

            compare(Kirigami.NameUtils.isStringUnsuitableForInitials("Live-CD User"), false)
            compare(Kirigami.NameUtils.initialsFromString("Live-CD User"), "LU")
        }
        // these are just randomly sampled names from internet pages in the
        // source languages of the name
        function test_jp_name() {
            compare(Kirigami.NameUtils.isStringUnsuitableForInitials("北里 柴三郎"), false)
            compare(Kirigami.NameUtils.initialsFromString("北里 柴三郎"), "北")

            compare(Kirigami.NameUtils.isStringUnsuitableForInitials("小野田 寛郎"), false)
            compare(Kirigami.NameUtils.initialsFromString("小野田 寛郎"), "小")
        }
        function test_cn_name() {
            compare(Kirigami.NameUtils.isStringUnsuitableForInitials("蔣經國"), false)
            compare(Kirigami.NameUtils.initialsFromString("蔣經國"), "蔣")
        }
        function test_bad_names() {
            compare(Kirigami.NameUtils.isStringUnsuitableForInitials("151231023"), true)
        }
    }
}
