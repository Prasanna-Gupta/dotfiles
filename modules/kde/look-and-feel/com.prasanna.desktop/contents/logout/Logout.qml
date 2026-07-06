/*
 * Prasanna OS - Custom Logout Screen
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents
import org.kde.coreaddons as KCoreAddons
import org.kde.kirigami as Kirigami
import org.kde.breeze.components
import "timer.js" as AutoTriggerTimer
import org.kde.plasma.private.sessions
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Item {
    id: root
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    height: screenGeometry.height
    width: screenGeometry.width

    signal logoutRequested()
    signal haltRequested()
    signal haltUpdateRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal rebootUpdateRequested()
    signal cancelRequested()
    signal lockScreenRequested()
    signal cancelSoftwareUpdateRequested()

    function sleepRequested() { root.suspendRequested(2); }
    function hibernateRequested() { root.suspendRequested(4); }

    property real timeout: 30
    property real remainingTime: root.timeout
    property var currentAction: {
        switch (sdtype) {
        case ShutdownType.ShutdownTypeReboot:
            return () => softwareUpdatePending ? rebootUpdateRequested() : rebootRequested();
        case ShutdownType.ShutdownTypeHalt:
            return () => softwareUpdatePending ? haltUpdateRequested() : haltRequested();
        default:
            return () => logoutRequested();
        }
    }
    readonly property bool showAllOptions: sdtype === ShutdownType.ShutdownTypeDefault

    KCoreAddons.KUser { id: kuser }

    SessionsModel {
        id: otherSessionsModel
        includeUnusedSessions: false
        includeOwnSession: false
    }

    QQC2.Action {
        onTriggered: root.cancelRequested()
        shortcut: "Escape"
    }

    onRemainingTimeChanged: {
        if (remainingTime <= 0) { (currentAction)(); }
    }

    Timer {
        id: countDownTimer
        running: !showAllOptions
        repeat: true
        interval: 1000
        onTriggered: remainingTime--
        Component.onCompleted: {
            AutoTriggerTimer.addCancelAutoTriggerCallback(function() {
                countDownTimer.running = false;
            });
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#0a0a0a"
        opacity: 0.92
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelRequested()
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Kirigami.Units.gridUnit * 2

        // Avatar — circular pre-cropped PNG
        Item {
            Layout.alignment: Qt.AlignHCenter
            width: Kirigami.Units.gridUnit * 7
            height: Kirigami.Units.gridUnit * 7

            Image {
                anchors.fill: parent
                source: kuser.faceIconUrl
                fillMode: Image.PreserveAspectFit
                smooth: true
                antialiasing: true
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 2
                border.color: "#44ffffff"
            }
        }

        // Username
        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 8
            font.weight: Font.Medium
            text: kuser.fullName
            textFormat: Text.PlainText
            color: "#FFFFFF"
        }

        // Countdown
        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: Kirigami.Theme.defaultFont.pointSize
            opacity: countDownTimer.running ? 0.6 : 0
            font.italic: true
            color: "#FFFFFF"
            text: {
                switch (sdtype) {
                    case ShutdownType.ShutdownTypeReboot:
                        return i18ndp("plasma_lookandfeel_org.kde.lookandfeel",
                            "Restarting in 1 second", "Restarting in %1 seconds", root.remainingTime);
                    case ShutdownType.ShutdownTypeNone:
                        return i18ndp("plasma_lookandfeel_org.kde.lookandfeel",
                            "Logging out in 1 second", "Logging out in %1 seconds", root.remainingTime);
                    default:
                        return i18ndp("plasma_lookandfeel_org.kde.lookandfeel",
                            "Shutting down in 1 second", "Shutting down in %1 seconds", root.remainingTime);
                }
            }
            textFormat: Text.PlainText
        }

        // Action buttons
        GridLayout {
            id: logoutButtonsRow
            Layout.alignment: Qt.AlignHCenter

            readonly property int spacing: Kirigami.Units.gridUnit * 1.5
            rowSpacing: spacing
            columnSpacing: spacing

            readonly property int buttonCount: visibleChildren.length
            readonly property int singleRowWidth: (children[0].implicitWidth * buttonCount) + (spacing * (buttonCount - 1))
            columns: singleRowWidth < root.width ? buttonCount : Math.ceil(buttonCount / 2)

            LogoutButton {
                icon.name: "system-suspend-symbolic"
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Suspend to RAM", "Slee&p")
                onClicked: root.sleepRequested()
                visible: spdMethods.SuspendState && root.showAllOptions
            }
            LogoutButton {
                icon.name: "system-suspend-hibernate-symbolic"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "&Hibernate")
                onClicked: root.hibernateRequested()
                visible: spdMethods.HibernateState && root.showAllOptions
            }
            LogoutButton {
                icon.name: "system-reboot-symbolic"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "&Restart")
                onClicked: root.rebootRequested()
                focus: sdtype === ShutdownType.ShutdownTypeReboot
                visible: maysd && (sdtype === ShutdownType.ShutdownTypeReboot || root.showAllOptions)
            }
            LogoutButton {
                icon.name: "system-shutdown-symbolic"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "&Shut Down")
                onClicked: root.haltRequested()
                focus: sdtype === ShutdownType.ShutdownTypeHalt || root.showAllOptions
                visible: maysd && (sdtype === ShutdownType.ShutdownTypeHalt || root.showAllOptions)
            }
            LogoutButton {
                icon.name: "system-log-out-symbolic"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "&Log Out")
                onClicked: root.logoutRequested()
                focus: sdtype === ShutdownType.ShutdownTypeNone
                visible: canLogout && (sdtype === ShutdownType.ShutdownTypeNone || root.showAllOptions)
            }
            LogoutButton {
                icon.name: "window-close-symbolic"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "&Cancel")
                onClicked: root.cancelRequested()
            }
        }
    }
}
