window.FetchModel = Backbone.Model.extend
  initialize: ->
    @set
      pagesFetched: []
      totalPages: 0
      lastPageFetched: 0
      isFetching: false
  numPagesFetched: -> @get("pagesFetched").length

  fetch_scrobbles: (username) ->
    if not username then throw "Invalid Username"
    @set isFetching: true

    # fetch first page
    req1 = new Request
      page: 1
      user: username
    requestQueue.add req1
    req1.on "error", (err) =>
      console.log ":( oh no! an error happened querying last.fm: #{err}"
      @initialize()
    req1.on "ratelimited", (err) =>
      console.log ":( oh no! an error happened querying last.fm: #{err}"
      @initialize()

    req1.on "success", (json) =>
      window.scrobbleCollection.add_from_lastfm_json json
      totalPages = parseInt json.recenttracks["@attr"].totalPages

      @set
        lastPageFetched: 1
        totalPages: totalPages
        pagesFetched: [1]
      @trigger "newPageFetched"

      if totalPages == 1
        @set isFetching: false
        return

      for page in [totalPages..2]
        req = new Request page: page, user: username
        req.on "success", (json) =>
          window.scrobbleCollection.add_from_lastfm_json json
          @set
            lastPageFetched: page
          @get("pagesFetched").push page
          @trigger "newPageFetched"
          if @numPagesFetched() == totalPages
            @set isFetching: false
          console.log "Pages Fetched: ", @get "pagesFetched"
        req.on "error", (err) =>
          console.log ":( oh no! an error happened querying last.fm: #{err}"
          @initialize()
        req.on "ratelimited", =>
          console.log "rate limited. :("
          requestQueue.add req # try again later
        requestQueue.add req
