window.render_tooltip = (x, y, scrobble) ->
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
