ToolTipView = Backbone.View.extend
  tagname: "div"
  className: "popover left"
  id: "tooltip"
  render: (x, y, scrobble) ->
    template = """
    <div class='arrow'></div>
    <div class='inner'>
      <h4 class='title'>{{name}}</h4>
      <div class='content'>
        {{#image}}<img src='{{image}}'>{{/image}}
        <div id='artist'>{{artist}}</div>
        <div id='album'><i>{{album}}</i></div>
        <div id='date'>{{date}}</div>
      </div>
    </div>"""

    tooltip_html = Mustache.to_html template,
      name: scrobble.track()
      artist: scrobble.artist()
      album: scrobble.album()
      date: scrobble.date().toString("HH:mm, ddd dd MMM yyyy")
      image: scrobble.image()

    # A fudge factor to position the tooltip just right
    xFudgeFactor = 10 #px
    arrowYOffset= 70 #px, from style.css
    
    css =
      top: y - arrowYOffset
      right: window.innerWidth - x - xFudgeFactor

    $(@el).html(tooltip_html).css(css).appendTo("body").fadeIn(200)

window.toolTipView = new ToolTipView

previousPointIndex = null

$("#placeholder").bind "plothover", (event, pos, item) ->
  if item # we're overing over a data point
    # Have we already drawn the tooltip?
    return if previousPointIndex == item.seriesIndex
    previousPointIndex = item.seriesIndex
    toolTipView.render item.pageX, item.pageY, item.series.scrobble
  else # we're hovering over whitespace
    toolTipView.remove()

$("#placeholder").mouseout ->
  previousPointIndex = null
  toolTipView.remove()
  if window.plot? then window.plot.unhighlight()
