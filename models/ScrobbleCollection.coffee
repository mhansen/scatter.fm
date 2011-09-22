Scrobble = Backbone.Model.extend
  artist: -> @get("artist")
  album: -> @get("album")
  track: -> @get("track")
  date: -> @get("date")
  image: -> @get("image")

ScrobbleCollection = Backbone.Collection.extend
  model: Scrobble
  add_from_lastfm_json: (json) ->
    for scrobble in json.recenttracks.track
      # Pull out just the information we need, because memory has been known
      # to run out with large datasets (e.g. 5 years of scrobbles). Leave the
      # rest to be GC'd.
      
      # You might think every scrobble has a date, but nope. 'now playing'
      # songs don't have a date, and they can break things. Skip them.
      continue if not scrobble['date']?
      my_scrobble =
        track: scrobble['name']
        artist: scrobble['artist']['#text']
        album: scrobble['album']['#text']
        date: new Date(scrobble['date']['uts'] * 1000)
      if scrobble['image'][1] && scrobble['image'][1]['#text']
        my_scrobble.image = scrobble['image'][1]['#text']
      @add my_scrobble, silent: true

window.scrobbleCollection = new ScrobbleCollection

appModel.bind "change:user", ->
  scrobbleCollection = new ScrobbleCollection
