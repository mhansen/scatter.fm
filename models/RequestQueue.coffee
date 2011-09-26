window.Request = Backbone.Model.extend
  run: ->
    $.ajax
      url: "http://ws.audioscrobbler.com/2.0/"
      data:
        method: "user.getrecenttracks"
        user: @get "user"
        api_key: "b25b959554ed76058ac220b7b2e0a026"
        format: "json"
        limit: "200"
        page: @get "page"
      success: (json) => @trigger "success", json
      error: (jqXHR, textStatus, errorThrown) => @trigger "error"
      dataType: "jsonp"
      timeout: 20000

InnerQueue = Backbone.Collection.extend()

window.RequestQueue = Backbone.Model.extend
  add: (req) ->
    if @inProgressRequests.size() < @get "max_n_reqs_in_progress"
      @inProgressRequests.add req
    else
      @queuedRequests.add req
  initialize: ->
    @inProgressRequests = new InnerQueue
    @queuedRequests = new InnerQueue

    @inProgressRequests.bind "add", (req) =>
      req.bind "success", => @inProgressRequests.remove req
      req.bind "error", => req.run() # try again
      req.run()

    @inProgressRequests.bind "remove", =>
      return if @queuedRequests.isEmpty()
      req = @queuedRequests.first()
      @queuedRequests.remove req
      @inProgressRequests.add req
