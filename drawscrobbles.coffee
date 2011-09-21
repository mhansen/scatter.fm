# these are colors that are pretty easy to tell apart in the graph.
# we don't want colors that are hard to distinguish, like purple vs violet
COLORS = [ "red", "green", "blue", "purple", "brown", "orange", "cyan", "magenta" ]
scrobbles = null

window.resetAndRedrawScrobbles = ->
  scrobbles = scrobbleCollection
  $("#drawingThrobber").show()
  $("#drawStatus").text "#{scrobbleCollection.size()} points"
  # the plotting locks up the DOM, so give it a chance to update
  # with a status message before launching the expensive plotting
  _.defer expensiveDrawingComputation

expensiveDrawingComputation = ->
  compute_artist_colors = (scrobbles) ->
    artist_scrobbles_hash = {}
    scrobbles.forEach (scrobble) ->
      artist = scrobble.artist()
      if artist_scrobbles_hash[artist]
        artist_scrobbles_hash[artist].push scrobble
      else artist_scrobbles_hash[artist] = [ scrobble ]

    # turn the object into an array and sort it
    artist_scrobbles_array = _(artist_scrobbles_hash).toArray().
      sort (a,b) -> b.length - a.length

    artists = for artist_scrobbles in artist_scrobbles_array
      artist_scrobbles[0].artist()
    artist_colors = {}
    for own i, artist of artists
      artist_colors[artist] = COLORS[i] or "gray"
    artist_colors

  artist_colors = compute_artist_colors scrobbles

  try
    re = new RegExp $("#search").val(), "i"
  catch error
    window.alert "Invalid regular expression: " + error
    re = //

  filtered_scrobbles = scrobbleCollection.filter (scrobble) ->
    re.exec(scrobble.track()) or re.exec(scrobble.artist()) or re.exec(scrobble.album())

  window.track_indices = {
    # Here's an example:
    #"snow patrol#eyes open": {
      #series_index: 1
      #datapoint_index:
    #}
  }

  series = []

  for scrobble in filtered_scrobbles
    date = scrobble.date().getTime()
    time = scrobble.date().getHours() + (scrobble.date().getMinutes() / 60)
    series.push
      color: artist_colors[scrobble.artist()]
      data: [[date, time]]
      scrobble: scrobble
    if not track_indices[scrobble.artist() + "#" + scrobble.track()]?
      track_indices[scrobble.artist() + "#" + scrobble.track()] = []
    track_indices[scrobble.artist() + "#" + scrobble.track()].push
      series_index: series.length - 1
      datapoint_index: 0

  ONE_DAY = 1000*60*60*24
  minTime = scrobbleCollection.min((scrobble) -> scrobble.date()).date()
  maxTime = scrobbleCollection.max((scrobble) -> scrobble.date()).date()

  try
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
  catch error
    console.log error
  $("#legend li").remove()

  for artist, color of artist_colors when color != "gray"
    circle = " \u25CF "
    $("<li></li>").text(artist+circle).css("color", color).appendTo("#legend")

  $("<li></li>").text("[Other]"+circle).css("color", "gray").appendTo("#legend")
  $("#legend_wrap").show()
  $("#searchForm").show()
  $("#drawingThrobber").hide()
