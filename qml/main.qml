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

ApplicationWindow {
    id: main;

    property int n_moves: 30
    property int n_cleared: 0

    property bool use_shapes: false;

    cover: coverPage;

    initialPage: Component {
        id: mainPage;

        MainPage {
            id: mp;
        }
    }

    CoverPage { id: coverPage }

    SettingsDialog { id: settingsDialog }

}
