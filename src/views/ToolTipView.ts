class ToolTipView extends Backbone.View {
  visible: boolean = false;

  // @ts-ignore
  render(x, y, scrobble) {
    let template = `\
<div class='arrow'></div>
<div class='inner'>
  <div class='content'>
    {{#image}}<img src='{{image}}'>{{/image}}
    <div>{{name}}</div>
    <div id='artist'><b>{{artist}}</b></div>
    <div id='album'>{{album}}</div>
    <div id='date'>{{date}}</div>
  </div>
</div>`;

    // @ts-ignore
    let tooltip_html = Mustache.to_html(template, {
      name: scrobble.track(),
      artist: scrobble.artist(),
      album: scrobble.album(),
      date: scrobble.date().toString("HH:mm, ddd dd MMM yyyy"),
      image: scrobble.image()
    });

    // Bring the arrow into the middle of the popover vertically
    let tipsyArrowYOffset = 70; //px, from style.css. 

    let css = {
      top: y - tipsyArrowYOffset,
      right: $(document).width() - x
    };

    this.$el.html(tooltip_html).css(css).appendTo("body").fadeIn(200);
    return this;
  }
}

const toolTipView = new ToolTipView({
  tagName: "div",
  className: "popover left",
  id: "tooltip",
});

let previousPointIndex = null;

$("#flot_container").on("plothover plotclick", function (event, pos, item) {
  if (item) { // we're overing over a data point
    // Have we already drawn the tooltip?
    if (toolTipView.visible && (previousPointIndex === item.seriesIndex)) { return; }
    previousPointIndex = item.seriesIndex;
    toolTipView.render(item.pageX, item.pageY, item.series.scrobble);
    toolTipView.visible = true;
  } else { // we're hovering over whitespace
    toolTipView.remove();
    toolTipView.visible = false;
  }
});

$("#flot_container").mouseout(function () {
  toolTipView.remove();
  // @ts-ignore
  if (window.plot != null) {
    // @ts-ignore
    window.plot.unhighlight();
  }
});
