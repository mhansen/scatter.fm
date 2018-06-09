window.DrawingThrobberView = Backbone.View.extend({
  render() {
    if (graphViewModel.get("isDrawing")) {
      $("#drawingThrobber").show();
      return $("#drawStatus").text(`${scrobbleCollection.size()} scrobbles`);
    } else {
      return $("#drawingThrobber").hide();
    }
  }
});

let drawingThrobberView = new DrawingThrobberView;
    
graphViewModel.on("change:isDrawing", (model, isDrawing) => drawingThrobberView.render());
