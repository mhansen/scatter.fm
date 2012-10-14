FetchThrobberView = Backbone.View.extend
  el: "#fetchThrobber"
  render: ->
    if fetchModel.get "isFetching"
      n = fetchModel.numPagesFetched()
      t = fetchModel.get 'totalPages'
      status = "Fetching your scrobbles... #{n}/#{t} pages done."
      this.$("#fetchStatus").text status
      @$el.show()
    else
      @$el.hide()

fetchThrobberView = new FetchThrobberView

fetchModel.bind "newPageFetched", ->
  fetchThrobberView.render()

fetchModel.bind "change:isFetching", (model) ->
  if model.get "isFetching"
    fetchThrobberView.render()
  else fetchThrobberView.remove()
