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

fetchModel.on "newPageFetched", ->
  fetchThrobberView.render()

fetchModel.on "change:isFetching", (model) ->
  if model.get "isFetching"
    fetchThrobberView.render()
  else fetchThrobberView.remove()
