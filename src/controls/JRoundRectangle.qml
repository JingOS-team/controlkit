import QtQuick 2.12
import QtQml 2.12
Item {
    id:root
    property color color: "#ffffff"
    property int radius: 0

    property int borderWidth: 0
    property color borderColor: "transparent"

    property int arrowX: 0
    property int arrowY: 0

    property int arrowWidth : 12
    property int arrowHeight: 8


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

    onColorChanged: {
        mycanvas.requestPaint();
    }

    onRadiusChanged: {
        mycanvas.requestPaint();
    }

    onBorderColorChanged: {
        mycanvas.requestPaint();
    }

    onBorderWidthChanged: {
        mycanvas.requestPaint();
    }

    Canvas {
        id: mycanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            if(root.borderWidth >= 1){
                ctx.strokeStyle = root.borderColor
                ctx.lineWidth = root.borderWidth;
            }

            ctx.fillStyle = root.color
            var w = width;
            var h = height;
            if((root.arrowPos & JRoundRectangle.ARROW_TOP) || (root.arrowPos & JRoundRectangle.ARROW_BOTTOM)){
                h = h - root.arrowHeight;
            } else if((root.arrowPos & JRoundRectangle.ARROW_RIGHT) || (root.arrowPos & JRoundRectangle.ARROW_LEFT)){
                w = w - root.arrowWidth;
            }

            drawRoundRectPath(ctx, w, h, root.radius, root.radiusPos, root.arrowPos, root.arrowX, root.arrowY, root.arrowWidth, root.arrowHeight);
            ctx.fill();
            if(root.borderWidth >= 1){
                ctx.stroke();
            }
        }

        function drawRoundRectPath(cxt, width, height, radius, rPos, aPos, ax, ay, aw, ah) {
            cxt.beginPath();
            if(rPos & JRoundRectangle.BOTTOMRIGHT){
                //从右下角顺时针绘制，弧度从0到1/2PI
                cxt.arc(width - radius, height - radius, radius, 0, Math.PI / 2);
            } else {

                    cxt.moveTo(width, height);

            }

            if(rPos & JRoundRectangle.BOTTOMLEFT){
                //画底线
                if(aPos & JRoundRectangle.ARROW_BOTTOM){
                    var apstart = ax + aw / 2;
                    var apend = ax - aw / 2;
                    console.log("line to " + apstart + "  " + height)
                    cxt.lineTo(apstart, height);
                    console.log("line to " + ax + "  " + height + ah)
                    cxt.lineTo(ax, height + ah);
                    console.log("line to " + apend + "  " + height)
                    cxt.lineTo(apend, height);
                } else {
                    cxt.lineTo(radius, height);
                }

                //左下角圆弧，弧度从1/2PI到PI
                cxt.arc(radius, height - radius, radius, Math.PI / 2, Math.PI);
            } else {
                if(aPos & JRoundRectangle.ARROW_BOTTOM){
                    var apstart = ax + aw / 2;
                    var apend = ax - aw / 2;
                    console.log("line to " + apstart + "  " + height)
                    cxt.lineTo(apstart, height);
                    console.log("line to " + ax + "  " + height + ah)
                    cxt.lineTo(ax, height + ah);
                    console.log("line to " + apend + "  " + height)
                    cxt.lineTo(apend, height);
                    cxt.lineTo(0, height);
                } else {
                    cxt.lineTo(0, height);
                }
            }

            if(rPos & JRoundRectangle.TOPLEFT){
                //画左线
                cxt.lineTo(0, radius);
                //左上角圆弧，弧度从PI到3/2PI
                cxt.arc(radius, radius, radius, Math.PI, Math.PI * 3 / 2);
            } else {
                cxt.lineTo(0, 0);
            }

            if(rPos & JRoundRectangle.TOPRIGHT){
                //画上线
                cxt.lineTo(width - radius, 0);
                //右上角圆弧
                cxt.arc(width - radius, radius, radius, Math.PI * 3 / 2, Math.PI * 2);
            } else {
                cxt.lineTo(width, 0);
            }

            if(rPos & JRoundRectangle.BOTTOMRIGHT){
                //画右线
                cxt.lineTo(width, height - radius);
            } else {
                cxt.lineTo(width, height);
            }
            cxt.closePath();
        }
    }
}
