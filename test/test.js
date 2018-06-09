module("RequestQueue");

test("runs a request that's added", function() {
  let requestQueue = new RequestQueue({
    max_n_reqs_in_progress: 1});
  expect(1);
  stop();
  let successfulReq1 = new Request({page: 1, user: "Mark"});
  successfulReq1.run = function() {
    this.trigger("success");
    ok(true);
    return start();
  };
  return requestQueue.add(successfulReq1);
});

test("queues up a second request till the first is done", function() {
  let requestQueue = new RequestQueue({
    max_n_reqs_in_progress: 1});
  expect(7);
  stop();
  let first_is_successful = false;
  let deferredReq = new Request({page: 1, user: "Mark"});
  deferredReq.run = function() {
    return _.defer(() => {
      first_is_successful = true;
      ok(!second_is_successful, "running the 1st req, 2nd hasn't run yet");
      return this.trigger("success");
    });
  };

  ok(requestQueue.inProgressRequests.size() === 0, "0 in progress");
  requestQueue.add(deferredReq);
  ok(requestQueue.inProgressRequests.size() === 1, "1 in progress");

  var second_is_successful = false;
  let req2 = new Request({page: 1, user: "Mark"});
  req2.run = function() {
    second_is_successful = true;
    this.trigger("success");
    ok(first_is_successful, "running the 2nd req, the 1st has already run");
    return start();
  };
  ok(requestQueue.queuedRequests.size() === 0, "0 queued");
  requestQueue.add(req2);
  ok(requestQueue.queuedRequests.size() === 1, "1 queued");
  return ok(!second_is_successful, "second hasn't run yet");
});

test("a failing request is retried till it works", function() {
  let requestQueue = new RequestQueue({
    max_n_reqs_in_progress: 1});
  expect(9);
  stop();

  let i = 0;
  let deferredReq = new Request({page: 1, user: "Mark"});
  deferredReq.run = function() {
    return _.defer(() => {
      i++;
      if ((i === 1) || (i === 2)) { this.trigger("error"); }
      if (i === 3) { return this.trigger("success"); }
    });
  };
  deferredReq.bind("error", () => ok(true, "error triggered"));
  deferredReq.bind("success", function() {
    ok(true, "retried successfully");
    start();
    return _.defer(() => {
      ok(requestQueue.inProgressRequests.size() === 0);
      return ok(requestQueue.queuedRequests.size() === 0);
    });
  });
  ok(requestQueue.inProgressRequests.size() === 0);
  ok(requestQueue.queuedRequests.size() === 0);
  requestQueue.add(deferredReq);
  ok(requestQueue.inProgressRequests.size() === 1);
  return ok(requestQueue.queuedRequests.size() === 0);
});
