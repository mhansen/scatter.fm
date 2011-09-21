FetchThrobberView = Backbone.View.extend
  el: "#fetchThrobber"
  render: -> $(@el).show()
  remove: -> $(@el).hide()
fetchThrobberView = new FetchThrobberView

fetchModel.bind "error", (message) ->
  fetchThrobberView.remove()

fetchModel.bind "change:isFetching", (model) ->
  if model.get("isFetching")
    fetchThrobberView.render()
  else
    fetchThrobberView.remove()
