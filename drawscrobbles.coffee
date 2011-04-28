COLORS = [ "red", "green", "blue", "purple", "yellow", "orange", "cyan", "magenta" ]
scrobbles = null

window.resetAndRedrawScrobbles = (s) ->
    scrobbles = s
    $("#drawingThrobber").show()
    $("#drawStatus").text "#{s.length} points"
    # the plotting locks up the DOM, so give it a chance to update
    # with a status message before launching the expensive plotting
    _.defer expensiveDrawingComputation

expensiveDrawingComputation = () ->
    compute_artist_colors = (scrobbles) ->
        artist_scrobbles_hash = {}
        for scrobble in scrobbles
            artist = scrobble.artist
            if artist_scrobbles_hash[artist]
                artist_scrobbles_hash[artist].push scrobble
            else artist_scrobbles_hash[artist] = [ scrobble ]

        # turn the object into an array and sort it
        artist_scrobbles_array = _(artist_scrobbles_hash).toArray().
            sort (a,b) -> b.length - a.length

        artists = for artist_scrobbles in artist_scrobbles_array
            artist_scrobbles[0].artist
        artist_colors = {}
        for own i, artist of artists
            artist_colors[artist] = COLORS[i] or "gray"
        artist_colors

    artist_colors = compute_artist_colors scrobbles

    re = new RegExp $("#search").val(), "i"
    filtered_scrobbles = _.filter scrobbles, (scrobble) ->
        re.exec(scrobble.track) or re.exec(scrobble.artist) or re.exec(scrobble.album)

    window.track_indices = {
        #"snow patrol#eyes open": {
            #series_index: 1
            #datapoint_index:
        #}
    }

    series = []

    for scrobble in filtered_scrobbles
        date = scrobble.date.getTime()
        time = scrobble.date.getHours() + (scrobble.date.getMinutes() / 60)
        series.push {
            color: artist_colors[scrobble.artist]
            data: [[date, time]]
            scrobble: scrobble
        }
        if not track_indices[scrobble.artist + "#" + scrobble.track]?
            track_indices[scrobble.artist + "#" + scrobble.track] = []
        track_indices[scrobble.artist + "#" + scrobble.track].push {
            series_index: series.length - 1
            datapoint_index: 0
        }


    ONE_DAY = 1000*60*60*24
    minTime = _(scrobbles).min((scrobble) -> scrobble.date).date
    maxTime = _(scrobbles).max((scrobble) -> scrobble.date).date

    window.plot = $.plot($("#placeholder"), series, {
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
        points: { radius: 1, show: true }
        grid: {
            hoverable: true
            autoHighlight: false
        }
        zoom: { interactive: true }
        pan: { interactive: true }
    })
    $("#drawingThrobber").hide()
