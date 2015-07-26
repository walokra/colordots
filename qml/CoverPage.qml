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

CoverBackground {
    id: cover

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            if (play_mode === "default") {
            moves_label.text = main.n_moves
            score_label.text = main.n_cleared
            } else {
                moves_label.text = main.time_left
                score_label.text = main.n_cleared
            }
        }
    }

    Image {
	anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        source: "images/colordots-overlay.svg"
        opacity: 0.4
    }


    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.paddingSmall
        width: parent.width
        height: parent.height

        property var circle_size: Theme.itemSizeSmall
        property int circle_spacing: (width - circle_size * 2) / 3

        Rectangle {
            id: moves_circle
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingMedium
            x: parent.circle_spacing
            width: parent.circle_size
            height: parent.circle_size
            radius: width / 2
            color: "#ad7fa8"
	    opacity: 0.7
            Label {
                id: moves_label
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: height * 0.5
                color: "white"
            }
        }

        Rectangle {
            id: score_circle
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingMedium
            x: parent.width - parent.circle_spacing - width
            width: parent.circle_size
            height: parent.circle_size
            radius: width / 2
            color: "#ad7fa8"
	    opacity: 0.7
            Label {
                id: score_label
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: height * 0.5
                color: "white"
            }
        }

	Label {
	    anchors.horizontalCenter: parent.horizontalCenter
	    anchors.top: moves_circle.bottom
	    anchors.topMargin: 20
	    text: "Colordots"
	    font.bold: true
	}
    }

}


