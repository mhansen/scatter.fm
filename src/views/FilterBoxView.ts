const FilterBoxView = Backbone.View.extend({
  el: "#searchForm",
  render(isDrawn) {
    if (isDrawn) {
      this.$el.fadeIn(1000);
    } else {
      this.$el.hide();
    }
  },
  val() { return $("#search").val(); }
});

const filterBoxView = new FilterBoxView;

graphViewModel.on("change:isDrawn", (model, isDrawn) => filterBoxView.render(isDrawn));
