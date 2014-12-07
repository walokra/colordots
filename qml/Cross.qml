/*
 * Copyright 2014 Marko Wallin.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 3 as published by the
 * Free Software Foundation. See http://www.gnu.org/copyleft/gpl.html the full
 * text of the license.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    width: Theme.itemSizeSmall / 2;
    property int x_coord
    property int y_coord
    property real cx
    property real cy
    x: cx - width / 2
    y: cy - height / 2
    height: width / 2
    color: "#4e9a06"

    Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.OutBounce; easing.amplitude: 0.5; } }

    Rectangle {
        width: parent.width
        height: parent.height
        rotation: 90
        antialiasing: true
        color: parent.color
    }
}
