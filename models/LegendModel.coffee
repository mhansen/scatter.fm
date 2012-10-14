# these are colors that are pretty easy to tell apart in the graph.
# we don't want colors that are hard to distinguish, like purple vs violet
COLORS = [ "red", "green", "blue", "purple", "brown", "orange", "cyan", "magenta" ]

window.LegendModel = Backbone.Model.extend
  initialize: ->
    @set
      artistColors: {}
  compute_artist_colors: (scrobbles) ->
    a = _.chain(scrobbles.models)
      .groupBy((s) -> s.artist())
      .toArray()
      .sortBy('length')
      .reverse()
      .value()

    artistColors = {}
    for own i, x of a
      artistColors[x[0].artist()] =
        color: COLORS[i] or "gray"
        count: x.length
    @set artistColors: artistColors
