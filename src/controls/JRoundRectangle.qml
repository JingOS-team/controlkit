/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.12
import QtQml 2.12
import jingos.display 1.0
Item {
    id:root
    property color color: "#ffffff"
    property int radius: 0

    property int borderWidth: 0
    property color borderColor: "transparent"

    property int arrowX: 0
    property int arrowY: 0

    property int arrowWidth :JDisplay.dp(16)
    property int arrowHeight: JDisplay.dp(8)


    property int radiusPos:JRoundRectangle.UNKOWN
    property int arrowPos:JRoundRectangle.ARROW_UNKOWN
    enum RadiusPos{
        UNKOWN  = 0x00,
        TOPLEFT = 0x01,
        TOPRIGHT = 0x02,
        BOTTOMRIGHT = 0x04,
        BOTTOMLEFT = 0x08
    }

    enum ArrowPos{
        ARROW_UNKOWN  = 0x00,
        ARROW_TOP = 0x01,
        ARROW_RIGHT = 0x02,
        ARROW_BOTTOM = 0x04,
        ARROW_LEFT = 0x08
    }

    onArrowPosChanged: {
        mycanvas.requestPaint();
    }

    onColorChanged: {
        mycanvas.requestPaint();
    }

    onRadiusChanged: {
        mycanvas.requestPaint();
    }

    onVisibleChanged: {
        if(visible){
            mycanvas.requestPaint();
        }
    }

    onBorderColorChanged: {
        mycanvas.requestPaint();
    }

    onBorderWidthChanged: {
        mycanvas.requestPaint();
    }

    onWidthChanged: {
        mycanvas.requestPaint()
    }

    onHeightChanged: {
        mycanvas.requestPaint()
    }

    Canvas {
        id: mycanvas
        anchors.fill: parent
        renderTarget:Canvas.FramebufferObject
        renderStrategy:Canvas.Cooperative
        onPaint: {

            var ctx = getContext("2d");
            ctx.clearRect(0,0,width,height);
            if(root.borderWidth >= 1){
                ctx.strokeStyle = root.borderColor
                ctx.lineWidth = root.borderWidth;
            }

            ctx.fillStyle = root.color

            drawRoundRectPath(ctx, width, height, root.radius, root.radiusPos, root.arrowPos, root.arrowX, root.arrowY, root.arrowWidth, root.arrowHeight);
            ctx.fill();
            if(root.borderWidth >= 1){
                ctx.stroke();
            }
        }

        /*
          cxt : Canvas handle
          width: rect width
          height: rect height
          radius: Fillet radius
          rPos:  Fillet position ， lefttop，righttop， rightbottom，leftbottom
          aPos:   Arrow position， left right top bottom
          ax:     The coordinates of the arrow  x
          ay:     The coordinates of the arrow  y
          aw:     Arrow width
          ah:     Arrow height

          --->
        |--------|
        |        |
        |--------|  //start pos
           <---
        */
        function drawRoundRectPath(cxt, width, height, radius, rPos, aPos, ax, ay, aw, ah) {
            cxt.beginPath();

            var apstart = ax + aw / 2;
            var apend = ax - aw / 2;

            if(rPos & JRoundRectangle.BOTTOMRIGHT){
                if(aPos & JRoundRectangle.ARROW_BOTTOM){
                    cxt.arc(width - radius, height - ah - radius, radius, 0, Math.PI / 2);
                } else {
                    cxt.arc(width - radius, height - radius, radius, 0, Math.PI / 2);
                }
            } else {
                if(aPos & JRoundRectangle.ARROW_BOTTOM){
                    cxt.moveTo(width, height - ah);
                } else {
                    cxt.moveTo(width, height);
                }
            }

            if(rPos & JRoundRectangle.BOTTOMLEFT){
                if(aPos & JRoundRectangle.ARROW_BOTTOM){
                    cxt.lineTo(apstart, height - ah);
                    cxt.lineTo(ax, height);
                    cxt.lineTo(apend, height - ah);
                    cxt.arc(radius, height - ah - radius, radius, Math.PI / 2, Math.PI);
                } else {
                    cxt.lineTo(radius, height);
                    cxt.arc(radius, height - radius, radius, Math.PI / 2, Math.PI);
                }
            } else {
                if(aPos & JRoundRectangle.ARROW_BOTTOM){

                    cxt.lineTo(apstart, height - ah);
                    cxt.lineTo(ax, height);
                    cxt.lineTo(apend, height - ah);
                    cxt.lineTo(0, height - ah);
                } else {
                    cxt.lineTo(0, height);
                }
            }

            if(rPos & JRoundRectangle.TOPLEFT){
                if(aPos & JRoundRectangle.ARROW_TOP){
                    cxt.lineTo(0, radius + ah);
                    cxt.arc(radius, radius + ah, radius, Math.PI, Math.PI * 3 / 2);
                } else {
                    cxt.lineTo(0, radius);
                    cxt.arc(radius, radius, radius, Math.PI, Math.PI * 3 / 2);
                }

            } else {
                if(aPos & JRoundRectangle.ARROW_TOP){
                    cxt.lineTo(0, ah);
                } else {
                    cxt.lineTo(0, 0);
                }
            }

            if(rPos & JRoundRectangle.TOPRIGHT){
                if(aPos & JRoundRectangle.ARROW_TOP){
                    cxt.lineTo(apend, ah);
                    cxt.lineTo(ax, 0);
                    cxt.lineTo(apstart, ah);
                    cxt.lineTo(width - radius, ah);
                    cxt.arc(width - radius, radius + ah, radius, Math.PI * 3 / 2, Math.PI * 2);
                } else {
                    cxt.lineTo(width - radius, 0);
                    cxt.arc(width - radius, radius, radius, Math.PI * 3 / 2, Math.PI * 2);
                }

            } else {
                if(aPos & JRoundRectangle.ARROW_TOP){
                    cxt.lineTo(apend, ah);
                    cxt.lineTo(ax, 0);
                    cxt.lineTo(apstart, ah);

                } else {
                    cxt.lineTo(width, 0);
                }
            }


            if(rPos & JRoundRectangle.BOTTOMRIGHT){
                if(aPos & JRoundRectangle.ARROW_BOTTOM){
                    cxt.lineTo(width, height - ah - radius);
                } else {
                    cxt.lineTo(width, height - radius);
                }
            } else {
                if(aPos & JRoundRectangle.ARROW_BOTTOM){
                    cxt.lineTo(width, height - ah);
                } else {
                    cxt.lineTo(width, height);
                }
            }
            cxt.closePath();
        }
    }
}
