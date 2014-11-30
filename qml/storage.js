.pragma library
.import QtQuick.LocalStorage 2.0 as LS

var identifier = "Colordots";
var description = "Colordots scores";

var db = LS.LocalStorage.openDatabaseSync(identifier, "", description, 1024, function(db) {
    db.changeVersion(db.version, "1.0", function(tx) {
        tx.executeSql ("CREATE TABLE IF NOT EXISTS Scores(date TEXT, mode TEXT, score NUMBER)")
    });
});

function update_scores(n_cleared, onSuccess) {
    // Save score
    var now = new Date()
    db.transaction(function(tx) {
        var last_score = tx.executeSql ("SELECT * FROM Scores ORDER BY score ASC")
        //console.debug("scores=" + last_score.rows.length)
        var item = last_score.rows.item(0)
        if (last_score.rows.length < 5) {
            tx.executeSql("INSERT INTO Scores VALUES(?, ?, ?)", [now.toISOString(), "default", n_cleared])
        } else {
            if (item && item.score < n_cleared) {
                tx.executeSql ("DELETE FROM Scores WHERE date='" + item.date + "'");
                tx.executeSql ("INSERT INTO Scores VALUES(?, ?, ?)", [now.toISOString(), "default", n_cleared])
            }
        }
    })

    var scores
    db.transaction(function(tx) {
        scores = tx.executeSql ("SELECT * FROM Scores ORDER BY score DESC LIMIT 5")
    })

    if (scores !== "undefined") {
        var text = ""
        for (var i = 0; i < scores.rows.length; i++) {
            var item = scores.rows.item(i)
            if (text != "")
                text += "<br/>"
            text += format_date(new Date(item.date)) + ": <b>" + item.score + "</b>"
        }
    }

    onSuccess(text);
}

function get_scores() {
    var scores
    db.transaction (function(tx) {
        try {
            scores = tx.executeSql ("SELECT * FROM Scores ORDER BY score DESC LIMIT 5")
        }
        catch (e) {
        }
    })

    if (scores !== "undefined") {
        var text = ""
        for (var i = 0; i < scores.rows.length; i++) {
            var item = scores.rows.item(i)
            if (text != "")
                text += "<br/>"
            text += format_date(new Date(item.date)) + ": <b>" + item.score + "</b>"
        }
    }
    return text;
}

function format_date(date) {
    var now = new Date()
    var seconds = (now.getTime() - date.getTime()) / 1000
    if (seconds < 1)
        return "Now"
    if (seconds < 120)
        return Math.floor (seconds) + " seconds ago"
    var minutes = seconds / 60
    if (minutes < 120)
        return Math.floor (minutes) + " minutes ago"
    var hours = minutes / 60
    if (hours < 48)
        return Math.floor (hours) + " hours ago"
    var days = hours / 24
    if (days < 30)
        return Math.floor (days) + " days ago"
    if (date.getFullYear() !== now.getFullYear())
        return Qt.formatDate (date, "MMM yyyy")
    return Qt.formatDate (date, "d MMM")
}
