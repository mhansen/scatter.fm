// https://colorbrewer2.org/#type=qualitative&scheme=Paired&n=12
const LEGEND_COLORS = [
    // Other artists in element 0
    '#cab2d6',
    // Top artists
    '#a6cee3',
    '#1f78b4',
    '#b2df8a',
    '#33a02c',
    '#fb9a99',
    '#e31a1c',
    '#fdbf6f',
    '#ff7f00',
    '#6a3d9a',
    '#b15928',
    '#ffff99',
];
class ArtistColor {
}
class LegendModel extends Backbone.Model {
    initialize() {
        this.set({ artistColors: {} });
    }
    get_artist_color(artist) {
        return this.artist_colors()[artist.toLowerCase()];
    }
    artist_colors() {
        return this.get('artistColors');
    }
    compute_artist_colors(scrobbles) {
        let a = _.chain(scrobbles.models)
            .groupBy(s => s.artist().toLowerCase())
            .toArray()
            .sortBy('length')
            .reverse()
            .value();
        let artistColors = {};
        const otherColor = LEGEND_COLORS[0];
        for (let i = 0; i < a.length; i++) {
            let scrobbles = a[i];
            artistColors[scrobbles[0].artist().toLowerCase()] = {
                artist: scrobbles[0].artist(),
                color: LEGEND_COLORS[i + 1] || otherColor,
                count: scrobbles.length,
                showInLegend: !!LEGEND_COLORS[i + 1],
            };
        }
        this.set({ artistColors, otherColor });
    }
}
