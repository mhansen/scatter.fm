window.appModel = new AppModel;
window.fetchModel = new FetchModel;
window.graphViewModel = new FlotScrobbleGraphViewModel;
window.legendModel = new LegendModel;
window.scrobbleCollection = new ScrobbleCollection;
window.requestQueue = new RequestQueue({
  max_n_reqs_in_progress: 4
});

appModel.on("change", function (model) {
  let path = "/";
  if (model.user()) {
    // Update the URL path
    path = `/user/${model.user()}`;
    if (model.get("filterTerm")) {
      path += `/filter/${model.get("filterTerm")}`;
    }
  }
  return router.navigate(path);
});

$("#searchForm").submit(function (e) {
  e.preventDefault();
  let filterTerm = filterBoxView.val();
  return appModel.set({ filterTerm });
});

appModel.on("change:user", function (model, user) {
  window.scrobbleCollection = new ScrobbleCollection;
  if (user) {
    return fetchModel.fetch_scrobbles(user);
  }
});

fetchModel.on("error", message => alert(`Last.FM Error: ${message}`));
