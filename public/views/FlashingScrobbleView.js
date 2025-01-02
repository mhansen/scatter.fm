class FlashingScrobbleView extends Backbone.View {
    constructor() {
        super(...arguments);
        this.flashingTimer = null;
    }
    // @ts-ignore
    render(scrobble) {
        if (this.flashingTimer != null) {
            clearInterval(this.flashingTimer);
        }
        let flashOn = false;
        let flash = function () {
            flashOn = !flashOn;
            if (flashOn) {
                // @ts-ignore
                Array.from(track_indices[scrobble.artist() + "#" + scrobble.track()]).forEach((indices) => 
                // @ts-ignore
                window.plot.highlight(indices.series_index, indices.datapoint_index));
            }
            else {
                // @ts-ignore
                window.plot.unhighlight();
            }
        };
        this.flashingTimer = setInterval(flash, 200);
        return this;
    }
    remove() {
        if (this.flashingTimer != null) {
            clearInterval(this.flashingTimer);
        }
        this.flashingTimer = null;
        // @ts-ignore
        if (window.plot != null) {
            window.plot.unhighlight();
        }
        return this;
    }
}
const flashingScrobbleView = new FlashingScrobbleView();
$("#flot_container").on("plothover plotclick", function (event, pos, item) {
    if (item) { // we're hovering over an data point
        flashingScrobbleView.render(item.series.scrobble);
    }
    else { // we're hovering over whitespace
        flashingScrobbleView.remove();
    }
});
$("#flot_container").mouseout(() => flashingScrobbleView.remove());
