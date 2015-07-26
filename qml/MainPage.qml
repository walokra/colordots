/*
 * Copyright 2014 Marko Wallin, adapted from code by 2013 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 3 as published by the
 * Free Software Foundation. See http://www.gnu.org/copyleft/gpl.html the full
 * text of the license.
 */

import QtQuick 2.1
import Sailfish.Silica 1.0
import "storage.js" as Storage

Page {
    id: root

    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        id: flickable
        z: 1

        height: header.height + statusRow.height + 2 * Theme.paddingMedium;
        width: parent.width;
        anchors { left: parent.left; right: parent.right; }

        PageHeader { id: header; title: "Colordots" }

        PullDownMenu {
            MenuItem {
                text: qsTr("Setting")
                onClicked: pageStack.push(settingsDialog)
            }

            MenuItem {
                text: qsTr("Scores")
                onClicked: actions.show_score()
            }

            MenuItem {
                text: qsTr("60 seconds game")
                onClicked: { play_mode = "time"; actions.start_game() }
            }

            MenuItem {
                text: qsTr("30 moves game")
                onClicked: { play_mode = "default"; actions.start_game() }
            }
        }

        Item {
            id: statusRow
            anchors { top: header.bottom; left: parent.left; right: parent.right; }

            property var circle_size: Theme.itemSizeMedium
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
                Label {
                    id: moves_label
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: height * 0.5
                    color: "white"
                }
            }
            Label {
                id: moves_desc_label
                anchors.top: moves_circle.bottom
                anchors.topMargin: Theme.paddingMedium
                anchors.horizontalCenter: moves_circle.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Moves Left")
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
                id: score_desc_label
                anchors.top: score_circle.bottom
                anchors.topMargin: Theme.paddingMedium
                anchors.horizontalCenter: score_circle.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Dots Cleared")
            }
        }
    }

    Timer {
        id: timer
        repeat: true
        interval: 1000
        onTriggered: {
            time_left--
            moves_label.text = time_left
            if (time_left === 0) {
                timer.stop()
                actions.end_game()
            }
        }
    }

    Item {
        id: gameArea
        anchors { top: flickable.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; }
        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutCubic } }

        Item {
            id: table
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom;}

            onWidthChanged: game.layout()
            onHeightChanged: game.layout()

            MouseArea {
                anchors.fill: parent
                onPressed: game.select(mouse.x, mouse.y)
                onPositionChanged: game.move_to(mouse.x, mouse.y)
                onReleased: {
                    if (play_mode !== "time" || time_left !== 0) {
                        game.complete()
                    }
                }
            }

            Component.onCompleted: {
                game.circle_component = Qt.createComponent("Dot.qml")
                game.rectangle_component = Qt.createComponent("Rectangle.qml")
                game.diamond_component = Qt.createComponent("Diamond.qml")
                game.star_component = Qt.createComponent("Star.qml")
                game.cross_component = Qt.createComponent("Cross.qml")
                game.line_component = Qt.createComponent("Line.qml")

                game.dots = new Array(6)
                for (var x = 0; x < 6; x++) {
                    game.dots[x] = new Array(6)
                }

                actions.start_game()
                game.layout()
            }
        }
    }

    Item {
        id: end_dialog
        anchors.fill: parent

        Rectangle {
            id: result_box
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 120
            height: width
            radius: width / 2
            scale: 0
            color: "#ad7fa8"
            MouseArea {
                anchors.fill: parent
                onClicked: actions.start_game()
            }
            Label {
                id: result_label
                anchors.fill: parent
                text: "999"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
                font.pixelSize: height * 0.5
                fontSizeMode: Text.HorizontalFit
                font.bold: true
            }

            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.InOutCubic } }
        }

        Label {
            id: score_history_label
            opacity: 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: result_box.bottom
            anchors.topMargin: Theme.paddingMedium;
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingMedium;
            horizontalAlignment: Text.AlignHCenter

            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.InOutCubic } }
        }
    }

    QtObject {
        id: game;

        property var colors: ["#ef2929", "#729fcf", "#8ae234", "#ad7fa8", "#fcaf3e"]
        property var dots
        property var selected_dots: []
        property var lines: []
        property var line_component
        property var circle_component
        property var rectangle_component
        property var diamond_component
        property var star_component
        property var cross_component
        property int spacing: 120
        property int dot_radius: 30
        property int line_width: 15
        property var color

        function fill() {
            // Add in new dots
            var new_dots = []
            for (var y = dots[1].length - 1; y >= 0; y--) {
                for (var x = 0; x < dots.length; x++) {
                    if (dots[x][y] !== undefined)
                        continue

                    // Drop down dot from above
                    var above_dot = undefined
                    for (var yy = y - 1; yy >= 0; yy--) {
                        if (dots[x][yy] !== undefined) {
                            above_dot = dots[x][yy]
                            dots[x][yy] = undefined
                            break
                        }
                    }

                    // If nothing above, create a new one
                    if (above_dot == undefined) {
                        color = get_random_color()
                        if (use_shapes) {
                            if (color === colors[0]) {
                                above_dot = circle_component.createObject(table)
                            } else if (color === colors[1]) {
                                above_dot = rectangle_component.createObject(table)
                            } else if (color === colors[2]) {
                                above_dot = diamond_component.createObject(table)
                            } else if (color === colors[3]) {
                                above_dot = star_component.createObject(table)
                            } else if (color === colors[4]) {
                                above_dot = cross_component.createObject(table)
                            } else {
                                above_dot = circle_component.createObject(table)
                            }
                        } else {
                            above_dot = circle_component.createObject(table)
                        }

                        new_dots[new_dots.length] = above_dot
                        above_dot.color = color
                    }

                    // Move dot down into empty space
                    above_dot.x_coord = x
                    above_dot.y_coord = y
                    place_dot(above_dot)
                    dots[x][y] = above_dot
                }
            }

            // If no there are no possible dots to link then make one of the new
            // dots match an adjacent one
            if (!can_link()) {
//                var new_dot = new_dots[Math.floor(Math.random() * new_dots.length)]
//                if (new_dot.y_coord === 0) {
//                    new_dot.color = dots[new_dot.x_coord][new_dot.y_coord + 1].color
//                } else {
//                    new_dot.color = dots[new_dot.x_coord][new_dot.y_coord - 1].color
//                }
                // If there's no dots to link, regenerate the field
                clear_field()
                fill()
            }
        }

        function can_link() {
            for (var x = 0; x < dots.length; x++)
                for (var y = 0; y < dots[0].length; y++) {
                    var c = dots[x][y].color
                    if (x > 0 && dots[x-1][y].color === c)
                        return true
                    if (x + 1 < dots.length && dots[x+1][y].color === c)
                        return true
                    if (y > 0 && dots[x][y-1].color === c)
                        return true
                    if (y + 1 < dots[0].length && dots[x][y+1].color === c)
                        return true
                }

            return false
        }

        function clear_selection() {
            for (var i = 0; i < lines.length; i++)
                lines[i].destroy()
            lines = []
            selected_dots = []
        }

        function clear_field() {
            for (var x = 0; x < game.dots.length; x++) {
                for (var y = 0; y < game.dots[0].length; y++) {
                    if (game.dots[x][y] !== undefined) {
                        game.dots[x][y].destroy()
                        game.dots[x][y] = undefined
                    }
                }
            }
        }

        function get_random_color() {
            return colors[Math.floor(Math.random() * colors.length)]
        }

        function get_nearest(x, y) {
            var nearest
            var d = -1
            for (var dx = 0; dx < dots.length; dx++) {
                for (var dy = 0; dy < dots[dx].length; dy++) {
                    var dot = dots[dx][dy]
                    var dd = Math.pow(x - dot.cx, 2) + Math.pow(y - dot.cy, 2)
                    if (dd < d || d < 0) {
                        d = dd
                        nearest = dot
                    }
                }
            }
            return nearest
        }

        function select(x, y) {
            if (play_mode === "default" && n_moves === 0) {
                return
            }
            if (play_mode === "time" && time_left === 0) {
                return
            }

            var line = line_component.createObject(table)
            var dot = get_nearest(x, y)
            line.x1 = dot.cx
            line.y1 = dot.cy
            line.x2 = line.x1
            line.y2 = line.y1
            line.color = dot.color
            line.height = line_width
            selected_dots.push(dot)
            lines.push(line)
        }

        function layout() {
            if (dots === undefined) {
                return
            }

            var size = Math.min(width, height)
            spacing = size / dots.length
            dot_radius = spacing / 4
            line_width = Math.round(dot_radius / 2)
            result_box.width = dot_radius * 10

            for (var x = 0; x < dots.length; x++)
                for (var y = 0; y < dots[0].length; y++)
                    place_dot(dots[x][y])
            for (var i = 0; i < lines.length; line++)
                lines[i].width = line_width
        }

        function place_dot(dot) {
            var x_offset = (width - (dots.length - 1) * spacing) / 2
            var y_offset = (height - (dots[0].length - 1) * spacing) / 2
            dot.cx = x_offset + dot.x_coord * spacing
            dot.cy = y_offset + dot.y_coord * spacing
            dot.width = dot_radius * 2
        }

        function move_to(x, y) {
            if (selected_dots.length === 0) {
                return
            }

            var last_dot = selected_dots[selected_dots.length - 1]
            var line = lines[lines.length - 1]

            // Get the dot we are nearest to
            var nearest = get_nearest(x, y)
            var d = Math.pow(last_dot.x_coord - nearest.x_coord, 2) + Math.pow(last_dot.y_coord - nearest.y_coord, 2)

            // If go back to previous dot then unselect
            if (selected_dots.length > 1 && nearest === selected_dots[selected_dots.length - 2]) {
                selected_dots.pop()
                line.destroy()
                lines.pop()
                line = lines[lines.length - 1]
            }
            // If go to new dot beside this one then extend line
            else if (nearest !== last_dot && nearest.color === last_dot.color && d == 1) {
                // If already had this dot selected, then made a loop!
                for (var i = 0; i < selected_dots.length; i++) {
                    if (selected_dots[i] === nearest) {
                        complete_loop()
                        return
                    }
                }

                // End line on this dot
                line.x2 = nearest.cx
                line.y2 = nearest.cy

                // Create a new line
                line = line_component.createObject(table)
                line.x1 = nearest.cx
                line.y1 = nearest.cy
                line.color = last_dot.color
                line.height = line_width

                selected_dots.push(nearest)
                lines.push(line)
            }

            line.x2 = x
            line.y2 = y
        }

        function complete() {
            if (selected_dots.length < 2) {
                clear_selection()
                return
            }

            n_moves--

            // Clear all the selected dots
            for (var i = 0; i < selected_dots.length; i++) {
                var dot = selected_dots[i]
                dots[dot.x_coord][dot.y_coord] = undefined
                dot.destroy()
                n_cleared++
            }
            clear_selection()

            game.fill()
            actions.update_labels()

            move_complete()
        }

        function complete_loop() {
            if (selected_dots.length < 2) {
                return
            }

            n_moves--

            // Clear all of that color
            var dot = selected_dots[0]
            for (var x = 0; x < dots.length; x++) {
                for (var y = 0; y < dots[0].length; y++) {
                    if (dots[x][y].color === dot.color) {
                        dots[x][y].destroy()
                        dots[x][y] = undefined
                        n_cleared++
                    }
                }
            }
            clear_selection()

            game.fill()
            actions.update_labels()

            move_complete()
        }

        function move_complete() {
            if (play_mode === "default" && n_moves == 0) {
                actions.end_game()
            }
        }
    }

    QtObject {
        id: actions;

        function start_game() {
            timer.stop()

            if (play_mode === "time") {
                moves_desc_label.text = qsTr("Seconds left")
                timer.start()
            } else {
                moves_desc_label.text = qsTr("Moves left")
            }

            time_left = 60
            n_moves = 30
            init_game()
        }

        function init_game() {
            // Hide UI
            result_box.scale = 0
            score_history_label.opacity = 0

            // Fade game in
            gameArea.opacity = 1

            // Clear existing dots
            game.clear_selection()
            game.clear_field()

            // Start new game
            game.fill()
            n_cleared = 0
            update_labels()
        }

        function end_game() {
            // Fade game out
            gameArea.opacity = 0.25

            // Show result
            result_label.text = n_cleared
            result_box.scale = 1
            score_history_label.opacity = 1

            update_scores(n_cleared);
        }

        function show_score() {
            // Fade game out
            gameArea.opacity = 0.25

            // Show result
            result_label.text = ""
            result_box.scale = 1
            score_history_label.opacity = 1

            get_scores(play_mode);
        }

        function update_labels() {
            if (play_mode === "default") {
                moves_label.text = n_moves
            } else {
                moves_label.text = time_left
            }

            score_label.text = n_cleared
        }

        function update_scores(n_cleared) {
            Storage.update_scores(n_cleared, play_mode,
                                  function(scores) {
                                      score_history_label.text = scores;
                                  }
                                  );
        }

        function get_scores() {
            score_history_label.text = Storage.get_scores(play_mode);
        }
    }

}


