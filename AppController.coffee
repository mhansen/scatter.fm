window.appModel = new AppModel
window.fetchModel = new FetchModel
window.graphViewModel = new FlotScrobbleGraphViewModel
window.legendModel = new LegendModel
window.scrobbleCollection = new ScrobbleCollection
window.requestQueue = new RequestQueue
  max_n_reqs_in_progress: 4

appModel.bind "change", (model) ->
  path = "/"
  if model.user()
    # Update the URL path
    path = "/user/" + model.user()
    if model.get("filterTerm")
      path += "/filter/" + model.get("filterTerm")
  router.navigate path

$("#searchForm").submit (e) ->
  e.preventDefault()
  filterTerm = filterBoxView.val()
  appModel.set filterTerm: filterTerm

appModel.bind "change:user", (model, user)->
  window.scrobbleCollection = new ScrobbleCollection
  if user
    fetchModel.fetch_scrobbles user

fetchModel.bind "error", (message) ->
  alert "Last.FM Error: #{message}"
