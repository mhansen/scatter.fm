window.fetch_scrobbles = (user) ->
  if not user then throw "Invalid Username"
  fetchModel.set isFetching: true

  fetch_scrobble_page = (num, callback) ->
    $.ajax
      url: "http://ws.audioscrobbler.com/2.0/"
      data:
        method: "user.getrecenttracks"
        user: user
        api_key: "b25b959554ed76058ac220b7b2e0a026"
        format: "json"
        limit: "200"
        page: num
      success: callback
      error: (e) -> console.log e #todo, handle properly
      dataType: "jsonp"

  # fetch first page
  fetch_scrobble_page 1, (json) ->
    if json.error
      fetchModel.trigger "error", json.message
      fetchModel.initialize # reset
      return
    if json.recenttracks.total == "0"
      fetchModel.trigger "error", "User has zero scrobbles."
      fetchModel.initialize # reset
      return

    window.scrobbleCollection.add_from_lastfm_json json
    totalPages = parseInt json["recenttracks"]["@attr"]["totalPages"]
    pagesToFetch = [2..totalPages]

    fetchModel.set
      lastPageFetched: 1
      totalPages: totalPages
      numPagesFetched: 1

    queryFn = ->
      if pagesToFetch.length == 0
        clearInterval(timer)
        return
      page = pagesToFetch.pop()

      isFinalRequest = pagesToFetch.length == 0
      fetch_scrobble_page page, (json) ->
        window.scrobbleCollection.add_from_lastfm_json json
        fetchModel.set
          lastPageFetched: page
          numPagesFetched: fetchModel.get("numPagesFetched") + 1
        # toconsider: what if the final request is lost?
        if isFinalRequest
          fetchModel.set isFetching: false
    # limit our queries to one per second
    timer = setInterval queryFn, 1000
