FetchModel = Backbone.Model.extend
  initialize: ->
    @set
      numPagesFetched: 0
      totalPages: 0
      lastPageFetched: 0
      isFetching: false

window.fetchModel = new FetchModel
