﻿import QtQuick 2.0
import QtQuick.Dialogs 1.0
import ".././button"

Item {
    id: mainroot

    Image{
       id: pre
       property bool playState: false
       anchors.fill: parent

    }

    property int  pageType: config.pageType_baiduFace
    signal sigReturnClicked()

    Flow{
        id: imgShow
        spacing: 10
        anchors.fill: parent
        anchors.margins: 20
    }


    FileDialog {
        id: fileDialog
        title: "请选择一张图片"
        folder: shortcuts.home
        nameFilters: [ "*.jpg *.png"]
        onAccepted: {
            var strpath = fileDialog.fileUrl.toString()
            console.log("You chose: " + strpath)
            mainroot.doImgChoice(strpath,true)
        }
        onRejected: {
            console.log("Canceled")
        }
    }


    Rectangle{
        id: showFlag
        width: 45
        height: parent.height
        anchors.left: parent.left
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#242424" }
            GradientStop { position: 1.0; color: "#444" }
        }
        opacity: 0
    }

    Image{
        id: leftBtn
        width: 25
        height: 50
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        source: "qrc:/skin/button/turnLeft.png"
        opacity: 0.3

        MouseArea{
            cursorShape:Qt.DragCopyCursor
            hoverEnabled: true
            anchors.fill: parent
            onEntered: {
                leftBtn.opacity = 0.8
                showFlag.opacity = 0.5
            }

            onExited: {
                leftBtn.opacity = 0.3
                showFlag.opacity = 0
            }

            onPressed: {
                leftBtn.opacity = 0.9
                showFlag.opacity = 0.9
            }

            onReleased: {
                if(showFlag.opacity != 0){
                    leftBtn.opacity = 0.8
                    showFlag.opacity = 0.5
                }
            }

            onClicked: {
                sigReturnClicked()
                console.log("trun_home_page")
            }
        }
    }

    Item{
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: 250
        height: 60
        Row{
            spacing: 50
            anchors.fill: parent
            anchors.centerIn: parent
            Loader{
                id: addbtnLoad
                sourceComponent: btnCom
                Component.onCompleted: {
                    addbtnLoad.item.setBtn("添加",config.btnTypeshowFace)
                }
            }

            Loader{
                id: dynamicdetectionLoad
                sourceComponent: btnCom
                Component.onCompleted: {
                    dynamicdetectionLoad.item.setBtn("动态检测",config.btnTypeDynamicshowFace)
                }
            }
        }
    }

    Component{
        id: btnCom
        LLSBUtton{
            id: faceshowBtn
            opacity: 0.8

            Connections{
                target: faceshowBtn
                onShowListClicked:{
                     if(btnType == config.btnTypeshowFace){
                         fileDialog.open()
                     }
                     else if(btnType == config.btnTypeDynamicshowFace){
                         if(faceshowBtn.btnState){
                              CameraManager.stopCamera()
                         }
                         else{
                              CameraManager.openCamera()
                         }
                         faceshowBtn.btnState = !faceshowBtn.btnState
                     }
                }
            }

            function setBtn(name,type){
                faceshowBtn.setBtnType(name,type)
            }

        }
    }

    Text {
         id: textTip
         anchors.horizontalCenter: parent.horizontalCenter
         anchors.bottom: parent.bottom
         anchors.bottomMargin: parent.height/4
         text: ""
         font.family: "Helvetica"
         font.pointSize: 15
         color: "red"
         visible: true
         opacity: 0

         PropertyAnimation{
             id: textTipAni
             target: textTip
             property: "opacity"
             from: 1.0
             to: 0
             duration: 5000
         }


         function setText(text){
             textTip.text = text;
         }

         function start(){
             textTipAni.stop()
             textTipAni.start()
         }
     }


    function doImgChoice(strpath,isAdd){
        var str = BaiduFaceManager.start(strpath)
        if(str == "-1"){
            console.log("=========================network_error===========================");
            textTip.setText("网络异常，请检查网络状态!");
            textTip.start()
        }
        else if(str !== "" && str !== "-1"){
            facePage.doJsonData(str,isAdd,strpath)
       }
    }


    Loader{
        id: preLoader
        anchors.fill: parent

       function setFaceRect(x1,y1,width1,height1,rotation1,jsonDetail){
           preLoader.item.setFaceRect(x1,y1,width1,height1,rotation1,jsonDetail)
       }
       function loadImg(imgPath){
           preLoader.item.loadImg(imgPath)
       }
    }

    Component{
        id: preViewCom
        Rectangle {
            id: preView
            anchors.fill: parent
            color: "#424242"

            Image {
                id: priImg
                anchors.centerIn: parent

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    preLoader.sourceComponent = undefined
                }
               }
             }

            function setFaceRect(x1,y1,width1,height1,rotation1,jsonDetail){

                var obj = rectFace.createObject(priImg)
                obj.visible = true
                obj.x = x1
                obj.y = y1
                obj.width = width1
                obj.height = height1
                obj.rotation = rotation1

                obj.setDetail(jsonDetail)
            }


            function loadImg(imgPath){
                priImg.source = imgPath
            }
        }
    }

    Component{
        id: imShow
        Image {
            id: imgshowDelete
            width: 150
            height: 150
            property string imgPath: ""

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    mainroot.doImgChoice(imgshowDelete.imgPath,false)
                }
            }
            Component.onCompleted: {
//                    imgshowDelete.source = "qrc:/skin/photo_error.png"
            }
            function setImage(imgpath){
                imgPath = imgpath
                imgshowDelete.source = imgpath
            }
        }
    }

    Component{
        id: rectFace
        Rectangle{
            id: rectFaceRec
            x: 0
            y: 0
            transformOrigin: Item.TopLeft
            color: "transparent"
            border.color: "red"
            border.width: 1
            width: 0
            height: 0
            rotation: 0
            visible: false

            Item{
                id: imgDetail
                anchors.right: rectFaceRec.right
                anchors.top: rectFaceRec.top
                width: rectFaceRec.width
                height:imgListDetial.implicitHeight
                opacity: 0.6
//                color: "#808080"

                ListView{
                    id: imgListDetial
                    width: imgDetail.width
                    implicitHeight:30* count + 10*count
                    orientation: ListView.Vertical
                    spacing: 10
                    model: listModel2
                    delegate: Item{
                        width: imgDetail.width
                        height: 30
                        Row{
                            anchors.fill: parent
                            anchors.topMargin: 10
                            Text {
                                color: "red"
                                font.pixelSize: 18
                                font.family: "微软雅黑"
                                text: name + ":"
                            }
                            Text {
                                color: "red"
                                font.pixelSize: 18
                                font.family: "微软雅黑"
                                text: value
                            }
                        }
                    }
                }

                ListModel{
                    id: listModel2

                    function addItem(str1,str2){

                        listModel2.append({name: str1,value: str2})
                    }
                }
            }

            function setDetail(data){
                listModel2.addItem("age",data.age)
//                listModel2.addItem("face_probability",data.face_probability)
            }


        }
    }

    Connections{
        target: CameraManager
        onSigSendImgUpdate:{
                pre.source = "image://CodeImage/yellow"+ Math.random()
        }

    }

    function doChoiceImg(img){

        var path = qsTr(img.toString())
        if(path == "") return
        var obj = imShow.createObject(imgShow);
        console.log("=================================" + path)
        obj.setImage(path)
    }

    function doJsonData(str,isAdd,imgpath){

        var obj = JSON.parse(str)
        if(obj.error_code == 0){

            preLoader.sourceComponent = preViewCom;
            preLoader.loadImg(imgpath)

            var arrrayList = obj.result.face_list;
            for(var i = 0;i<arrrayList.length;i++){
                var data = arrrayList[i]
                if(data.hasOwnProperty("face_probability")){
                    if(data.hasOwnProperty("location")){
                        var rect = data.location
                        var jsonDetail = {"age": data.age,"face_probability":data.face_probability}

                        preLoader.setFaceRect(rect.left,rect.top,rect.width,rect.height,rect.rotation,jsonDetail)
                        //preView.setFaceRect(rect.left,rect.top,rect.width,rect.height,rect.rotation,jsonDetail)

                    }
                }
            }

           if(isAdd){
              doChoiceImg(fileDialog.fileUrl,isAdd)
           }

        }
        else{
            console.log("=========================pic_error===========================");
            textTip.setText("请导入正确人脸!");
            textTip.start()
            return;
            //不是人物图像
        }

    }
}
