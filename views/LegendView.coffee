LegendView = Backbone.View.extend
  el: "#legend_wrap"
  render: ->
    this.$("li").remove()
    artistColors = legendModel.get("artistColors")
    for artist, color of artistColors when color != "gray"
      $("<li>").text(artist).css("color", color).appendTo("#legend")
    $("<li>").text("[Other Artists]").css("color", "gray").appendTo("#legend")
    @$el.show()
  remove: ->
    @$el.hide()
  
legendView = new LegendView

legendModel.bind "change:artistColors", (model, artistColors) ->
  legendView.render()
