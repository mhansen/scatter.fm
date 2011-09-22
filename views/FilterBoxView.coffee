FilterBoxView = Backbone.View.extend
  el: "#searchForm"
  render: -> $(@el).fadeIn 1000
  remove: -> $(@el).hide()

filterBoxView = new FilterBoxView

graphViewModel.bind "change:isDrawn", (model, isDrawn) ->
  if isDrawn
    filterBoxView.render()
  else
    filterBoxView.remove()

