.pragma library
.import QtQuick.LocalStorage 2.0 as LS

var identifier = "Colordots";
var description = "Colordots scores";

var QUERY = {
    CREATE_SETTINGS_TABLE: 'CREATE TABLE IF NOT EXISTS Settings(key TEXT PRIMARY KEY, value TEXT);',
    CREATE_SCORES_TABLE: 'CREATE TABLE IF NOT EXISTS Scores(date TEXT, mode TEXT, score NUMBER);'
}

var db = LS.LocalStorage.openDatabaseSync(identifier, "", description, 1024, function(db) {
    db.changeVersion(db.version, "1.0", function(tx) {
        tx.executeSql (QUERY.CREATE_SCORES_TABLE)
    });
});

if (db.version === "1.0") {
    db.changeVersion(db.version, "1.1", function(tx) {
        tx.executeSql (QUERY.CREATE_SETTINGS_TABLE)
    });
}

function update_scores(n_cleared, mode, onSuccess) {
    //console.debug("update_scores(" + n_cleared + ", " + mode + ")")

    // Save score
    var now = new Date()
    db.transaction(function(tx) {
        var last_score = tx.executeSql ("SELECT * FROM Scores WHERE mode = '" + mode + "' ORDER BY score ASC")
        var item = last_score.rows.item(0)
        if (last_score.rows.length < 5) {
            tx.executeSql("INSERT INTO Scores VALUES(?, ?, ?)", [now.toISOString(), mode, n_cleared])
        } else {
            if (item && item.score < n_cleared) {
                tx.executeSql ("DELETE FROM Scores WHERE date='" + item.date + "'");
                tx.executeSql ("INSERT INTO Scores VALUES(?, ?, ?)", [now.toISOString(), mode, n_cleared])
            }
        }
    })

    var scores
    db.transaction(function(tx) {
        scores = tx.executeSql ("SELECT * FROM Scores WHERE mode = '" + mode + "' ORDER BY score DESC LIMIT 5")
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

function get_scores(mode) {
    //console.debug("get_scores(" + mode + ")")
    var scores
    db.transaction (function(tx) {
        try {
            scores = tx.executeSql ("SELECT * FROM Scores WHERE mode = '" + mode + "' ORDER BY score DESC LIMIT 5")
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


/**
  Write setting to database.
*/
function writeSetting(key, value) {
    //console.log("writeSetting(" + key + "=" + value + ")");

    if (value === true) {
        value = 'true';
    }
    else if (value === false) {
        value = 'false';
    }

    db.transaction(function(tx) {
        tx.executeSql("INSERT OR REPLACE INTO settings VALUES (?, ?);", [key, value]);
        tx.executeSql("COMMIT;");
    });

}

/**
 Read given setting from database.
*/
function readSetting(key) {
    //console.log("readSetting(" + key + ")");

    var res = "";
    db.readTransaction(function(tx) {
        var rows = tx.executeSql("SELECT value AS val FROM settings WHERE key=?;", [key]);

        if (rows.rows.length !== 1) {
            res = "";
        } else {
            res = rows.rows.item(0).val;
        }
    });

    if (res === 'true') {
        return true;
    }
    else if (res === 'false') {
        return false;
    }

    return res;
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
