/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.4 as Kirigami

Popup{
    id:arrowDlg
    padding: 0

    Item{
        id:calculationProxy
        objectName:"calculationProxy"
        anchors.fill:parent
        visible:false
    }

    enum Orientation {
        UNKNOWNORI,
        UP,
        DOWN,
        LEFT,
        RIGHT
    }

    visible:true
    width:200
    height:300
    background: Rectangle{
        anchors.fill:parent
        color:"transparent"
    }

    property int orientation: JArrowPopup.Orientation.UNKNOWNORI
    property Item orientedItem: null

    modal:true

    Shape{
            id:popShape
            anchors.fill:parent
            smooth:true
            antialiasing: true
            ShapePath{
                id:popPath
                strokeColor: "transparent"
                strokeWidth: 0
                fillColor: "white"
                capStyle: ShapePath.WindingFill
            }
    }
    Loader{
        id:paintLoader
        anchors.fill:parent
        sourceComponent:undefined
    }
    


    ///////////////////////////////////

    function setOrientation(ori){
        orientation = ori;
    }

    function setOrientedItem(item){
        orientedItem = item;
        parent = item;
        if(!orientedItem){
            apData.arrowPos = -1;
        }
    }

    function setArrowHeight(h){
        apData.arrowHeight = h;
    }

    function setArrowPos(pos){
        apData.arrowPos = pos;
    }

    function setDockedPoint(p){
        apData.dockedPoint = p
    }

    function draw(){
        arrowDlg.visible =true;
        apData.geoCalOrientedRect();
        apData.geoCalArrowPos();
        apData.geoCalArrowPoint();
        apData.geoCalDockedPoint();
        apData.geoTransToPopup();
        apData.geoMovePopup();
        apData.geoTransToPopup();
        apData.calArrowPosInPopup();
        switch(orientation){
            case JArrowPopup.Orientation.UP:
                paintLoader.sourceComponent = apData.upShape;
                break;
            case JArrowPopup.Orientation.DOWN:
                break;
            case JArrowPopup.Orientation.LEFT:
                break;
            case JArrowPopup.Orientation.RIGHT:
                break;
        }
    }

    QtObject{
        id:apData
        property int popRadius: 8
        property int arrowWidth: Kirigami.Units.gridUnit * 1.5
        property int arrowHeight: Kirigami.Units.gridUnit * 0.66
        property int arrowPos: -1
        property int arrowStart: -1
        property int arrowPosPopup: -1
        property int arrowStartPopup: -1
        property rect orientedRect:Qt.rect(0,0,0,0)
        property rect orParent: Qt.rect(0,0,0,0)
        property point orientedPoint:Qt.point(-1, -1)
        property point opParent:Qt.point(-1, -1)
        property point dockedPoint:Qt.point(-1, -1)
        property point dpParent:Qt.point(-1, -1)

        function geoCalOrientedRect(){
            if(!orientedItem){
                return;
            }
            apData.orParent = Qt.rect(0, 0, orientedItem.width, orientedItem.height);
            apData.orientedRect = calculationProxy.mapFromItem(orientedItem, 0, 0, apData.orParent.width, apData.orParent.height);
        }

        function geoCalArrowPos(){
            switch(orientation){
                case JArrowPopup.Orientation.UP:
                case JArrowPopup.Orientation.DOWN:
                    if(arrowDlg.width < arrowWidth + Kirigami.Units.gridUnit * 2){
                        arrowDlg.width = arrowWidth + Kirigami.Units.gridUnit * 2;
                    }
                    if(arrowDlg.width  - Kirigami.Units.gridUnit * 2 > parent.Window.window.width){
                        arrowDlg.width = parent.Window.window.width - Kirigami.Units.gridUnit * 2
                    }
                    if(arrowPos <= 0  || arrowPos >= orParent.width){
                        arrowPos = orParent.width / 2;
                    }
                    break;
                case JArrowPopup.Orientation.LEFT:
                case JArrowPopup.Orientation.RIGHT:
                    if(arrowDlg.height < arrowWidth + Kirigami.Units.gridUnit * 2){
                        arrowDlg.height = arrowWidth + Kirigami.Units.gridUnit * 2;
                    }
                    if(arrowDlg.height - Kirigami.Units.gridUnit * 2 > parent.Window.window.height){
                        arrowDlg.height = parent.Window.window.height - Kirigami.Units.gridUnit * 2
                    }
                    if(arrowPos <= 0 ||  arrowPos >= orParent.height){
                        arrowPos = orParent.height / 2;
                    }
                    break;
            }
            arrowStart = arrowPos - arrowWidth / 2;
        }

        function geoCalArrowPoint(){
            switch(orientation){
                case JArrowPopup.Orientation.UP:
                    opParent = Qt.point(arrowPos, orParent.bottom);
                    break;
                case JArrowPopup.Orientation.DOWN:
                    opParent = Qt.point(arrowPos, orParent.top);
                    break;
                case JArrowPopup.Orientation.LEFT:
                    opParent = Qt.point(orParent.right, arrowPos);
                    break;
                case JArrowPopup.Orientation.RIGHT:
                    opParent = Qt.point(orParent.left, arrowPos);
                    break;
            }
        }

        function geoCalDockedPoint(){
            switch(orientation){
                case  JArrowPopup.Orientation.UP:
                    dpParent = Qt.point(opParent.x, opParent.y + arrowHeight);
                    break;
                case  JArrowPopup.Orientation.DOWN:
                    dpParent = Qt.point(opParent.x, opParent.y - arrowHeight);
                    break;
                case  JArrowPopup.Orientation.LEFT:
                    dpParent = Qt.point(opParent.x + arrowHeight, opParent.y);
                    break;
                case  JArrowPopup.Orientation.RIGHT:
                    dpParent = Qt.point(opParent.x - arrowHeight, opParent.y);
                    break;
            }
        }

        function geoTransToPopup(){
            orientedPoint = Qt.point(opParent.x - arrowDlg.x, opParent.y - arrowDlg.y);
        }

        function calArrowPosInPopup(){
            switch(orientation){
                case JArrowPopup.Orientation.UP:
                case JArrowPopup.Orientation.DOWN:
                    arrowPosPopup = Math.abs(arrowPos - arrowDlg.x);
                    break;
                case JArrowPopup.Orientation.LEFT:
                case JArrowPopup.Orientation.RIGHT:
                    arrowPosPopup = Math.abs(arrowPos - arrowDlg.y);
                    break;
            }
            arrowStartPopup = arrowPosPopup - arrowWidth / 2;
        }

        function geoMovePopup(){
            switch(orientation){
                case JArrowPopup.Orientation.UP:
                case JArrowPopup.Orientation.DOWN:
                    arrowDlg.y = dpParent.y;
                    if(arrowDlg.x + arrowWidth / 2 + Kirigami.Units.gridUnit > arrowPos){
                        arrowDlg.x = arrowPos - (arrowWidth / 2 + Kirigami.Units.gridUnit)
                    }
                    if(arrowDlg.x + arrowDlg.width - arrowWidth / 2  - Kirigami.Units.gridUnit < arrowPos){
                        arrowDlg.x = arrowDlg.x + (arrowWidth / 2 + Kirigami.Units.gridUnit - (arrowDlg.x + arrowDlg.width - arrowPos))
                    }
                    break;
                case JArrowPopup.Orientation.LEFT:
                case JArrowPopup.Orientation.RIGHT:
                    arrowDlg.x = dpParent.x;
                    if(arrowDlg.y + arrowWidth / 2 + Kirigami.Units.gridUnit > arrowPos){
                        arrowDlg.y = arrowPos - (arrowWidth / 2 + Kirigami.Units.gridUnit)
                    }
                    if(arrowDlg.y + arrowDlg.height - arrowWidth / 2  - Kirigami.Units.gridUnit < arrowPos){
                        arrowDlg.y = arrowDlg.y + (arrowWidth / 2 + Kirigami.Units.gridUnit - (arrowDlg.x + arrowDlg.height - arrowPos))
                    }
                    break;
            }
        }

        ////////////////////////////////////////////////
        //path functions
        ////////////////////////////////////////////////

        function shapeUp(){
            popPath.pathElements = [];
            popPath.startX = 0;
            popPath.startY = popRadius;

            var arc = Qt.createQmlObject('import QtQuick 2.15; PathArc{}', popPath);
            arc.x = apData.popRadius;
            arc.y = 0;
            arc.radiusX = popRadius;
            arc.radiusY = popRadius;
            popPath.pathElements.push(arc);

            var line = Qt.createQmlObject('import QtQuick 2.15; PathLine{}', popPath);
            line.x = apData.arrowStartPopup;
            line.y = 0;
            popPath.pathElements.push(line);

            line = Qt.createQmlObject('import QtQuick 2.15; PathLine{}', popPath);
            line.x = apData.orientedPoint.x;
            line.y = apData.orientedPoint.y;
            popPath.pathElements.push(line);

            line = Qt.createQmlObject('import QtQuick 2.15; PathLine{}', popPath);
            line.x = apData.arrowStartPopup + apData.arrowWidth;
            line.y = 0;
            popPath.pathElements.push(line);
        }

        ///////////////////////////////////////////////
        property Component upShape:Component{
            Shape{
                id:shapeUp
                //anchors.fill:parent
                smooth:true
                antialiasing: true

                ShapePath {
                    strokeColor: "transparent"
                    strokeWidth: 0
                    fillColor: "white"
                    capStyle: ShapePath.WindingFill

                    startX: 0
                    startY: apData.popRadius
                    PathArc{
                        x: apData.popRadius
                        y: 0
                        radiusX: apData.popRadius
                        radiusY: apData.popRadius
                    }
                    PathLine{
                        x: apData.arrowStartPopup
                        y: 0
                    }
                    PathLine{
                        x: apData.orientedPoint.x
                        y: apData.orientedPoint.y
                    }
                    PathLine{
                        x: apData.arrowStartPopup + apData.arrowWidth
                        y: 0
                    }
                    PathLine{
                        x: arrowDlg.width - apData.popRadius
                        y: 0
                    }
                    PathArc{
                        x: arrowDlg.width
                        y: apData.popRadius
                        radiusX: apData.popRadius
                        radiusY: apData.popRadius
                    }
                    PathLine{
                        x: arrowDlg.width
                        y: arrowDlg.height - apData.popRadius
                    }
                    PathArc{
                        x: arrowDlg.width - apData.popRadius
                        y: arrowDlg.height
                        radiusX: apData.popRadius
                        radiusY: apData.popRadius
                    }
                    PathLine{
                        x:apData.popRadius
                        y:arrowDlg.height
                    }
                    PathArc{
                        x: 0
                        y: arrowDlg.height - apData.popRadius
                        radiusX: apData.popRadius
                        radiusY: apData.popRadius
                    }
                    PathLine{
                        x:0
                        y:apData.popRadius
                    }
                }
            }
        } //end of upShape

        property Component downShape: Component{
            Shape{

            }
        } //end of downShape

        property Component leftShape: Component{
            Shape{

            }
        } // end of leftShape

        property Component rightShape: Component{
            Shape{

            }
        } // end of rightShape
    }
}