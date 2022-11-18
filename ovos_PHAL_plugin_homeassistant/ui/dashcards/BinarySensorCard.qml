import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import QtGraphicalEffects 1.0
import "../code/helper.js" as HelperJS

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true
    property var device: modelData
    property bool isOn: device.state === "on" ? true : false

    Rectangle {
        id: sensorTemplateDashboardCard
        height: Mycroft.Units.gridUnit * 6
        width: parent.width - Mycroft.Units.gridUnit / 2        
        anchors.centerIn: parent
        radius: 10
        border.color: (HelperJS.isLight(Kirigami.Theme.backgroundColor) ? Qt.lighter(Kirigami.Theme.backgroundColor, 3) : Qt.darker(Kirigami.Theme.backgroundColor, 3))
        border.width: 1
        color: isOn ? Kirigami.Theme.highlightColor : HelperJS.isLight(Kirigami.Theme.backgroundColor) ? Qt.darker(Kirigami.Theme.backgroundColor, 1.5) : Qt.lighter(Kirigami.Theme.backgroundColor, 1.5) 

        Label {
            id: sensorName
            anchors.fill: parent
            text: device.state.toUpperCase()
            font.pixelSize: 20
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            color: Kirigami.Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}