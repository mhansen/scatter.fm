let Scrobble = Backbone.Model.extend({
  artist() { return this.get("artist"); },
  album() { return this.get("album"); },
  track() { return this.get("track"); },
  date() { return this.get("date"); },
  image() { return this.get("image"); }
});

window.ScrobbleCollection = Backbone.Collection.extend({
  model: Scrobble,
  add_from_lastfm_json(json) {
    let result = [];
    for (let scrobble of Array.from(json.recenttracks.track)) {
    // Pull out just the information we need, because memory has been known
    // to run out with large datasets (e.g. 5 years of scrobbles). Leave the
    // rest to be GC'd.
    
    // You might think every scrobble has a date, but nope. 'now playing'
    // songs don't have a date, and they can break things. Skip them.
      if ((scrobble['date'] == null)) { continue; }
      let my_scrobble = {
        track: scrobble['name'],
        artist: scrobble['artist']['#text'],
        album: scrobble['album']['#text'],
        date: new Date(scrobble['date']['uts'] * 1000)
      };
      if (scrobble['image'][1] && scrobble['image'][1]['#text']) {
        my_scrobble.image = scrobble['image'][1]['#text'];
      }
      result.push(this.add(my_scrobble, {silent: true}));
    }
    return result;
  }
});
