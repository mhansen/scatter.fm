# these are colors that are pretty easy to tell apart in the graph.
# we don't want colors that are hard to distinguish, like purple vs violet
COLORS = [ "red", "green", "blue", "purple", "brown", "orange", "cyan", "magenta" ]

window.LegendModel = Backbone.Model.extend
  initialize: ->
    @set
      artistColors: {}
  compute_artist_colors: (scrobbles) ->
    artists = _.chain(scrobbles)
      .groupBy((s) -> s.artist())
      .toArray()
      .sortBy('length')
      .map((artist_scrobbles) -> artist_scrobbles[0].artist())

    artistColors = {}
    for own i, artist of artists
      artistColors[artist] = COLORS[i] or "gray"
    @set artistColors: artistColors
