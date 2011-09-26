DrawingThrobberView = Backbone.View.extend
  render: ->
    $("#drawingThrobber").show()
    $("#drawStatus").text "#{scrobbleCollection.size()} scrobbles"
  remove: ->
    $("#drawingThrobber").hide()

drawingThrobberView = new DrawingThrobberView
    
graphViewModel.bind "change:isDrawing", (model, isDrawing) ->
  if isDrawing
    drawingThrobberView.render()
  else
    drawingThrobberView.remove()
