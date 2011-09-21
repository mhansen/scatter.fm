previousPoint = null
flashingTimer = null

$("#placeholder").bind "plothover", (event, pos, item) ->
  return if not item # we're not hovering over an item
  return if previousPoint == item.seriesIndex # we've already drawn the tooltip

  previousPoint = item.seriesIndex
  $("#tooltip").remove()
  window.plot.unhighlight()
  if flashingTimer? then clearInterval flashingTimer

  scrobble = item.series.scrobble
  showTooltip item.pageX, item.pageY, scrobble

  flashOn = false
  flash = ->
    flashOn = not flashOn
    if flashOn
      for indices in track_indices[scrobble.artist + "#" + scrobble.track]
        window.plot.highlight indices.series_index, indices.datapoint_index
    else
      window.plot.unhighlight()

  flashingTimer = setInterval flash, 200

$("#placeholder").mouseout (e) ->
  previousPoint = null
  $("#tooltip").remove()
  if window.plot? then window.plot.unhighlight()
  if flashingTimer? then clearInterval flashingTimer

showTooltip = (x, y, scrobble) ->
  dateString = scrobble.date.toString("HH:mm, ddd dd MMM yyyy")
  template = """
  <div id='tooltip' class='popover left'>
    <div class='arrow'></div>
    <div class='inner'>
      <h4 class='title'>{{name}}</h4>
      <div class='content'>
        <div id='artist'>{{artist}}</div>
        <div id='album'><i>{{album}}</i></div>
        <div id='date'>{{date}}</div>
      </div>
    </div>
  </div>
  """

  tooltip_html = Mustache.to_html template,
    name: scrobble.track
    artist: scrobble.artist
    album: scrobble.album
    date: dateString

  # A fudge factor to position the tooltip just right
  xFudgeFactor = 10 #px
  arrowYOffset= 70 #px, from style.css
  
  css =
    top: y - arrowYOffset
    right: window.innerWidth - x - xFudgeFactor

  $(tooltip_html).css(css).appendTo("body").fadeIn(200)

  if scrobble.image
    img = new Image
    img.src = scrobble.image
    $(img).prependTo "#tooltip .content"

$("#searchForm").submit (e) ->
  e.preventDefault()
  return if not window.current_lastfm_user
  path = "/user/" + window.current_lastfm_user + "/filter/" + $("#search").val()
  myRouter.navigate path, triggerRoute: true

window.current_lastfm_user = undefined
graph_a_user = (user) ->
  return if user == window.current_lastfm_user
  window.current_lastfm_user = user

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
    graph_a_user user
  load_and_search: (user, search) ->
    graph_a_user(user)
    $("#search").val(search)
    resetAndRedrawScrobbles window.scrobbles

myRouter = new AppRouter
Backbone.history.start()
