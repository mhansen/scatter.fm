const Scrobble = Backbone.Model.extend({
    artist() { return this.get("artist"); },
    album() { return this.get("album"); },
    track() { return this.get("track"); },
    date() { return this.get("date"); },
    image() { return this.get("image"); }
});
const ScrobbleCollection = Backbone.Collection.extend({
    model: Scrobble,
    add_from_lastfm_json(json) {
        for (let scrobble of json.recenttracks.track) {
            // Pull out just the information we need, because memory has been known
            // to run out with large datasets (e.g. 5 years of scrobbles). Leave the
            // rest to be GC'd.
            // You might think every scrobble has a date, but nope. 'now playing'
            // songs don't have a date, and they can break things. Skip them.
            if (scrobble['date'] == null) {
                continue;
            }
            // Old tracks (e.g. 1970) are probably bugs. Last.FM was founded in 2002.
            // Filter out obviously wrong scrobbles.
            if (Number(scrobble['date']['uts']) < 946684800) { // Unix timestamp for year 2000.
                continue;
            }
            let my_scrobble = {
                track: scrobble['name'],
                artist: scrobble['artist']['#text'],
                album: scrobble['album']['#text'],
                date: new Date(scrobble['date']['uts'] * 1000),
                image: null
            };
            if (scrobble['image'][1] && scrobble['image'][1]['#text']) {
                my_scrobble.image = scrobble['image'][1]['#text'];
            }
            this.add(my_scrobble, { silent: true });
        }
    }
});
