import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import QtGraphicalEffects 1.0

Item {
    id: sensorTemplateDashboardCard
    property var device: modelData
    property bool validState: device.state !== "unknown" || device.state !== "unavailable" ? 1 : 0
    property var unitType
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    Component.onCompleted: {
        get_unit_type()
    }    

    function get_unit_type(){
        if(device.attributes.unit_of_measurement == "%") {
            unitType = "percentage"
        } else if (device.attributes.unit_of_measurement == "KWh") {
            unitType = "power"
        } else if (device.attributes.unit_of_measurement == "W") {
            unitType = "power"
        } else if (device.attributes.unit_of_measurement == "kWh") {
            unitType = "power"
        } else if (device.attributes.unit_of_measurement == "Wh") {
            unitType = "power"
        } else if (device.attributes.unit_of_measurement == "kW") {
            unitType = "power"
        }
        else {
            unitType = "undefined"
        }
    }

    Label {
        id: sensorName
        anchors.fill: parent
        visible: validState && sensorTemplateDashboardCard.unitType == "undefined" ? 1 : 0
        enabled: validState && sensorTemplateDashboardCard.unitType == "undefined" ? 1 : 0
        text: device.attributes.unit_of_measurement ? device.state + " " + device.attributes.unit_of_measurement : device.state
        font.pixelSize: 20
        fontSizeMode: Text.Fit
        minimumPixelSize: 10
        color: Kirigami.Theme.highlightColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    CircleSensorItemPercentType {
        id: sensorGraphicPercentStyle
        anchors.centerIn: parent
        width: parent.width < parent.height ? parent.width * 0.8 : parent.height * 0.8
        height: parent.width < parent.height ? parent.width * 0.8 : parent.height * 0.8
        visible: validState && sensorTemplateDashboardCard.unitType == "percentage" ? 1 : 0
        enabled: validState && sensorTemplateDashboardCard.unitType == "percentage" ? 1 : 0
        value: device.state / 100
    }

    PowerSensorItemType {
        id: sensorGraphicPowerStyle
        anchors.fill: parent
        visible: validState && sensorTemplateDashboardCard.unitType == "power" ? 1 : 0
        enabled: validState && sensorTemplateDashboardCard.unitType == "power" ? 1 : 0
        text: device.attributes.unit_of_measurement ? device.state + " " + device.attributes.unit_of_measurement : device.state
    }
}