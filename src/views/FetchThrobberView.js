let FetchThrobberView = Backbone.View.extend({
  el: "#fetchThrobber",
  render() {
    if (fetchModel.get("isFetching")) {
      let n = fetchModel.numPagesFetched();
      let t = fetchModel.get('totalPages');
      let status = `Fetching your scrobbles... ${n}/${t} pages done.`;
      this.$("#fetchStatus").text(status);
      this.$el.show();
    } else {
      this.$el.hide();
    }
  }
});

let fetchThrobberView = new FetchThrobberView;

fetchModel.on("newPageFetched", () => fetchThrobberView.render());

fetchModel.on("change:isFetching", function (model) {
  if (model.get("isFetching")) {
    fetchThrobberView.render();
  } else {
    fetchThrobberView.remove();
  }
});
