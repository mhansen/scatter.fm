// Last.fm allows 5 reqs per second.
// I set this to 200ms per request, but the browser fell behind on requests and
// queued them up, them bursted through a whole lot of requests faster than
// allowed. I still got rate limited. So I've set it to 500ms, but I still get
// rate limited, but not as often, and the rate limiting goes away after a few
// seconds.
let rate_limit_ms = 500;

window.RequestQueue = Backbone.Model.extend({
  initialize() {
    this.queue = [];
    this.currentlyEmptyingQueue = false;
  },
  add(req) {
    this.queue.push(req);
    if (!this.currentlyEmptyingQueue) {
      this.doAnotherRequest();
    }
  },
  doAnotherRequest() {
    if (this.queue.length === 0) {
      this.currentlyEmptyingQueue = false;
    } else {
      this.currentlyEmptyingQueue = true;
      _.delay( () => {
        console.log(new Date + "running delayed request");
        this.queue.shift().run();
        return this.doAnotherRequest();
      }
      , rate_limit_ms);
    }
  },
  numReqsPending() {
    return this.queue.size();
  }
});
