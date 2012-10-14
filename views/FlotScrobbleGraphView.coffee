# these are colors that are pretty easy to tell apart in the graph.
# we don't want colors that are hard to distinguish, like purple vs violet
COLORS = [ "red", "green", "blue", "purple",
           "brown", "orange", "cyan", "magenta" ]

FlotScrobbleGraphView = Backbone.View.extend
  render: ->
    return if scrobbleCollection.size() == 0
    graphViewModel.set isDrawing: true
  
    # The plotting locks up the DOM, so give it a chance to update
    # with a status message before launching the expensive plotting.
    _.defer ->
      legendModel.compute_artist_colors(scrobbleCollection)
      re = appModel.filterRegex()

      filtered_scrobbles = scrobbleCollection.filter (s) ->
        re.exec(s.track()) or re.exec(s.artist()) or re.exec(s.album())

      flot_series = construct_flot_series filtered_scrobbles

      minTime = scrobbleCollection.min((scrobble) -> scrobble.date()).date()
      maxTime = scrobbleCollection.max((scrobble) -> scrobble.date()).date()

      plot_flot_series flot_series, minTime, maxTime
      graphViewModel.set isDrawn: true, isDrawing: false

compute_artist_colors = ->
  artist_scrobbles_hash = {}
  scrobbleCollection.forEach (scrobble) ->
    artist = scrobble.artist()
    if artist_scrobbles_hash[artist]
      artist_scrobbles_hash[artist].push scrobble
    else artist_scrobbles_hash[artist] = [ scrobble ]

  # turn the object into an array and sort it
  # so we get the most popular artists at the start
  artist_scrobbles_array = _(artist_scrobbles_hash).toArray().
    sort (a,b) -> b.length - a.length

  artists = for artist_scrobbles in artist_scrobbles_array
    artist_scrobbles[0].artist()
  artist_colors = {}
  for own i, artist of artists
    artist_colors[artist] = COLORS[i] or "gray"
  artist_colors

construct_flot_series = (scrobbles) ->
  window.track_indices = {
    # Here's an example:
    #"snow patrol#eyes open": {
      #series_index: 1
      #datapoint_index: 0
    #}
  }

  series = []

  for scrobble in scrobbles
    date = scrobble.date().getTime()
    time = scrobble.date().getHours() + (scrobble.date().getMinutes() / 60)
    series.push
      color: legendModel.get("artistColors")[scrobble.artist()]
      data: [[date, time]]
      scrobble: scrobble
    if not track_indices[scrobble.artist() + "#" + scrobble.track()]?
      track_indices[scrobble.artist() + "#" + scrobble.track()] = []
    track_indices[scrobble.artist() + "#" + scrobble.track()].push
      series_index: series.length - 1
      datapoint_index: 0
  return series

plot_flot_series = (flot_series, minTime, maxTime) ->
  ONE_DAY_IN_MS = 1000*60*60*24
  try
    window.plot = $.plot $("#flot_container"), flot_series,
      xaxis:
        min: minTime
        max: maxTime
        mode: "time"
        timeformat: "%d %b %y"
        tickLength: 0
        zoomRange: [ONE_DAY_IN_MS, maxTime - minTime]
        panRange: [minTime, maxTime]
        position: "top"
      yaxis:
        transform: (v) -> -v # flip y axis so morning is at the top
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
      points:
        radius: 1
        show: true
      grid:
        clickable: true
        hoverable: true
        autoHighlight: false
      zoom:
        interactive: true
      pan:
        interactive: true
  catch error
    console.log error

flotScrobbleGraphView = new FlotScrobbleGraphView

redraw_on_response_number = 1

appModel.on "change:user", ->
  redraw_on_response_number = 1

fetchModel.on "newPageFetched", ->
  if fetchModel.numPagesFetched() == redraw_on_response_number
    # Redrawing is slow as hell, and O(n^2) if we draw it n times.
    # So only draw it log2(n) times, for O(nlogn) load times.  Do
    # this by only drawing on response 1, 2, 4, 8, 16... etc until
    # the final response.
    redraw_on_response_number *= 2
    flotScrobbleGraphView.render()

fetchModel.on "change:isFetching", (model, isFetching) ->
  # Force a redraw when the last response comes through.
  flotScrobbleGraphView.render()

appModel.on "change:filterTerm", (model, oldFilterTerm) ->
  flotScrobbleGraphView.render()
