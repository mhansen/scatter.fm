class FlashingScrobbleView extends Backbone.View {
  initialize() {
    this.flashingTimer = null;
  }
  render(scrobble) {
    if (this.flashingTimer != null) { clearInterval(this.flashingTimer); }
    let flashOn = false;
    let flash = function () {
      flashOn = !flashOn;
      if (flashOn) {
        Array.from(track_indices[scrobble.artist() + "#" + scrobble.track()]).forEach((indices) =>
          window.plot.highlight(indices.series_index, indices.datapoint_index));
      } else {
        window.plot.unhighlight();
      }
    };
    this.flashingTimer = setInterval(flash, 200);
    return this;
  }
  remove() {
    if (this.flashingTimer != null) { clearInterval(this.flashingTimer); }
    this.flashingTimer = null;
    if (window.plot != null) { window.plot.unhighlight(); }
    return this;
  }
}

const flashingScrobbleView = new FlashingScrobbleView();

$("#flot_container").on("plothover plotclick", function (event, pos, item) {
  if (item) { // we're hovering over an data point
    flashingScrobbleView.render(item.series.scrobble);
  } else { // we're hovering over whitespace
    flashingScrobbleView.remove();
  }
});

$("#flot_container").mouseout(() => flashingScrobbleView.remove());
