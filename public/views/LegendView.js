const LegendView = Backbone.View.extend({
    el: "#legend_wrap",
    render() {
        this.$("li").remove();
        let artistColors = legendModel.get("artistColors");
        for (let artist in artistColors) {
            let color = artistColors[artist];
            if (color.showInLegend) {
                $("<li>")
                    .text(`${artist} (${color.count})`)
                    .css("color", color.color)
                    .appendTo("#legend");
            }
        }
        $("<li>")
            .text("[Other Artists]")
            .css("color", legendModel.get("otherColor"))
            .appendTo("#legend");
        this.$el.show();
    },
    remove() {
        this.$el.hide();
    }
});
const legendView = new LegendView;
legendModel.on("change:artistColors", (model, artistColors) => legendView.render());
