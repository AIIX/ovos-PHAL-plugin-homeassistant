import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import QtGraphicalEffects 1.0
import "delegates" as Delegates
import "code/helper.js" as HelperJS

Mycroft.Delegate {
    id: dashboardRoot
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    property var dashboardModel: sessionData.dashboardModel
    property var deviceDashboardModel: sessionData.deviceDashboardModel
    property bool instanceAvailable: sessionData.instanceAvailable
    property var tabBarModel
    property bool horizontalMode: width >= height ? true : false

    function get_page_name() {
       if (dashboardSwipeView.currentIndex == 0) {
           return "Dashboard"
       } else {
           return tabBarModel[bar.currentIndex].name
       }
    }

    function change_tab_to_type(type) {
        var index_of_type_in_tabBarModel = tabBarModel.findIndex(function(item) {
            return item.type == type
        })
        bar.currentIndex = index_of_type_in_tabBarModel
    }

    Timer {
        id: pollTimer
        interval: 3000
        repeat: true
        running: dashboardSwipeView.currentIndex > 0 ? 1 : 0
        onTriggered: {
            var dev_type = tabBarModel[bar.currentIndex].type
            if(dev_type != "main") {
                Mycroft.MycroftController.sendRequest("ovos.phal.plugin.homeassistant.update.device.dashboard", {"device_type": dev_type})
            }   
        }
    }

    Timer {
        id: delayTimer
    }

    function delay(delayTime, cb) {
        delayTimer.interval = delayTime;
        delayTimer.repeat = false;
        delayTimer.triggered.connect(cb);
        delayTimer.start();
    }

    onGuiEvent: {
        switch (eventName) {
            case "ovos.phal.plugin.homeassistant.change.dashboard":
                var requested_page = data.dash_type
                if (requested_page === "main") {
                    dashboardSwipeView.currentIndex = 0
                } else if (requested_page === "device") {
                    dashboardSwipeView.currentIndex = 1
                }
                break
            case "ovos.phal.plugin.homeassistant.integration.query_media.result":
                deviceControlsLoader.mediaModel = data.results
                console.log(JSON.stringify(data.results))
                break
        }
    }

    onDashboardModelChanged: {
        if (dashboardModel) {
            dashboardGridView.model = dashboardModel.items
            dashboardGridView.forceLayout();

            // Build the tab bar model
            var tabModel = [{"name": "Home", "type": "main"}]
            for (var i = 0; i < dashboardModel.items.length; i++) {
                var item = dashboardModel.items[i]
                tabModel.push({"name": item.name + "s", "type": item.type})   
            }
            tabBarModel = tabModel
        }
    }

    onDeviceDashboardModelChanged: {
        if (deviceDashboardModel) {
            devicesGridView.model = deviceDashboardModel.items

            if(dashboardSwipeView.currentIndex > 0) {
                pollTimer.restart()
            }
        }
    }

    background: Rectangle {
        color: HelperJS.isLight(Kirigami.Theme.backgroundColor) ? Qt.darker(Kirigami.Theme.backgroundColor, 1.5) : Qt.lighter(Kirigami.Theme.backgroundColor, 1.5)
    }

    Item {
        id: topBarArea
        height: Mycroft.Units.gridUnit * 3
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            id: pageTitleIconArea
            width: Mycroft.Units.gridUnit * 3
            anchors.top: parent.top
            anchors.bottom: topBarSeparator.top
            anchors.left: parent.left
            color: Kirigami.Theme.highlightColor

            Kirigami.Icon {
                id: pageTitleIcon
                anchors.centerIn: parent
                width: Mycroft.Units.gridUnit * 1.8
                height: Mycroft.Units.gridUnit * 1.8
                source: HelperJS.isLight(Kirigami.Theme.backgroundColor) ? Qt.resolvedUrl("icons/ha_icon_dark.svg") : Qt.resolvedUrl("icons/ha_icon_light.svg")
            }
        }
        
        Rectangle {
            id: pageTitleRect
            anchors.top: parent.top
            anchors.left: pageTitleIconArea.right
            anchors.leftMargin: Mycroft.Units.gridUnit * 1
            anchors.verticalCenter: parent.verticalCenter
            color: Kirigami.Theme.highlightColor
            width: pageTitle.implicitWidth + Mycroft.Units.gridUnit * 2
            height: Mycroft.Units.gridUnit * 2

            Label {
                id: pageTitle
                text: qsTr("Home Assistant") + " - " + get_page_name()
                font.pixelSize: Mycroft.Units.gridUnit * 1.5
                color: Kirigami.Theme.textColor
                anchors.fill: parent
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: topBarSeparator.top
            width: Mycroft.Units.gridUnit * 4
            color: Kirigami.Theme.highlightColor

            Kirigami.Icon {
                id: closeIcon
                anchors.centerIn: parent
                width: Mycroft.Units.gridUnit * 1.8
                height: Mycroft.Units.gridUnit * 1.8
                source: "window-close-symbolic"

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: Kirigami.Theme.textColor
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Mycroft.MycroftController.sendRequest("ovos-PHAL-plugin-homeassistant.close", {})
                }
            }
        }

        Kirigami.Separator {
            id: topBarSeparator
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: Kirigami.Theme.highlightColor
        }
    }

    Item {
        id: instanceSetupArea
        visible: !instanceAvailable
        enabled: !instanceAvailable
        anchors.top: topBarArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Kirigami.Icon {
            id: instanceSetupIcon
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -Mycroft.Units.gridUnit * 5
            anchors.horizontalCenter: parent.horizontalCenter
            width: Mycroft.Units.gridUnit * 5
            height: Mycroft.Units.gridUnit * 5
            source: HelperJS.isLight(Kirigami.Theme.backgroundColor) ? Qt.resolvedUrl("icons/ha_icon_dark.svg") : Qt.resolvedUrl("icons/ha_icon_light.svg")
        }

        Label {
            id: instanceSetupLabel
            text: qsTr("Home Assistant Instance Not Available")
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            elide: Text.ElideRight
            font.pixelSize: Mycroft.Units.gridUnit * 1.5
            color: Kirigami.Theme.textColor
            anchors.top: instanceSetupIcon.bottom
            anchors.topMargin: Mycroft.Units.gridUnit * 1
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Button {
            id: instanceSetupButton
            font.pixelSize: Mycroft.Units.gridUnit * 1.5
            anchors.top: instanceSetupLabel.bottom
            anchors.topMargin: Mycroft.Units.gridUnit * 1
            anchors.horizontalCenter: parent.horizontalCenter
            width: instanceSetupButtonLayout.implicitWidth + Mycroft.Units.gridUnit * 2
            height: Mycroft.Units.gridUnit * 4

            background: Rectangle {
                color: Kirigami.Theme.highlightColor
                radius: Mycroft.Units.gridUnit * 0.5
            }

            contentItem: Item {
                RowLayout {
                    id: instanceSetupButtonLayout
                    anchors.centerIn: parent

                    Kirigami.Icon {
                        id: instanceSetupButtonIcon
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        Layout.alignment: Qt.AlignVCenter
                        source: "network-connect"
                    }

                    Kirigami.Heading {
                        id: instanceSetupButtonText
                        level: 2
                        Layout.fillHeight: true          
                        wrapMode: Text.WordWrap
                        font.bold: true
                        elide: Text.ElideRight
                        color: Kirigami.Theme.textColor
                        text: qsTr("Connect Instance")
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }

            onClicked: {
                instaceSetupPopupBox.open()
            } 
        }
    }

    SwipeView {
        id: dashboardSwipeView
        currentIndex: 0
        anchors.top: topBarArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottomBarArea.top
        visible: instanceAvailable
        enabled: instanceAvailable
        interactive: false
        clip: false

        Item {
            id: mainDashboard

            Kirigami.CardsGridView {
                id: dashboardGridView
                anchors.fill: parent
                maximumColumns: horizontalMode ? 3 : 2
                cellHeight: Mycroft.Units.gridUnits * 5
                delegate: Delegates.DashboardDelegate {}
                clip: true
                ScrollBar.vertical: ScrollBar{
                    width: Mycroft.Units.gridUnit * 1.5
                    policy: dashboardGridView.count >= 6 ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                }
            }
        }
        
        Item {
            id: deviceDashboard

            Flickable {
                id: devicesDashboard
                anchors.fill: parent
                contentWidth: width
                contentHeight: deviceDashboardLayout.implicitHeight
                clip: true
                ScrollBar.vertical: ScrollBar{
                    width: Mycroft.Units.gridUnit * 1.5
                    policy: devicesGridView.count >= 6 ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                }

                GridLayout {
                    id: deviceDashboardLayout
                    anchors.fill: parent
                    columns: horizontalMode ? (width > 800 ? 3 : 2) : (width > 600 ? 2 : 1)
                    property int cellWidth: horizontalMode ? (width / columns - Kirigami.Units.largeSpacing * 2) : (width / columns - Kirigami.Units.largeSpacing * 2)
                    property int cellHeight: cellWidth - Kirigami.Units.largeSpacing * 3
                    columnSpacing: Kirigami.Units.largeSpacing
                    rowSpacing: Kirigami.Units.largeSpacing

                    Repeater {
                        id: devicesGridView
                        delegate: Delegates.DeviceDashboardDelegate {}
                    }
                }
            }
        }
    }

    Item {
        id: bottomBarArea
        height: Mycroft.Units.gridUnit * 3
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        
        Kirigami.Separator {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            color: Kirigami.Theme.highlightColor
        }

        TabBar {
            id: bar
            width: parent.width
            height: parent.height - Kirigami.Units.smallSpacing
            anchors.bottom: parent.bottom

            Repeater {
                model: tabBarModel
                delegate: TabButton {
                    text: modelData.name
                    width: parent.width / tabBarModel.count
                    height: parent.height
                    onClicked: {
                        if(modelData.type === "main") {
                            dashboardSwipeView.currentIndex = 0
                        } else {
                            Mycroft.MycroftController.sendRequest("ovos.phal.plugin.homeassistant.show.device.dashboard", {"device_type": modelData.type})
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: instaceSetupPopupBox
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: parent.width * 0.8
        height: parent.height * 0.8
        
        background: Rectangle {
            color: Qt.darker(Kirigami.Theme.backgroundColor, 1)
            radius: Mycroft.Units.gridUnit * 0.5
        }
        
        contentItem: Item {
            Item {
                anchors.fill: parent
                anchors.margins: Mycroft.Units.gridUnit

                Kirigami.Heading {
                    id: instanceSetupPopupTitle
                    level: 2
                    text: qsTr("Setup Home Assistant Instance")
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Mycroft.Units.gridUnit * 2
                }

                Kirigami.Separator {
                    anchors.top: instanceSetupPopupTitle.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Kirigami.Theme.highlightColor
                }
                
                Label {
                    id: instanceSetupPopupUrlLabel
                    text: qsTr("Home Assistant Instance URL")
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 10
                    elide: Text.ElideRight
                    font.pixelSize: Mycroft.Units.gridUnit * 1.5
                    color: Kirigami.Theme.textColor
                    anchors.top: instanceSetupPopupTitle.bottom
                    anchors.topMargin: Kirigami.Units.smallSpacing
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Mycroft.Units.gridUnit * 2
                }

                TextField {
                    id: instanceSetupPopupUrl
                    placeholderText: qsTr("http://homeassistant.local")
                    font.pixelSize: Mycroft.Units.gridUnit * 1.5
                    color: Kirigami.Theme.textColor
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: instanceSetupPopupUrlLabel.bottom
                    anchors.topMargin: Mycroft.Units.gridUnit * 0.5
                    height: Mycroft.Units.gridUnit * 3
                }

                Label {
                    id: instanceSetupPopupApiKeyLabel
                    text: qsTr("Home Assistant Instance API Key")
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 10
                    elide: Text.ElideRight
                    font.pixelSize: Mycroft.Units.gridUnit * 1.5
                    color: Kirigami.Theme.textColor
                    anchors.top: instanceSetupPopupUrl.bottom
                    anchors.topMargin: Kirigami.Units.smallSpacing
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Mycroft.Units.gridUnit * 2
                }

                TextField {
                    id: instanceSetupPopupApiKey
                    placeholderText: qsTr("API Key")
                    font.pixelSize: Mycroft.Units.gridUnit * 1.5
                    color: Kirigami.Theme.textColor
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: instanceSetupPopupApiKeyLabel.bottom
                    anchors.topMargin: Mycroft.Units.gridUnit * 0.5
                    height: Mycroft.Units.gridUnit * 3
                }

                RowLayout {
                    id: instanceSetupPopupButtons
                    anchors.top: instanceSetupPopupApiKey.bottom
                    anchors.topMargin: Kirigami.Units.smallSpacing
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Mycroft.Units.gridUnit * 3

                    Button {
                        id: instanceSetupPopupConfirmButton
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        background: Rectangle {
                            id: instanceSetupPopupConfirmButtonBackground
                            color: Kirigami.Theme.highlightColor
                            radius: Mycroft.Units.gridUnit * 0.5
                        }

                        contentItem: Item {
                            RowLayout {
                                id: instanceSetupPopupConfirmButtonLayout
                                anchors.centerIn: parent

                                Kirigami.Icon {
                                    id: instanceSetupPopupConfirmButtonIcon
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    Layout.alignment: Qt.AlignVCenter
                                    source: "answer-correct"

                                    ColorOverlay {
                                        anchors.fill: parent
                                        source: parent
                                        color: Kirigami.Theme.textColor
                                    }
                                }

                                Kirigami.Heading {
                                    id: instanceSetupPopupConfirmButtonText
                                    level: 2
                                    Layout.fillHeight: true          
                                    wrapMode: Text.WordWrap
                                    font.bold: true
                                    elide: Text.ElideRight
                                    color: Kirigami.Theme.textColor
                                    text: qsTr("Confirm")
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                }
                            }
                        }

                        onClicked: {
                            Mycroft.MycroftController.sendRequest("ovos.phal.plugin.homeassistant.setup.instance", {"url": instanceSetupPopupUrl.text, "api_key": instanceSetupPopupApiKey.text})
                            instaceSetupPopupBox.close()
                        }

                        onPressed: {
                            instanceSetupPopupConfirmButtonBackground.color = Qt.darker(Kirigami.Theme.highlightColor, 2)    
                        }
                        onReleased: {
                            instanceSetupPopupConfirmButtonBackground.color = Kirigami.Theme.highlightColor
                        } 
                    }

                    Button {
                        id: instanceSetupPopupCancelButton
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        background: Rectangle {
                            id: instanceSetupPopupCancelButtonBackground
                            color: Kirigami.Theme.highlightColor
                            radius: Mycroft.Units.gridUnit * 0.5
                        }

                        contentItem: Item {
                            RowLayout {
                                id: instanceSetupPopupCancelButtonLayout
                                anchors.centerIn: parent

                                Kirigami.Icon {
                                    id: instanceSetupPopupCancelButtonIcon
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    Layout.alignment: Qt.AlignVCenter
                                    source: "window-close-symbolic"

                                    ColorOverlay {
                                        anchors.fill: parent
                                        source: parent
                                        color: Kirigami.Theme.textColor
                                    }
                                }

                                Kirigami.Heading {
                                    id: instanceSetupPopupCancelButtonText
                                    level: 2
                                    Layout.fillHeight: true          
                                    wrapMode: Text.WordWrap
                                    font.bold: true
                                    elide: Text.ElideRight
                                    color: Kirigami.Theme.textColor
                                    text: qsTr("Cancel")
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                }
                            }
                        }

                        onClicked: {
                            instaceSetupPopupBox.close()
                        }

                        onPressed: {
                            instanceSetupPopupCancelButtonBackground.color = Qt.darker(Kirigami.Theme.highlightColor, 2)    
                        }
                        onReleased: {
                            instanceSetupPopupCancelButtonBackground.color = Kirigami.Theme.highlightColor
                        } 
                    }
                }
            }
        }
    }

    ItemDelegate {
        anchors.fill: parent
        visible: deviceControlsLoader.opened
        enabled: deviceControlsLoader.opened

        background: Rectangle {
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.9)
        }
        
        DeviceControlsLoader {
            id: deviceControlsLoader
            horizontalMode: dashboardRoot.horizontalMode
        }

        onClicked: {
            if(deviceControlsLoader.opened) {
                deviceControlsLoader.closeSheet()
            }
        }
    }
}
