FlashingScrobbleView = Backbone.View.extend
  initialize: -> @flashingTimer = null
  render: (scrobble) ->
    clearInterval @flashingTimer if @flashingTimer?
    flashOn = false
    flash = ->
      flashOn = not flashOn
      if flashOn
        for indices in track_indices[scrobble.artist() + "#" + scrobble.track()]
          window.plot.highlight indices.series_index, indices.datapoint_index
      else
        window.plot.unhighlight()
    @flashingTimer = setInterval flash, 200
  remove: ->
    clearInterval @flashingTimer if @flashingTimer?
    @flashingTimer = null
    window.plot.unhighlight() if window.plot?

window.flashingScrobbleView = new FlashingScrobbleView

$("#placeholder").bind "plothover", (event, pos, item) ->
  if item # we're hovering over an data point
    flashingScrobbleView.render(item.series.scrobble)
  else # we're hovering over whitespace
    flashingScrobbleView.remove()

$("#placeholder").mouseout ->
  flashingScrobbleView.remove()
