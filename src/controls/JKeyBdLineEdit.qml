import QtQuick 2.0
import QtQml 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Styles 1.4
Rectangle{
    id:authenticationinput
    property string labelData:""
    property string labelDisplayData:""
    property var preChar: ""
    property int timeFlag:0
    property var coverChar: "∙"//String.fromCharCode(9679)
    property bool visibleFlag:false
    property var courseColor :"#FFFFFF"
    property var textColor :"#FFFFFF"
    property var visableIconColor:"#FFAEAEAE"
    property var cleanIconColor:"#FFAEAEAE"
    property bool ctrlPressFlag: false
    property alias lableId: lable
    property var visableIconBackgroundColor: ""
    property var cleanIconBackgroundColor: ""

    signal mousePress()

    width:466
    height:60
    radius:authenticationinput.height*0.183
    border.color: Qt.rgba(0,0,0,0.15)
    border.width:  1

    JIconButton {
        id:delBtn
        visible: labelData
        anchors.right: parent.right
        anchors.rightMargin: authenticationinput.width*0.0343//16
        anchors.verticalCenter: parent.verticalCenter
        color: cleanIconColor
        padding: 0
        iconRadius:delBtn.width/5
        backgroundColor:cleanIconBackgroundColor ? cleanIconBackgroundColor : "transparent"
        width:cleanIconBackgroundColor ? Math.min(authenticationinput.width*0.0772,authenticationinput.height*0.533)*3/4 :
                                            Math.min(authenticationinput.width*0.0772,authenticationinput.height*0.533)
        height:cleanIconBackgroundColor ? Math.min(authenticationinput.width*0.0772,authenticationinput.height*0.533)*3/4:
                          Math.min(authenticationinput.width*0.0772,authenticationinput.height*0.533)
        source: Qt.resolvedUrl("./image/keyImage/pwd_cancel.svg")
        onClicked: {
            labelDisplayData = ""
            labelData=""
        }
    }

    JIconButton {
        id:seepassword
        visible: true
        anchors.right: delBtn.left
        anchors.rightMargin: authenticationinput.width*0.0343//25
        anchors.verticalCenter: parent.verticalCenter
        color: visableIconColor
        padding: 0
        iconRadius:seepassword.width/5
        backgroundColor:visableIconBackgroundColor ? visableIconBackgroundColor : "transparent"
        width:visableIconBackgroundColor ? Math.min(authenticationinput.width*0.0772,authenticationinput.height*0.533)*3/4 :
                                            Math.min(authenticationinput.width*0.0772,authenticationinput.height*0.533)
        height:visableIconBackgroundColor ? Math.min(authenticationinput.width*0.0772,authenticationinput.height*0.533)*3/4 :
                          Math.min(authenticationinput.width*0.0772,authenticationinput.height*0.533)
        source: visibleFlag ?
                   Qt.resolvedUrl("./image/keyImage/pwd_visible.svg")
                    :Qt.resolvedUrl("./image/keyImage/pwd_hidden.svg")
        onClicked: {
            visibleFlag=!visibleFlag
            console.debug(seepassword.source)
        }
    }
    Rectangle{
        width: authenticationinput.width-delBtn.width*2-authenticationinput.width*0.0686
        height: authenticationinput.height//  60
        anchors.left: parent.left
        border.color: "transparent"
        border.width: 0
        color: "transparent"
        radius:authenticationinput.radius
        Label{
            id: lable
            width: parent.width-20
            anchors.centerIn: parent
            text: visibleFlag ? labelData : labelDisplayData
            font.family : "Gilroy"
            font.weight: Font.Normal
            font.pixelSize: parseInt(authenticationinput*0.517)//31
            clip: true
            horizontalAlignment:contentWidth > width ?  Text.AlignRight:Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            color: textColor
            Rectangle{
                id:course
                width: 3
                height:lable.height*3/4
                visible: lable.activeFocus
                color: courseColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:  parent.left
            }
            onContentWidthChanged: {
                if(contentWidth<width){
                    course.anchors.leftMargin=contentWidth
                }else{
                    course.anchors.leftMargin=lable.width-2
                }
            }
            Keys.onPressed: {
                switchKeyValue(event)
            }
            Keys.onReleased: {
                if(event.key===Qt.Key_Control){
                    ctrlPressFlag=false
                }
            }
        }
        MouseArea{
            id:mouse
            anchors.fill: parent
            onPressed: {
                lable.forceActiveFocus()
                mousePress()
            }
        }
        Timer {
            id:timer
            interval: 500;
            running: lable.activeFocus//true
            repeat: true
            onTriggered: {
                course.visible=!course.visible
                timeFlag+=1
                if(timeFlag>3){
                    timeFlag=0
                    if(!visibleFlag){
                        if(preChar!=""&&preChar!=coverChar){
                            labelDisplayData=labelDisplayData.replace(preChar,coverChar)
                        }
                    }
                }
            }
            onRunningChanged: {
                if(timer.running===false)
                {
                    course.visible=false
                    if(!visibleFlag){
                        if(preChar!=""&&preChar!=coverChar){
                            labelDisplayData=labelDisplayData.replace(preChar,coverChar)
                        }
                    }
                }else{
                    course.visible=true
                }
            }
        }
    }
    function clearData(){
        labelData=""
        labelDisplayData=""
    }
    function opSubStr (){
        if(labelData.length>0){
            labelData=labelData.substring(0,labelData.length-1)
            labelDisplayData=labelDisplayData.substring(0,labelDisplayData.length-1)
        }else{
            labelData=""
            labelDisplayData=""
        }
    }
    function opAddStr (str){
//        if(!visibleFlag){
            if(preChar!=""&&preChar!=coverChar){
                labelDisplayData=labelDisplayData.replace(preChar,coverChar)
//            }
        }
        preChar=str
        labelData+=str
        labelDisplayData+=str
    }
    function switchKeyValue(event){
        switch(event.key){
        case Qt.Key_ParenRight://")"
        case Qt.Key_0:
        case Qt.Key_Exclam://“!”
        case Qt.Key_1:
        case Qt.Key_At://"@"
        case Qt.Key_2:
        case Qt.Key_NumberSign://"#"
        case Qt.Key_3:
        case Qt.Key_Dollar://"$"
        case Qt.Key_4:
        case Qt.Key_Percent://"%"
        case Qt.Key_5:
        case Qt.Key_AsciiCircum://"^"
        case Qt.Key_6:
        case Qt.Key_Ampersand://"&"
        case Qt.Key_7:
        case Qt.Key_Asterisk://"*"
        case Qt.Key_8:
        case Qt.Key_ParenLeft://"("
        case Qt.Key_9:
        case Qt.Key_A:
        case Qt.Key_B:
        case Qt.Key_C:
        case Qt.Key_D:
        case Qt.Key_E:
        case Qt.Key_F:
        case Qt.Key_G:
        case Qt.Key_H:
        case Qt.Key_I:
        case Qt.Key_J:
        case Qt.Key_K:
        case Qt.Key_L:
        case Qt.Key_M:
        case Qt.Key_N:
        case Qt.Key_O:
        case Qt.Key_P:
        case Qt.Key_Q:
        case Qt.Key_R:
        case Qt.Key_S:
        case Qt.Key_T:
        case Qt.Key_U:
        case Qt.Key_V:
        case Qt.Key_W:
        case Qt.Key_X:
        case Qt.Key_Y:
        case Qt.Key_Z:
        case Qt.Key_AsciiTilde:// “~”
        case Qt.Key_QuoteLeft:// “`”
        case Qt.Key_Minus:// “-”
        case Qt.Key_Underscore:// “_”
        case Qt.Key_Plus://“+”
        case Qt.Key_Equal://“=”
        case Qt.Key_BraceLeft:// “{”
        case Qt.Key_BracketLeft:// “[”
        case Qt.Key_BraceRight:// “}”
        case Qt.Key_BracketRight:// “]”
        case Qt.Key_Bar:// “|”
        case Qt.Key_Backslash:// “\”
        case Qt.Key_Colon://“;”
        case Qt.Key_Semicolon://“;”
        case Qt.Key_QuoteDbl://“"”
        case Qt.Key_Apostrophe://“'”
        case Qt.Key_Space://“空格 ”
        case Qt.Key_Less://“<”
        case Qt.Key_Comma://“,”
        case Qt.Key_Greater://“>”
        case Qt.Key_Period://“.”
        case Qt.Key_Question:// “?”
        case Qt.Key_Slash:// “/”
            if(!ctrlPressFlag)
            {
                timeFlag=0
                opAddStr(event.text)
            }
            break;
        case Qt.Key_CapsLock://“切换大小写 ”

            break;
        case Qt.Key_Return://“left Enter”

            break;
        case Qt.Key_Shift://“shrift”

            break;
        case Qt.Key_Enter://“enter”

            break;
        case Qt.Key_Backspace://“Backspace”
            opSubStr()
            break;
        case Qt.Key_Control://“Ctrl”
            ctrlPressFlag=true
            break;
        case Qt.Key_Alt://“Alt”

            break;
        default:
            break;
        }
    }
}
