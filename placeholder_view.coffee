previousPoint = null
flashingTimer = null

$("#placeholder").bind "plothover", (event, pos, item) ->
  return if not item # we're not hovering over an item
  return if previousPoint == item.seriesIndex # we've already drawn the tooltip

  previousPoint = item.seriesIndex
  $("#tooltip").remove()
  window.plot.unhighlight()
  if flashingTimer? then clearInterval flashingTimer

  scrobble = item.series.scrobble
  render_tooltip item.pageX, item.pageY, scrobble

  flashOn = false
  flash = ->
    flashOn = not flashOn
    if flashOn
      for indices in track_indices[scrobble.artist + "#" + scrobble.track]
        window.plot.highlight indices.series_index, indices.datapoint_index
    else
      window.plot.unhighlight()

  flashingTimer = setInterval flash, 200

$("#placeholder").mouseout (e) ->
  previousPoint = null
  $("#tooltip").remove()
  if window.plot? then window.plot.unhighlight()
  if flashingTimer? then clearInterval flashingTimer
