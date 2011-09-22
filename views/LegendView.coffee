LegendView = Backbone.View.extend
  el: "#legend_wrap"
  render: ->
    $("#legend li").remove()
    artistColors = legendModel.get("artistColors")
    for artist, color of artistColors when color != "gray"
      circle = " \u25CF "
      $("<li></li>").text(artist+circle).css("color", color).appendTo("#legend")

    $("<li></li>").text("[Other]"+circle).css("color", "gray").appendTo("#legend")
    $(@el).show()
  remove: ->
    $(@el).hide()
  
legendView = new LegendView

legendModel.bind "change:artistColors", (model, artistColors) ->
  legendView.render()
