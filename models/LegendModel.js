// these are colors that are pretty easy to tell apart in the graph.
// we don't want colors that are hard to distinguish, like purple vs violet
const LEGEND_COLORS = [ "red", "green", "blue", "purple", "brown", "orange", "cyan", "magenta" ];

window.LegendModel = Backbone.Model.extend({
  initialize() {
    return this.set({
      artistColors: {}});
  },
  compute_artist_colors(scrobbles) {
    let a = _.chain(scrobbles.models)
      .groupBy(s => s.artist())
      .toArray()
      .sortBy('length')
      .reverse()
      .value();

    let artistColors = {};
    for (let i of Object.keys(a || {})) {
      let x = a[i];
      artistColors[x[0].artist()] = {
        color: LEGEND_COLORS[i] || "gray",
        count: x.length
      };
    }
    return this.set({artistColors});
  }
});
