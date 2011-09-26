# these are colors that are pretty easy to tell apart in the graph.
# we don't want colors that are hard to distinguish, like purple vs violet
COLORS = [ "red", "green", "blue", "purple", "brown", "orange", "cyan", "magenta" ]

window.LegendModel = Backbone.Model.extend
  initialize: ->
    @set
      artistColors: {}
  compute_artist_colors: (scrobbleCollection) ->
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
    artistColors = {}
    for own i, artist of artists
      artistColors[artist] = COLORS[i] or "gray"
    @set artistColors: artistColors
