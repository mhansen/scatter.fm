# Last.fm allows 5 reqs per second.
# I set this to 200ms per request, but the browser fell behind on requests and
# queued them up, them bursted through a whole lot of requests faster than
# allowed. I still got rate limited. So I've set it to 500ms, but I still get
# rate limited, but not as often, and the rate limiting goes away after a few
# seconds.
rate_limit_ms = 500

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
