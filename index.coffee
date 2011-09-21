current_lastfm_user = undefined
window.graph_a_user = (user) ->
  # don't refetch data for the same user
  return if user == current_lastfm_user
  current_lastfm_user = user

  responses_received = 0
  redraw_on_response_number = 1
  fetch_scrobbles user

  fetchModel.bind "progress", (e) ->
    responses_received++
    if responses_received == redraw_on_response_number
      # redrawing is slow as hell, don't do it often
      redraw_on_response_number *= 2
      resetAndRedrawScrobbles()
    $("#fetchStatus").text e.thisPage - 2 + " to go."

  fetchModel.bind "change:isFetching", (model, wasFetching) ->
    if wasFetching and not model.get("isFetching")
      resetAndRedrawScrobbles() # force redraw

  fetchModel.bind "error", (message) -> alert "Last.FM Error: #{message}"

  fetchModel.set isFetching: true

AppRouter = Backbone.Router.extend
  routes:
    "/user/:user": "load_user"
    "/user/:user/": "load_user"
    "/user/:user/filter/:searchterm": "load_and_search"
  load_user: (user) -> appModel.set user: user
  load_and_search: (user, filterTerm) ->
    appModel.set user: user, filterTerm: filterTerm
window.router = new AppRouter

Backbone.history.start()
