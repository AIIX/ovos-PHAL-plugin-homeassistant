import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import QtGraphicalEffects 1.0
import "../code/helper.js" as HelperJS

Rectangle {
    id: mediaplayerTemplateDashboardCard
    property var device: modelData
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 10
    property bool isOnline: device.state !== "off" && device.state !== "unknown" && device.state !== "unavailable" ? 1 : 0
    color: isOnline ? Kirigami.Theme.highlightColor : (HelperJS.isLight(Kirigami.Theme.backgroundColor) ? Qt.darker(Kirigami.Theme.backgroundColor, 1.5) : Qt.lighter(Kirigami.Theme.backgroundColor, 1.5))

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Mycroft.Units.gridUnit / 2

        Label {
            id: appName
            text: isOnline ? device.attributes.app_name : "Status: Device Offline"
            Layout.fillWidth: true       
            Layout.preferredHeight: Mycroft.Units.gridUnit * 4
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Mycroft.Units.gridUnit * 1.5
            color: isOnline ? Kirigami.Theme.textColor : Kirigami.Theme.highlightColor
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Button {
                id: powerButton
                Layout.alignment: Qt.AlignLeft            
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                Layout.preferredHeight: Kirigami.Units.iconSizes.huge            

                background: Rectangle {
                    color: "transparent"
                    radius: 100
                }

                contentItem: Kirigami.Icon {
                    source: "system-shutdown-symbolic"
                    width: width * 0.8
                    height: width * 0.8

                    ColorOverlay {
                        id: powerButtonOverlayColor
                        anchors.fill: parent
                        source: parent
                        color: Kirigami.Theme.textColor
                    }
                }

                onClicked: {
                    console.log(device.state)
                    if(device.state == "off") {
                        Mycroft.MycroftController.sendRequest("ovos.phal.plugin.homeassistant.device.turn_on", { "device_id": device.id })
                    }
                    else {
                        Mycroft.MycroftController.sendRequest("ovos.phal.plugin.homeassistant.device.turn_off", { "device_id": device.id })
                    }
                }

                onPressed: {
                    powerButtonOverlayColor.color = Qt.lighter(Kirigami.Theme.highlightColor, 1.5)
                }
                onReleased: {
                    powerButtonOverlayColor.color = Kirigami.Theme.textColor
                }
            }

            Button {
                id: previousButton
                Layout.alignment: Qt.AlignLeft            
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                visible: device.state == "playing" || device.state == "paused"
                enabled: device.state == "playing" || device.state == "paused"

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Kirigami.Icon {
                    source: "media-skip-backward-symbolic"
                    width: width * 0.8
                    height: width * 0.8

                    ColorOverlay {
                        id: previousButtonOverlayColor
                        anchors.fill: parent
                        source: parent
                        color: Kirigami.Theme.textColor
                    }
                }

                onClicked: {
                    Mycroft.MycroftController.sendRequest("ovos.phal.plugin.homeassistant.call.supported.function", { 
                        "device_id": device.id,
                        "function": "media_previous_track"
                    })
                }
                onPressed: {
                    previousButtonOverlayColor.color = Qt.lighter(Kirigami.Theme.highlightColor, 1.5)
                }
                onReleased: {
                    previousButtonOverlayColor.color = Kirigami.Theme.textColor
                }
            }

            Button {
                id: playButton
                Layout.alignment: Qt.AlignLeft            
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                visible: device.state == "playing" || device.state == "paused"  
                enabled: device.state == "playing" || device.state == "paused"          

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Kirigami.Icon {
                    source: device.state == "playing" ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"
                    width: width * 0.8
                    height: width * 0.8

                    ColorOverlay {
                        id: playButtonOverlayColor
                        anchors.fill: parent
                        source: parent
                        color: Kirigami.Theme.textColor
                    }
                }

                onClicked: {
                    if(device.state == "paused") {
                        Mycroft.MycroftController.sendRequest("ovos.phal.plugin.homeassistant.call.supported.function", {
                            "device_id": device.id,
                            "function_name": "play_media",
                            "function_args": {}
                        })
                    } else if(device.state == "playing") {
                        Mycroft.MycroftController.sendRequest("ovos.phal.plugin.homeassistant.call.supported.function", {
                            "device_id": device.id,
                            "function_name": "media_pause",
                            "function_args": {}
                        })
                    }
                }
                onPressed: {
                    playButtonOverlayColor.color = Qt.lighter(Kirigami.Theme.highlightColor, 1.5)
                }
                onReleased: {
                    playButtonOverlayColor.color = Kirigami.Theme.textColor
                }
            }

            Button {
                id: nextButton
                Layout.alignment: Qt.AlignLeft            
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                visible: device.state == "playing" || device.state == "paused"
                enabled: device.state == "playing" || device.state == "paused"      

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Kirigami.Icon {
                    source: "media-skip-forward-symbolic"
                    width: width * 0.8
                    height: width * 0.8

                    ColorOverlay {
                        id: nextButtonOverlayColor
                        anchors.fill: parent
                        source: parent
                        color: Kirigami.Theme.textColor
                    }
                }

                onClicked: {
                    Mycroft.MycroftController.sendRequest("ovos.phal.plugin.homeassistant.call.supported.function", { 
                        "device_id": device.id,
                        "function": "media_next_track"
                    })
                }
                onPressed: {
                    nextButtonOverlayColor.color = Qt.lighter(Kirigami.Theme.highlightColor, 1.5)
                }
                onReleased: {
                    nextButtonOverlayColor.color = Kirigami.Theme.textColor
                }
            }
        }

        Button {
            id: selectMediaButton
            Layout.fillWidth: true
            Layout.preferredHeight: Mycroft.Units.gridUnit * 3
            visible: false
            enabled: false

            background: Rectangle {
                id: selectMediaButtonBackground
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.gridUnit
            }

            SequentialAnimation {
                id: selectMediaButtonAnimation

                PropertyAnimation {
                    target: selectMediaButtonBackground
                    property: "color"
                    from: Kirigami.Theme.backgroundColor
                    to: Kirigami.Theme.highlightColor
                    duration: 100
                }

                PropertyAnimation {
                    target: selectMediaButtonBackground
                    property: "color"
                    from: Kirigami.Theme.highlightColor
                    to: Kirigami.Theme.backgroundColor
                    duration: 100
                }
            }

            contentItem: Item {
                RowLayout {
                    id: selectMediaButtonLayout
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft

                    spacing: Mycroft.Units.gridUnit

                    Kirigami.Icon {
                        source: "media-optical-symbolic"
                        width: Kirigami.Units.iconSizes.large
                        height: Kirigami.Units.iconSizes.large

                        ColorOverlay {
                            id: selectMediaButtonOverlayColor
                            anchors.fill: parent
                            source: parent
                            color: Kirigami.Theme.textColor
                        }
                    }

                    Label {
                        text: qsTr("Select Media")
                        color: Kirigami.Theme.textColor
                    }
                }
            }

            onPressed: {
                selectMediaButtonAnimation.running = true
            }
        }
    }
}