import QtQuick 2.0
import Sailfish.Silica 1.0
import "storage.js" as Storage

Dialog {
    id: root;

    SilicaFlickable {
        id: settingsFlickable

        anchors.fill: parent

        contentHeight: contentArea.height

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }

        DialogHeader {
            id: header
            title: qsTr("Settings")
            acceptText: qsTr("Save")
        }

        Column {
            id: contentArea
            anchors { top: header.bottom; left: parent.left; right: parent.right }
            width: parent.width
            height: childrenRect.height
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium

            TextSwitch {
                anchors {left: parent.left; right: parent.right }
                text: qsTr("Use shapes and colors")
                checked: use_shapes
                onClicked: {
                    checked ? use_shapes = true : use_shapes = false
                }
            }
            Label {
                anchors {left: parent.left; right: parent.right }
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Dots have both shape and color.")
            }
        }

        VerticalScrollDecorator { flickable: settingsFlickable }
    }

    onAccepted: {
        Storage.writeSetting("use_shapes", use_shapes)
    }

    Component.onCompleted: {
        use_shapes = Storage.readSetting("use_shapes")
    }
}
