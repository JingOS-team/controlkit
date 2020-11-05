import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kirigami.private 2.13
import QtTest 1.0

Kirigami.PageRow {
    id: root
    TestCase {
        name: "AvatarTests"
        function test_latin_name() {
            compare(AvatarPrivate.stringUnsuitableForInitials("Nate Martin"), false)
            compare(AvatarPrivate.initialsFromString("Nate Martin"), "NM")

            compare(AvatarPrivate.stringUnsuitableForInitials("Kalanoka"), false)
            compare(AvatarPrivate.initialsFromString("Kalanoka"), "K")

            compare(AvatarPrivate.stringUnsuitableForInitials("Why would anyone use such a long not name in the field of the Name"), false)
            compare(AvatarPrivate.initialsFromString("Why would anyone use such a long not name in the field of the Name"), "WN")

            compare(AvatarPrivate.stringUnsuitableForInitials("Live-CD User"), false)
            compare(AvatarPrivate.initialsFromString("Live-CD User"), "LU")
        }
        // these are just randomly sampled names from internet pages in the
        // source languages of the name
        function test_jp_name() {
            compare(AvatarPrivate.stringUnsuitableForInitials("北里 柴三郎"), false)
            compare(AvatarPrivate.initialsFromString("北里 柴三郎"), "北")

            compare(AvatarPrivate.stringUnsuitableForInitials("小野田 寛郎"), false)
            compare(AvatarPrivate.initialsFromString("小野田 寛郎"), "小")
        }
        function test_cn_name() {
            compare(AvatarPrivate.stringUnsuitableForInitials("蔣經國"), false)
            compare(AvatarPrivate.initialsFromString("蔣經國"), "蔣")
        }
        function test_bad_names() {
            compare(AvatarPrivate.stringUnsuitableForInitials("151231023"), true)
        }
    }
}
