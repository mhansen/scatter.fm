ToolTipView = Backbone.View.extend
  tagname: "div"
  className: "popover left"
  id: "tooltip"
  visible: false
  render: (x, y, scrobble) ->
    template = """
    <div class='arrow'></div>
    <div class='inner'>
      <div class='content'>
        {{#image}}<img src='{{image}}'>{{/image}}
        <div>{{name}}</div>
        <div id='artist'><b>{{artist}}</b></div>
        <div id='album'>{{album}}</div>
        <div id='date'>{{date}}</div>
      </div>
    </div>"""

    tooltip_html = Mustache.to_html template,
      name: scrobble.track()
      artist: scrobble.artist()
      album: scrobble.album()
      date: scrobble.date().toString("HH:mm, ddd dd MMM yyyy")
      image: scrobble.image()

    # Bring the arrow into the middle of the popover vertically
    tipsyArrowYOffset = 70 #px, from style.css. 
    
    css =
      top: y - tipsyArrowYOffset
      right: $(document).width() - x

    $(@el).html(tooltip_html).css(css).appendTo("body").fadeIn(200)

window.toolTipView = new ToolTipView

previousPointIndex = null

track_hovering = -> mpq.track "Hover over Track", mp_note: "Throttled to once per second"
# Send a hovering ping to mixpanel at most once every second
track_hovering_throttled = _.throttle track_hovering, 1000

$("#flot_container").bind "plothover plotclick", (event, pos, item) ->
  if item # we're overing over a data point
    # Have we already drawn the tooltip?
    return if toolTipView.visible and previousPointIndex == item.seriesIndex
    previousPointIndex = item.seriesIndex
    toolTipView.render item.pageX, item.pageY, item.series.scrobble
    toolTipView.visible = true
    track_hovering_throttled()
  else # we're hovering over whitespace
    toolTipView.remove()
    toolTipView.visible = false

$("#flot_container").mouseout ->
  toolTipView.remove()
  if window.plot? then window.plot.unhighlight()
