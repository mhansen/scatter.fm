window.FetchModel = Backbone.Model.extend
  initialize: ->
    @set
      numPagesFetched: 0
      totalPages: 0
      lastPageFetched: 0
      isFetching: false
  fetch_scrobbles: (username) ->
    if not username then throw "Invalid Username"
    @set isFetching: true

    # fetch first page
    req1 = new Request page: 1, user: username
    requestQueue.add req1
    req1.bind "success", (json) =>
      if json.error
        @trigger "error", json.message
        @initialize() # reset
        return
      if json.recenttracks.total == "0"
        @trigger "error", "User has zero scrobbles."
        @initialize() # reset
        return

      window.scrobbleCollection.add_from_lastfm_json json
      totalPages = parseInt json["recenttracks"]["@attr"]["totalPages"]
      pagesToFetch = [2..totalPages]

      @set
        lastPageFetched: 1
        totalPages: totalPages
        numPagesFetched: 1

      queryFn = =>
        if pagesToFetch.length == 0
          clearInterval(timer)
          return
        page = pagesToFetch.pop()

        isFinalRequest = pagesToFetch.length == 0
        req = new Request page: page, user: username
        requestQueue.add req
        req.bind "success", (json) =>
          window.scrobbleCollection.add_from_lastfm_json json
          @set
            lastPageFetched: page
            numPagesFetched: @get("numPagesFetched") + 1
          # toconsider: what if the final request is lost?
          # we'd never trigger 'finished'
          if isFinalRequest
            @set isFetching: false
      # Drip-feed our queries into the queue, one per second.
      # It's last.fm's api rules, no more than one request per
      # second.
      timer = setInterval queryFn, 1000
