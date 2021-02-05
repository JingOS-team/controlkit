import QtQuick 2.0

Rectangle {
    id:keyBtn
    property alias keyStr: keyText.text

    implicitWidth:  jkeyboard.boardWidth*0.09//160
    implicitHeight: jkeyboard.boardHeight*0.1613  //106
    color:mouse.containsMouse ? (mouse.pressed ? "#787880":"#FFFFFF"):"#A6FFFFFF"
    opacity: mouse.containsMouse ? (mouse.pressed ? 1.0:0.9):1.0
    radius: keyBtn.height*0.34

    Text {
        id:keyText
        anchors.centerIn: parent
        horizontalAlignment:Text.AlignHCenter
        verticalAlignment :Text.AlignVCenter
        font.family : "Gilroy"
        font.weight: Font.Normal
        font.pixelSize: parseInt(jkeyboard.boardHeight*0.0472)
        color: "#000000"
    }
    MouseArea{
        id:mouse
        hoverEnabled : true
        anchors.fill: parent
        onClicked: {
            jkeyboard.keyBtnClick(keyStr)
        }
    }
}
