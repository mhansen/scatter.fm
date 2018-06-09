let FilterBoxView = Backbone.View.extend({
  el: "#searchForm",
  render(isDrawn) {
    if (isDrawn) {
      return this.$el.fadeIn(1000);
    } else {
      return this.$el.hide();
    }
  },
  val() { return $("#search").val(); }
});

window.filterBoxView = new FilterBoxView;

graphViewModel.on("change:isDrawn", (model, isDrawn) => filterBoxView.render(isDrawn));
