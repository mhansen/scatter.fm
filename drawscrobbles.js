var scrobbles;
var plot;

function resetAndRedrawScrobbles(s) {
    scrobbles = s;
    $("#drawingThrobber").show();
    _.defer(expensiveDrawingComputation);
}

function expensiveDrawingComputation() {

    function compute_top_artists(scrobbles) {
        var artist_scrobbles_hash = {};
        _(scrobbles).each(function (scrobble) {
            var artist = scrobble.artist["#text"];
            if (artist_scrobbles_hash[artist]) {
                artist_scrobbles_hash[artist].push(scrobble);
            } else {
                artist_scrobbles_hash[artist] = [ scrobble ];
            }
        });

        // turn the object into an array and sort it
        var artist_scrobbles_array = _(artist_scrobbles_hash).toArray().
            sort(function(a,b) { return b.length - a.length; });

        return _(artist_scrobbles_array).map(function (artist_scrobbles) {
            return artist_scrobbles[0]["artist"]["#text"]; // just return an array of the names
        });
    }
    var artists = compute_top_artists(scrobbles);

    artist_colors = {};
    for (var i = 0; i < artists.length; i++) {
        var artist = artists[i];
        var color = COLORS[i] || "gray";
        artist_colors[artist] = color;
    }

    function scrobbles_to_series(scrobbles) {
        return _(scrobbles).map(function (scrobble) {
            var date = new Date(scrobble.date.uts * 1000);
            var time = date.getHours() + (date.getMinutes() / 60);
            var artist = scrobble.artist["#text"];
            return {
                color: artist_colors[artist],
                data: [[date.getTime(), time]],
                scrobble: scrobble
            }
        });
    }

    var re = new RegExp($("#search").val(), "i");
    var filtered_scrobbles = _(scrobbles).filter(function (scrobble) {
        var track = scrobble.name;
        var artist = scrobble.artist["#text"];
        var album = scrobble.album["#text"];
        return (re.exec(track) || re.exec(artist) || re.exec(album));
    });

    var ONE_DAY = 1000*60*60*24;
    var minTime = _(scrobbles).min(function(s) { return s.date.uts; }).date.uts * 1000;
    var maxTime = _(scrobbles).max(function(s) { return s.date.uts; }).date.uts * 1000;

    plot = $.plot($("#placeholder"), scrobbles_to_series(filtered_scrobbles), {
        xaxis: {
            min: minTime,
            max: maxTime,
            mode: "time", 
            timeformat: "%d %b %y",
            tickLength: 0,
            zoomRange: [ONE_DAY, maxTime - minTime],
            panRange: [minTime, maxTime]
        },
        yaxis: {
            transform: function (v) { return -v; }, // invert
            inverseTransform: function (v) { return -v; },
            min: 0,
            max: 24,
            tickLength: 0,
            ticks: [0, 3, 6, 9, 12, 15, 18, 21, 24 ],
            tickFormatter: function(val, axis) {
                if (val == 0) return "12am"
                    if (val < 12) return val + "am";
                if (val == 12) return "12pm";
                return (val - 12) + "pm";
            },
            zoomRange: false,
            panRange: false
        },
        points: { 
            radius: 0.5,
            show: "true"
        },
        grid: {
            hoverable: true
        },
        zoom: {
            interactive: true
        },
        pan: {
            interactive: true
        }
    });
    $("#drawingThrobber").hide();
}
