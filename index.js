// Distinct colors that aren't likely to be confused with one another.
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

$("#searchForm").submit(function (e) {
    e.preventDefault();
    if (!scrobbles) return;
    if (!plot) return;
    window.location.hash = "#" + $("#search").val();
    resetAndRedrawScrobbles(scrobbles);
});

if ($.url.param("user")) {
    $("#user").val($.url.param("user"));
    var responses_received = 0;
    var next_redraw = 1;
    fetch_scrobbles({
        user: $.url.param("user"), 
        onprogress: function (scrobbles) {
            responses_received++;
            if (next_redraw == responses_received) {
                next_redraw *= 2;
                resetAndRedrawScrobbles(scrobbles);
            }
        },
        onfinished: function (scrobbles) {
            $("#fetchThrobber").hide();
            resetAndRedrawScrobbles(scrobbles); // force redraw
        },
        onerror: function (errCode, message) {
            $("#fetchThrobber").hide();
            alert("Last.FM Error: "+ message);
        }
    });
    $("#fetchThrobber").show();
}

if (window.location.hash) {
    $("#search").val(window.location.hash.substring(1));
}
$(window).bind('hashchange', function() {
    $("#search").val(window.location.hash.substring(1));
});
