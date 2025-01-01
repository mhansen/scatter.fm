class FilterBoxView extends Backbone.View {
  isDrawn = false;
  render() {
    if (this.isDrawn) {
      this.$el.fadeIn(1000);
    } else {
      this.$el.hide();
    }
    return this;
  }
  val() { return $("#search").val(); }
}

const filterBoxView = new FilterBoxView({
  el: "#searchForm",
});

graphViewModel.on("change:isDrawn", (model, isDrawn) => {
  filterBoxView.isDrawn = isDrawn;
  filterBoxView.render()
});
