# Last.fm allows 5 reqs per second.
# 1 request per 200ms.
rate_limit_ms = 200

window.RequestQueue = Backbone.Model.extend
  initialize: ->
    @queue = []
    @currentlyEmptyingQueue = false
  add: (req) ->
    @queue.push req
    if not @currentlyEmptyingQueue
      @doAnotherRequest()
  doAnotherRequest: ->
    if @queue.length == 0
      @currentlyEmptyingQueue = false
    else
      @currentlyEmptyingQueue = true
      _.delay( =>
        console.log new Date + "running delayed request"
        @queue.shift().run()
        @doAnotherRequest()
      , rate_limit_ms)
  numReqsPending: ->
    @queue.size()
