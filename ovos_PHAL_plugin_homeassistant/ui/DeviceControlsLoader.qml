import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import QtGraphicalEffects 1.0
import "code/helper.js" as HelperJS

Rectangle {
    id: deviceControlsLoader
    property var device
    property var createdControlsList: []
    property var createdToolsList: []
    property bool createdControlsEnabled: true
    property bool horizontalMode
    property bool opened: false
    property var mediaModel

    width: parent.width * 0.8
    height: parent.height * 0.8
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    visible: opened
    enabled: opened
    
    color: Kirigami.Theme.backgroundColor
    radius: Mycroft.Units.gridUnit
    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.4)
    border.width: Mycroft.Units.gridUnit / 4

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
    }

    Keys.onEscapePressed: {
        deviceControlsLoader.closeSheet()
    }

    function updateSheet(device) {
        deviceControlsLoader.device = device;
    }

    function openSheet(device) {
        deviceControlsLoader.forceActiveFocus()
        deviceControlsLoader.device = device

        if(!deviceControlsLoader.opened) {
            deviceControlsLoader.opened = true;
            console.log("Opening device controls for " + device.type)
            
            // Add Header Tool
            if (device.type == "light") {
                var lightHeaderStateButtonComponent = Qt.createComponent("devicecontrols/LightDeviceStateButton.qml");
                var lightHeaderStateControl = lightHeaderStateButtonComponent.createObject(deviceSheetHeaderToolbarArea);
                createdToolsList.push(lightHeaderStateControl);

                if(device.state == "on") {
                    createdControlsEnabled = true;
                }
            }

            // Add Controls
            if (device.type === "light" && device.attributes.brightness) {
                var lightBrightnessComponent = Qt.createComponent("devicecontrols/LightBrightness.qml")
                var lightBrightnessControl = lightBrightnessComponent.createObject(deviceControlsItemAreaLayout)
                createdControlsList.push(lightBrightnessControl)
            }
            
            if (device.type === "light" && device.attributes.rgb_color) {
                var lightColorComponent = Qt.createComponent("devicecontrols/LightColor.qml")
                var lightColorControl = lightColorComponent.createObject(deviceControlsItemAreaLayout)
                createdControlsList.push(lightColorControl)
            }

            if (device.type === "media_player") {
                var mediaPlayerLocalMediaComponent = Qt.createComponent("devicecontrols/LocalMediaControl.qml")
                var mediaPlayerLocalMediaControl = mediaPlayerLocalMediaComponent.createObject(deviceControlsItemAreaLayout)
                createdControlsList.push(mediaPlayerLocalMediaControl)
            }
        }
    }
    
    function closeSheet(){

        createdControlsList.forEach(function(control) {
            control.destroy();
        });
        createdControlsList = [];

        createdToolsList.forEach(function(tool) {
            tool.destroy();
        });
        createdToolsList = [];

        deviceControlsLoader.device = ""
        deviceControlsLoader.opened = false
    }

    Item {
        id: deviceControlsItemContentArea
        anchors.fill: parent
        anchors.margins: Mycroft.Units.gridUnit / 2

        Rectangle {
            id: deviceSheetHeaderArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Mycroft.Units.gridUnit * 3
            radius: 6
            color: HelperJS.isLight(Kirigami.Theme.backgroundColor) ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.5) : Qt.darker(Kirigami.Theme.backgroundColor, 1.5)

            Label {
                id: deviceSheetHeaderAreaLabel
                text: deviceControlsLoader.device.name
                font.pixelSize: Mycroft.Units.gridUnit * 1.5
                color: Kirigami.Theme.textColor
                anchors.left: parent.left
                anchors.leftMargin: Mycroft.Units.gridUnit / 2
                anchors.verticalCenter: parent.verticalCenter
                width: deviceSheetHeaderAreaLabel.implicitWidth
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Kirigami.Separator {
                id: deviceSheetHeaderAreaSeparatorOne
                anchors.left: deviceSheetHeaderAreaLabel.right
                anchors.leftMargin: Mycroft.Units.gridUnit / 2
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: Mycroft.Units.gridUnit * 1.5
            }

            RowLayout {
                id: deviceSheetHeaderToolbarArea
                anchors.left: deviceSheetHeaderAreaSeparatorOne.right
                anchors.leftMargin: Mycroft.Units.gridUnit / 2
                anchors.right: deviceSheetHeaderAreaSeparatorTwo.left
                anchors.rightMargin: Mycroft.Units.gridUnit / 2
                anchors.verticalCenter: parent.verticalCenter
            }

            Kirigami.Separator {
                id: deviceSheetHeaderAreaSeparatorTwo
                anchors.right: deviceSheetHeaderCloseButton.left
                anchors.rightMargin: Mycroft.Units.gridUnit / 2
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: Mycroft.Units.gridUnit * 1.5
            }

            Button {
                id: deviceSheetHeaderCloseButton
                icon.name: "dialog-close"
                anchors.right: parent.right
                anchors.rightMargin: Mycroft.Units.gridUnit / 2
                anchors.verticalCenter: parent.verticalCenter

                onClicked: {
                    deviceControlsLoader.closeSheet()
                }
            }

            Kirigami.Separator {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
            }
        }
        
        Item {
            anchors.top: deviceSheetHeaderArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Mycroft.Units.gridUnit * 0.5

            GridLayout {
                id: deviceControlsItemAreaLayout
                height: parent.height
                width: parent.width
                columns: horizontalMode ? 2 : 1
                enabled: createdControlsEnabled
                opacity: createdControlsEnabled ? 1 : 0.5
            }
        }
    }
}

