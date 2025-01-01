class DrawingThrobberView extends Backbone.View {
    render() {
        if (graphViewModel.get("isDrawing")) {
            $("#drawingThrobber").show();
            $("#drawStatus").text(`${scrobbleCollection.size()} scrobbles`);
        }
        else {
            $("#drawingThrobber").hide();
        }
        return this;
    }
}
const drawingThrobberView = new DrawingThrobberView();
graphViewModel.on("change:isDrawing", (model, isDrawing) => drawingThrobberView.render());
