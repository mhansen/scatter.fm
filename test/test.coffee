module "RequestQueue"

test "runs a request that's added", ->
  requestQueue = new RequestQueue
    max_n_reqs_in_progress: 1
  expect 1
  stop()
  successfulReq1 = new Request page: 1, user: "Mark"
  successfulReq1.run = ->
    @trigger "success"
    ok true
    start()
  requestQueue.add successfulReq1

test "queues up a second request till the first is done", ->
  requestQueue = new RequestQueue
    max_n_reqs_in_progress: 1
  expect 7
  stop()
  first_is_successful = false
  deferredReq = new Request page: 1, user: "Mark"
  deferredReq.run = ->
    _.defer =>
      first_is_successful = true
      ok not second_is_successful, "running the 1st req, 2nd hasn't run yet"
      @trigger "success"

  ok requestQueue.inProgressRequests.size() == 0, "0 in progress"
  requestQueue.add deferredReq
  ok requestQueue.inProgressRequests.size() == 1, "1 in progress"

  second_is_successful = false
  req2 = new Request page: 1, user: "Mark"
  req2.run = ->
    second_is_successful = true
    @trigger "success"
    ok first_is_successful, "running the 2nd req, the 1st has already run"
    start()
  ok requestQueue.queuedRequests.size() == 0, "0 queued"
  requestQueue.add req2
  ok requestQueue.queuedRequests.size() == 1, "1 queued"
  ok not second_is_successful, "second hasn't run yet"

test "a failing request is retried till it works", ->
  requestQueue = new RequestQueue
    max_n_reqs_in_progress: 1
  expect 9
  stop()

  i = 0
  deferredReq = new Request page: 1, user: "Mark"
  deferredReq.run = ->
    _.defer =>
      i++
      @trigger "error" if i == 1 or i == 2
      @trigger "success" if i == 3
  deferredReq.bind "error", ->
    ok true, "error triggered"
  deferredReq.bind "success", ->
    ok true, "retried successfully"
    start()
    _.defer =>
      ok requestQueue.inProgressRequests.size() == 0
      ok requestQueue.queuedRequests.size() == 0
  ok requestQueue.inProgressRequests.size() == 0
  ok requestQueue.queuedRequests.size() == 0
  requestQueue.add deferredReq
  ok requestQueue.inProgressRequests.size() == 1
  ok requestQueue.queuedRequests.size() == 0
