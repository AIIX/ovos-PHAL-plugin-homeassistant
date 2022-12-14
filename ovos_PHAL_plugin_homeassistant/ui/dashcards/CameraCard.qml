import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import QtGraphicalEffects 1.0
import "../code/helper.js" as HelperJS

Item {
    id: cameraTemplateDashboardCard
    property var device: modelData
    Layout.fillWidth: true
    Layout.fillHeight: true
    property bool isStreaming: false
    property var streamingLink: device.host + "/api/camera_proxy_stream/" + device.id + "?token=" + device.attributes.access_token
    property var imageLink: device.host + device.attributes.entity_picture

    onDeviceChanged: {
        if(device.host.startsWith("ws://") || device.host.startsWith("wss://")) {
            cameraTemplateDashboardCard.streamingLink = device.host.replace("ws://", "http://").replace("wss://", "https://") + "/api/camera_proxy_stream/" + device.id + "?token=" + device.attributes.access_token
            cameraTemplateDashboardCard.imageLink = device.host.replace("ws://", "http://").replace("wss://", "https://") + device.attributes.entity_picture
        }        
    }

    Image {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: playPauseCameraStreamButton.top
        source: cameraTemplateDashboardCard.imageLink
        visible: !cameraTemplateDashboardCard.isStreaming
        enabled: !cameraTemplateDashboardCard.isStreaming
    }

    Video {
        id: cameraCardVideo
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: playPauseCameraStreamButton.top
        source: cameraTemplateDashboardCard.streamingLink
        visible: cameraTemplateDashboardCard.isStreaming
        enabled: cameraTemplateDashboardCard.isStreaming
        autoLoad: true

        onVisibleChanged: {
            if(!visible) {
                cameraCardVideo.stop()
            } else {
                cameraCardVideo.play()
            }
        }
    }

    Button {
        id: playPauseCameraStreamButton
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Mycroft.Units.gridUnit * 3

        background: Rectangle {
            id: cameraStreamButtonBackground
            color: cameraTemplateDashboardCard.isStreaming ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
        }

        contentItem: Item {
            Kirigami.Icon {
                anchors.centerIn: parent
                source : cameraTemplateDashboardCard.isStreaming ? "media-playback-stop" : "media-playback-start"
                width: Mycroft.Units.gridUnit * 1.5
                height: Mycroft.Units.gridUnit * 1.5
            }
        }

        onClicked: {
            if(!cameraTemplateDashboardCard.isStreaming) {
                cameraTemplateDashboardCard.isStreaming = true
            } else {
                cameraTemplateDashboardCard.isStreaming = false
            }
        }

        onPressed: {
            cameraStreamButtonBackground.opacity = 0.5
        }

        onReleased: {
            cameraStreamButtonBackground.opacity = 1
        }
    }
}
