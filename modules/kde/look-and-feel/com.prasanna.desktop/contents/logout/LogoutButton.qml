import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.AbstractButton {
    id: root

    Layout.alignment: Qt.AlignTop
    implicitWidth: Kirigami.Units.gridUnit * 6
    implicitHeight: circle.height + label.implicitHeight + Kirigami.Units.smallSpacing

    opacity: hovered ? 1.0 : 0.75
    Behavior on opacity { OpacityAnimator { duration: 150 } }

    readonly property string iconDir: Qt.resolvedUrl("icons/")
    readonly property string iconFile: iconDir + root.icon.name + ".svg"

    contentItem: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            id: circle
            Layout.alignment: Qt.AlignHCenter
            width: Kirigami.Units.gridUnit * 4
            height: width
            radius: width / 2
            color: root.hovered ? "#44ffffff" : "#22ffffff"
            Behavior on color { ColorAnimation { duration: 150 } }

            Image {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.medium
                height: width
                source: root.iconFile
                fillMode: Image.PreserveAspectFit
                smooth: true
                sourceSize: Qt.size(width * 2, height * 2)
            }

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.width: 1
                border.color: "#33ffffff"
            }
        }

        Text {
            id: label
            Layout.alignment: Qt.AlignHCenter
            color: "#CCFFFFFF"
            font.pointSize: Kirigami.Theme.defaultFont.pointSize - 1
            horizontalAlignment: Text.AlignHCenter
            text: root.text.replace(/&([A-Za-z])/, "$1")
        }
    }

    background: Item {}
}
