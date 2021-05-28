import QtQuick 2.0
import QtQml 2.12

Rectangle {
    id:keyBtn

    property alias keyStr: keyText.text
    property string imagePath:"upper.svg"
    property int type : 0
    property bool textVisible: true

    implicitWidth:  jkeyboard.boardWidth*0.1329//236
    implicitHeight: jkeyboard.boardHeight*0.1613 //106
    color:mouse.containsMouse ? (mouse.pressed ? "#787880":"#FFFFFF"):"#A6B8BACF"
    opacity: mouse.containsMouse ? (mouse.pressed ? 1.0:0.9):1.0
    radius: keyBtn.height*0.34

    Text {
        id:keyText
        anchors.fill: parent
        visible: textVisible
        horizontalAlignment:Text.AlignHCenter
        verticalAlignment :Text.AlignVCenter
        font.family : "Gilroy"
        font.weight: Font.Normal
        font.pixelSize:parseInt(jkeyboard.boardHeight*0.0472)//Math.round(keyBtn.height*0.2925)
        color: "#000000"
    }
    Item{
        width: 30//jkeyboard.boardHeight*0.0457
        height: 30//jkeyboard.boardHeight*0.0457
        anchors.centerIn: parent
        Image {
            id: keyImage
            anchors.fill: parent
            source: "./image/keyImage/"+imagePath
            visible: !textVisible
        }
    }

    MouseArea{
        id:mouse
        anchors.fill: parent
        hoverEnabled : true
        onClicked: {
            jkeyboard.changModel(textVisible,keyStr,imagePath)
        }
    }
}
