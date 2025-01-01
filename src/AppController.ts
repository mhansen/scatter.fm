let appModel = new AppModel();
let fetchModel = new FetchModel();
let graphViewModel = new FlotScrobbleGraphViewModel();
let legendModel = new LegendModel();
let scrobbleCollection = new ScrobbleCollection();
let requestQueue = new RequestQueue({
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
  router.navigate(path);
});

$("#searchForm").submit(function (e) {
  e.preventDefault();
  let filterTerm = filterBoxView.val();
  appModel.set({ filterTerm });
});

appModel.on("change:user", function (model, user) {
  scrobbleCollection = new ScrobbleCollection;
  if (user) {
    fetchModel.fetch_scrobbles(user);
  }
});

fetchModel.on("error", message => alert(`Last.FM Error: ${message}`));
