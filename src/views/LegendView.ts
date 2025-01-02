class LegendView extends Backbone.View {
  render() {
    this.$("li").remove();
    let artistColors = legendModel.artist_colors();
    for (const k in artistColors) {
      const color = artistColors[k];
      if (color.showInLegend) {
        $("<li>")
          .text(`${color.artist} (${color.count})`)
          .css("color", color.color)
          .appendTo("#legend");
      }
    }
    $("<li>")
      .text("[Other Artists]")
      .css("color", legendModel.get("otherColor"))
      .appendTo("#legend");
    this.$el.show();
    return this;
  }

  remove() {
    this.$el.hide();
    return this;
  }
}
  
const legendView = new LegendView({
  el: "#legend_wrap",
});

legendModel.on("change:artistColors", () => legendView.render());
