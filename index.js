// distinct colors that aren't likely to be confused with one another
var COLORS = [ "red", "green", "blue", "purple", "yellow", "orange", "cyan", "magenta" ];

var previousPoint = null;
$("#placeholder").bind("plothover", function (event, pos, item) {
    if (!item) return;
    if (previousPoint == item.seriesIndex) return;
    previousPoint = item.seriesIndex;
    $("#tooltip").remove();
    showTooltip(item.pageX, item.pageY, item.series.scrobble);
});

function showTooltip(x, y, scrobble) {
    var tipWidth = 300;
    var tipHeight = 66;
    var xOffset = 5;
    var yOffset = 5;
    var scrollLeft = window.pageXOffset;
    var scrollTop = window.pageYOffset;
    var docWidth = window.innerWidth - 15;
    var docHeight = window.innerHeight - 8;

    if (y + tipHeight - scrollTop > docHeight) { // off the bottom side
        var calculatedY = y - tipHeight - yOffset;
    } else { 
        var calculatedY = y;
    }

    if (x + tipWidth - scrollLeft > docWidth) { // over the right side
        var css = { 
            top: calculatedY,
            right: docWidth - x + xOffset 
        };
    } else {
        var css = { 
            top: calculatedY,
            left: x + xOffset 
        };
    }
    var dateString = (new Date(scrobble.date.uts * 1000)).toString("HH:mm, ddd dd MMM yyyy");
    $("<div id='tooltip'>").
    append($("<div id='text'>").
        append($("<div id='name'>").text(scrobble.name)).
        append($("<div id='artist'>").text(scrobble.artist["#text"])).
        append($("<div id='album'>").text(scrobble.album["#text"])).
        append($("<div id='date'>").text(dateString))
    ).css(css).appendTo("body").fadeIn(200);

    if (scrobble.image[0] && scrobble.image[0]["#text"]) {
        var img = new Image();
        img.src = scrobble.image[1]["#text"];
        $(img).prependTo("#tooltip");
    }
}

$("#userForm").submit(function (e) {
    e.preventDefault();
    fetch_scrobbles($("#user").val(), resetAndRedrawScrobbles);
});

$("searchForm").submit(function (e) {
    e.preventDefault();
    if (!scrobbles) return;
    if (!plot) return;

    plot.setData([])
    plot.draw();
    var re = new RegExp($("#search").val(), "i");
    var filtered_scrobbles = _(scrobbles).filter(function (scrobble) {
        var track = scrobble.name;
        var artist = scrobble.artist["#text"];
        var album = scrobble.album["#text"];
        return (re.exec(track) || re.exec(artist) || re.exec(album));
    });
    plot.setData(scrobbles_to_series(filtered_scrobbles));
    plot.draw();
});