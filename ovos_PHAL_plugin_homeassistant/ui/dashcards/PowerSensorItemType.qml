import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import QtGraphicalEffects 1.0
import "../code/helper.js" as HelperJS

Item {
    id: powerSensorItem
    property var text
    
    RowLayout {
        anchors.centerIn: parent

        Kirigami.Icon {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignVCenter
            source: Qt.resolvedUrl("../icons/power.svg")

            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: Kirigami.Theme.highlightColor
            }
        }

        Kirigami.Heading {
            level: 2
            Layout.fillHeight: true          
            wrapMode: Text.WordWrap
            font.bold: true
            color: Kirigami.Theme.textColor
            text: powerSensorItem.text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }
    }
}