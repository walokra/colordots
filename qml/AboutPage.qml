/*
 * Copyright 2014 Marko Wallin
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 3 as published by the
 * Free Software Foundation. See http://www.gnu.org/copyleft/gpl.html the full
 * text of the license.
 */

import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: aboutPage;

    SilicaFlickable {
        id: flickable;

        anchors.fill: parent;
        contentHeight: contentArea.height + 2 * Theme.paddingLarge;

        PageHeader {
            id: header;
            title: qsTr("About Colordots");
        }

        Column {
            id: contentArea;
            anchors { top: header.bottom; left: parent.left; right: parent.right }
            height: childrenRect.height;

            anchors.leftMargin: Theme.paddingMedium;
            anchors.rightMargin: Theme.paddingMedium;
            spacing: Theme.paddingMedium;

            Item {
                anchors { left: parent.left; right: parent.right; }
                height: aboutText.height;

                Label {
                    id: aboutText;
                    width: parent.width;
                    wrapMode: Text.Wrap;
                    font.pixelSize: Theme.fontSizeMedium;
                    textFormat: Text.StyledText
                    linkColor: Theme.highlightColor
                    onLinkActivated: Qt.openUrlExternally(link);
                    text: qsTr("Colordots is a game of connecting. Link as many dots as you can in thirty moves. Connect one dot to another, connect four dots to make a square. Ported from Dotty which is written for Ubuntu Phone by Robert Ancell. Similar to Dots game for Android/iOS.")
                }
            }

            SectionHeader { text: qsTr("Version") }

            Item {
                anchors { left: parent.left; right: parent.right; }
                height: versionText.height;

                Label {
                    id: versionText;
                    width: parent.width;
                    font.pixelSize: Theme.fontSizeMedium;
                    wrapMode: Text.Wrap;
                    text: APP_VERSION + "-" + APP_RELEASE;
                }
            }

            SectionHeader { text: qsTr("Developed By"); }

            ListItem {
                id: root;

                Image {
                    id: rotImage;
                    source: "images/rot_tr_86x86.png";
                    width: 86;
                    height: 86;
                }
                Label {
                    anchors { left: rotImage.right; leftMargin: Theme.paddingLarge;}
                    text: "Marko Wallin, @walokra"
                    font.pixelSize: Theme.fontSizeLarge
                }
            }

            Label {
                anchors { right: parent.right; rightMargin: Theme.paddingLarge; }
                textFormat: Text.StyledText;
                linkColor: Theme.highlightColor;
                font.pixelSize: Theme.fontSizeSmall;
                truncationMode: TruncationMode.Fade;
                text: qsTr("Bug reports") + ": " + "<a href='https://github.com/walokra/colordots/issues'>Github</a>";
                onLinkActivated: Qt.openUrlExternally(link);
            }

            SectionHeader { text: qsTr("Powered By") }

            ListItem {
                Image {
                    id: qtImage;
                    source: "images/qt_icon.png";
                    width: 80;
                    height: 80;
                }
                Label {
                    anchors { left: qtImage.right; leftMargin: Theme.paddingLarge; }
                    text: "Qt + QML";
                    font.pixelSize: Theme.fontSizeLarge;
                }
            }
        }

        VerticalScrollDecorator { flickable: flickable }
    }

}
