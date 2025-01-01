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
  artist: string;
  color: string;
  count: number;
  showInLegend: boolean;
}

class LegendModel extends Backbone.Model {
  initialize() {
    this.set({ artistColors: {} });
  }
  get_artist_color(artist: string): ArtistColor {
    return this.get('artistColors').get(artist.toLowerCase());
  }
  compute_artist_colors(scrobbles: ScrobbleCollection) {
    let a = _.chain(scrobbles.models)
      .groupBy(s => s.artist().toLowerCase())
      .toArray()
      .sortBy('length')
      .reverse()
      .value();

    let artistColors: Map<string, ArtistColor> = new Map();
    const otherColor = LEGEND_COLORS[0];
    for (let i = 0; i < a.length; i++) {
      let x = a[i];
      artistColors.set(x[0].artist().toLowerCase(), {
        artist: x[0].artist(),
        color: LEGEND_COLORS[i + 1] || otherColor,
        count: x.length,
        showInLegend: !!LEGEND_COLORS[i + 1],
      });
    }

    this.set({ artistColors, otherColor });
  }
}
