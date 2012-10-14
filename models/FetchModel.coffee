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
    req1.bind "error", (err) =>
      console.log ":( oh no! an error happened querying last.fm: #{err}"
      @initialize()
    req1.bind "ratelimited", (err) =>
      console.log ":( oh no! an error happened querying last.fm: #{err}"
      @initialize()

    req1.bind "success", (json) =>
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
        req.bind "success", (json) =>
          window.scrobbleCollection.add_from_lastfm_json json
          @set
            lastPageFetched: page
          @get("pagesFetched").push page
          @trigger "newPageFetched"
          if @numPagesFetched() == totalPages
            @set isFetching: false
          console.log "Pages Fetched: ", @get "pagesFetched"
        req.bind "error", (err) =>
          console.log ":( oh no! an error happened querying last.fm: #{err}"
          @initialize()
        req.bind "ratelimited", =>
          console.log "rate limited. :("
          requestQueue.add req # try again later
        requestQueue.add req
