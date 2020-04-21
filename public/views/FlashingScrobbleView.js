let FlashingScrobbleView = Backbone.View.extend({
  initialize() { return this.flashingTimer = null; },
  render(scrobble) {
    if (this.flashingTimer != null) { clearInterval(this.flashingTimer); }
    let flashOn = false;
    let flash = function () {
      flashOn = !flashOn;
      if (flashOn) {
        return Array.from(track_indices[scrobble.artist() + "#" + scrobble.track()]).map((indices) =>
          window.plot.highlight(indices.series_index, indices.datapoint_index));
      } else {
        return window.plot.unhighlight();
      }
    };
    return this.flashingTimer = setInterval(flash, 200);
  },
  remove() {
    if (this.flashingTimer != null) { clearInterval(this.flashingTimer); }
    this.flashingTimer = null;
    if (window.plot != null) { return window.plot.unhighlight(); }
  }
});

window.flashingScrobbleView = new FlashingScrobbleView;

$("#flot_container").on("plothover plotclick", function (event, pos, item) {
  if (item) { // we're hovering over an data point
    return flashingScrobbleView.render(item.series.scrobble);
  } else { // we're hovering over whitespace
    return flashingScrobbleView.remove();
  }
});

$("#flot_container").mouseout(() => flashingScrobbleView.remove());
