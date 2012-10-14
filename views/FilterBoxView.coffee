FilterBoxView = Backbone.View.extend
  el: "#searchForm"
  render: (isDrawn) ->
    if isDrawn
      $(@el).fadeIn 1000
    else
      $(@el).hide()
  val: -> $("#search").val()

window.filterBoxView = new FilterBoxView

graphViewModel.on "change:isDrawn", (model, isDrawn) ->
  filterBoxView.render isDrawn
