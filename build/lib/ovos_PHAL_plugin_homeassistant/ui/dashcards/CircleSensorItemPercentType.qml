import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import QtGraphicalEffects 1.0
import "../code/helper.js" as HelperJS

Item {
    id: circleSensorItem
    property var value

    // Custom progress Indicator
    Item {
        anchors.fill: parent
        anchors.margins: 5

        Rectangle{
            id: mask
            anchors.fill: parent
            radius: width / 2
            color: HelperJS.isLight(Kirigami.Theme.backgroundColor) ? Qt.darker(Kirigami.Theme.backgroundColor, 1.5) : Qt.lighter(Kirigami.Theme.backgroundColor, 1.5)
            border.width: 5
            border.color: Kirigami.Theme.backgroundColor
        }

        Item {
            anchors.fill: mask
            anchors.margins: 5
            layer.enabled: true
            rotation: 180
            layer.effect: OpacityMask {
                maskSource: mask
            }
            Rectangle {
                height: parent.height * circleSensorItem.value 
                width: parent.width
                color: Kirigami.Theme.highlightColor
            }
        }

        Label {
            anchors.centerIn: parent
            color: Kirigami.Theme.textColor
            font.bold: true
            fontSizeMode: Text.Fit
            font.pixelSize: 30
            minimumPixelSize: 10
            text: Number(circleSensorItem.value * 100).toFixed() + "%"
        }
    }
}