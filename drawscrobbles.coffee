COLORS = [ "red", "green", "blue", "purple", "yellow", "orange", "cyan", "magenta" ]
scrobbles = null
plot = null

window.resetAndRedrawScrobbles = (s) ->
    scrobbles = s
    $("#drawingThrobber").show()
    $("#drawStatus").text "#{s.length} points"
    _.defer expensiveDrawingComputation

expensiveDrawingComputation = () ->
    compute_top_artists = (scrobbles) ->
        artist_scrobbles_hash = {}
        for scrobble in scrobbles
            artist = scrobble.artist
            if artist_scrobbles_hash[artist]
                artist_scrobbles_hash[artist].push scrobble
            else artist_scrobbles_hash[artist] = [ scrobble ]

        # turn the object into an array and sort it
        artist_scrobbles_array = _(artist_scrobbles_hash).toArray().
            sort (a,b) -> b.length - a.length

        #just return an array of the artist names
        artist_scrobbles[0].artist for artist_scrobbles in artist_scrobbles_array
    artists = compute_top_artists scrobbles

    artist_colors = {}
    for own i, artist of artists
        artist_colors[artist] = COLORS[i] or "gray"

    re = new RegExp $("#search").val(), "i"
    filtered_scrobbles = _.filter scrobbles (scrobble) ->
        re.exec(scrobble.track) or re.exec(scrobble.artist) or re.exec(scrobble.album)

    series = for scrobble in filtered_scrobbles
        date = scrobble.date.getTime()
        time = scrobble.date.getHours() + (scrobble.date.getMinutes() / 60)
        {
            color: artist_colors[scrobble.artist]
            data: [[date, time]]
            scrobble: scrobble
        }

    ONE_DAY = 1000*60*60*24
    minTime = _(scrobbles).min((scrobble) -> scrobble.date).date
    maxTime = _(scrobbles).max((scrobble) -> scrobble.date).date


    plot = $.plot($("#placeholder"), series, {
        xaxis: {
            min: minTime
            max: maxTime
            mode: "time"
            timeformat: "%d %b %y"
            tickLength: 0
            zoomRange: [ONE_DAY, maxTime - minTime]
            panRange: [minTime, maxTime]
        }
        yaxis: {
            transform: (v) -> -v # flip y axis
            inverseTransform: (v) -> -v
            min: 0
            max: 24
            tickLength: 0
            ticks: [0, 3, 6, 9, 12, 15, 18, 21, 24 ]
            tickFormatter: (val, axis) ->
                if val == 0 then "12am"
                else if val < 12 then "#{val}am"
                else if val == 12 then "12pm"
                else "#{val - 12}pm"
            zoomRange: false
            panRange: false
        }
        points: { radius: 0.5, show: true }
        grid: { hoverable: true }
        zoom: { interactive: true }
        pan: { interactive: true }
    })
    $("#drawingThrobber").hide()
