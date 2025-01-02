// Last.fm allows 5 reqs per second.
// I set this to 200ms per request, but the browser fell behind on requests and
// queued them up, them bursted through a whole lot of requests faster than
// allowed. I still got rate limited. So I've set it to 500ms, but I still get
// rate limited, but not as often, and the rate limiting goes away after a few
// seconds.
const rate_limit_ms = 500;

class RequestQueue extends Backbone.Model {
  queue: LastFMRequest[] = [];
  currentlyEmptyingQueue = false;

  add(req: LastFMRequest) {
    this.queue.push(req);
    if (!this.currentlyEmptyingQueue) {
      this.doAnotherRequest();
    }
  }

  doAnotherRequest() {
    if (this.queue.length === 0) {
      this.currentlyEmptyingQueue = false;
    } else {
      this.currentlyEmptyingQueue = true;
      setTimeout(() => {
        console.log(new Date + "running delayed request");
        this.queue.shift().run();
        this.doAnotherRequest();
      }, rate_limit_ms);
    }
  }
  numReqsPending() {
    return this.queue.length;
  }
}
