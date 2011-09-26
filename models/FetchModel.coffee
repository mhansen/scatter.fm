FetchModel = Backbone.Model.extend
  initialize: ->
    @set
      numPagesFetched: 0
      totalPages: 0
      lastPageFetched: 0
      isFetching: false
  fetch_scrobbles: (username) ->
    if not username then throw "Invalid Username"
    @set isFetching: true

    fetch_scrobble_page = (num, callback, second_try) ->
      $.ajax
        url: "http://ws.audioscrobbler.com/2.0/"
        data:
          method: "user.getrecenttracks"
          user: username
          api_key: "b25b959554ed76058ac220b7b2e0a026"
          format: "json"
          limit: "200"
          page: num
        success: callback
        error: (jqXHR, textStatus, errorThrown) ->
          if second_try
            console.log "retried req##{num} and failed, giving up"
            return
          # retry the request once
          console.log "failed once. retrying req##{num}"
          fetch_scrobble_page(num, callback, true)
        dataType: "jsonp"
        timeout: 20000

    # fetch first page
    fetch_scrobble_page 1, (json) =>
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
        fetch_scrobble_page page, (json) =>
          window.scrobbleCollection.add_from_lastfm_json json
          @set
            lastPageFetched: page
            numPagesFetched: @get("numPagesFetched") + 1
          # toconsider: what if the final request is lost?
          # we'd never trigger 'finished'
          if isFinalRequest
            @set isFetching: false
      # limit our queries to one per second
      timer = setInterval queryFn, 1000

window.fetchModel = new FetchModel

fetchModel.bind "error", (message) ->
  alert "Last.FM Error: #{message}"
