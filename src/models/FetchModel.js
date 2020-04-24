window.FetchModel = Backbone.Model.extend({
  initialize() {
    this.set({
      pagesFetched: [],
      totalPages: 0,
      lastPageFetched: 0,
      isFetching: false
    });
  },
  numPagesFetched() { return this.get("pagesFetched").length; },

  fetch_scrobbles(username) {
    if (!username) { throw "Invalid Username"; }
    this.set({ isFetching: true });

    // fetch first page
    let req1 = new Request({
      page: 1,
      user: username
    });
    requestQueue.add(req1);
    req1.on("error", err => {
      console.error(`:( oh no! an error happened querying last.fm: ${err}`);
    });
    req1.on("ratelimited", err => {
      console.error("rate limited. :(");
    });

    req1.on("success", json => {
      window.scrobbleCollection.add_from_lastfm_json(json);
      let totalPages = parseInt(json.recenttracks["@attr"].totalPages);

      this.set({
        lastPageFetched: 1,
        totalPages,
        pagesFetched: [1]
      });
      this.trigger("newPageFetched");

      if (totalPages === 1) {
        this.set({ isFetching: false });
        return;
      }

      (() => {
        for (var page = totalPages, asc = totalPages <= 2; asc ? page <= 2 : page >= 2; asc ? page++ : page--) {
          var req = new Request({ page, user: username });
          req.on("success", json => {
            window.scrobbleCollection.add_from_lastfm_json(json);
            this.set({
              lastPageFetched: page
            });
            this.get("pagesFetched").push(page);
            this.trigger("newPageFetched");
            if (this.numPagesFetched() === totalPages) {
              this.set({ isFetching: false });
            }
            console.log("Pages Fetched: ", this.get("pagesFetched"));
          });
          req.on("error", err => {
            console.error(`:( oh no! an error happened querying last.fm: ${err}`);
          });
          req.on("ratelimited", () => {
            console.warning("rate limited. :(");
            requestQueue.add(req);
          }); // try again later
          requestQueue.add(req);
        }
      })();
    });
  }
});
