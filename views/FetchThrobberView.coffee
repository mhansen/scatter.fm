FetchThrobberView = Backbone.View.extend
  el: "#fetchThrobber"
  render: ->
    if fetchModel.get "isFetching"
      status = "Fetching... #{fetchModel.get('numPagesFetched')} pages done."
      this.$("#fetchStatus").text status
      $(@el).show()
    else
      $(@el).hide()

fetchThrobberView = new FetchThrobberView

fetchModel.bind "change:numPagesFetched", ->
  fetchThrobberView.render()

fetchModel.bind "change:isFetching", (model) ->
  fetchThrobberView.render()
