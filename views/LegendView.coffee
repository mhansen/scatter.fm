LegendView = Backbone.View.extend
  el: "#legend_wrap"
  render: ->
    this.$("li").remove()
    artistColors = legendModel.get("artistColors")
    for artist, color of artistColors when color.color != "gray"
      $("<li>")
        .text("#{artist} (#{color.count})")
        .css("color", color.color)
        .appendTo("#legend")
    $("<li>")
      .text("[Other Artists]")
      .css("color", "gray")
      .appendTo("#legend")
    @$el.show()
  remove: ->
    @$el.hide()
  
legendView = new LegendView

legendModel.on "change:artistColors", (model, artistColors) ->
  legendView.render()
