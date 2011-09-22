FetchThrobberView = Backbone.View.extend
  el: "#fetchThrobber"
  render: ->
    if fetchModel.get "isFetching"
      n = fetchModel.get 'numPagesFetched'
      t = fetchModel.get 'totalPages'
      status = "Fetching... #{n}/#{t} pages done."
      this.$("#fetchStatus").text status
      $(@el).show()
    else
      $(@el).hide()

fetchThrobberView = new FetchThrobberView

fetchModel.bind "change:numPagesFetched", ->
  fetchThrobberView.render()

fetchModel.bind "change:isFetching", (model) ->
  fetchThrobberView.render()
