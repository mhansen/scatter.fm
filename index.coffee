current_lastfm_user = undefined
window.graph_a_user = (user) ->
  # don't refetch data for the same user
  return if user == current_lastfm_user
  current_lastfm_user = user

  $("#user").text(user)
  $("#lastfm_link").attr "href", "http://www.last.fm/user/" + user
  responses_received = 0
  redraw_on_response_number = 1
  fetch_scrobbles
    user: user
    onprogress: (e) ->
      responses_received++
      if responses_received == redraw_on_response_number
        # redrawing is slow as hell, don't do it often
        redraw_on_response_number *= 2
        resetAndRedrawScrobbles e.scrobbles
      $("#fetchStatus").text e.thisPage - 2 + " to go."
    onfinished: (scrobbles) ->
      $("#fetchThrobber").hide()
      resetAndRedrawScrobbles scrobbles  # force redraw
    onerror: (errCode, message) ->
      $("#fetchThrobber").hide()
      alert "Last.FM Error: " + message
  $("#fetchThrobber").show()

AppRouter = Backbone.Router.extend
  routes:
    "/user/:user": "load_user"
    "/user/:user/": "load_user"
    "/user/:user/filter/:searchterm": "load_and_search"
  load_user: (user) ->
    appModel.set user: user
    appModel.set filterTerm: ""
  load_and_search: (user, filterTerm) ->
    appModel.set user: user
    appModel.set filterTerm: filterTerm
window.router = new AppRouter

Backbone.history.start()
