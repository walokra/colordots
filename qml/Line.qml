/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 3 as published by the
 * Free Software Foundation. See http://www.gnu.org/copyleft/gpl.html the full
 * text of the license.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    property real x1
    property real y1

    property real x2
    property real y2

    color: "#4e9a06"
    height: Theme.itemSizeExtraSmall;
    antialiasing: true

    transformOrigin: Item.Left

    x: x1
    y: y1 - height / 2
    width: {
        return Math.sqrt (Math.pow ((x2 - x1), 2) + Math.pow ((y2 - y1), 2))
    }

    rotation: {
        var a, m, d
        var b = x2 - x1
        if (b === 0) {
            if (y2 > y1)
                return 90
            else
                return 270
        }
        a = y2 - y1
        m = a / b
        d = Math.atan (m) * 180 / Math.PI

        if (a < 0 && b < 0)
            return d + 180
        else if (a >= 0 && b>=0)
            return d
        else if (a < 0 && b >= 0)
            return d
        else if (a >= 0 && b < 0)
            return d + 180
        else
            return 0
    }
}
