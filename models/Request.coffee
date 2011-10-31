window.Request = Backbone.Model.extend
  run: ->
    $.ajax
      url: "http://ws.audioscrobbler.com/2.0/"
      data:
        method: "user.getrecenttracks"
        user: @get "user"
        api_key: "b25b959554ed76058ac220b7b2e0a026"
        format: "json"
        limit: "200"
        page: @get "page"
      success: (json) =>
        if json.error == 29
          @trigger "ratelimited", json.message
        else if json.error
          @trigger "error", json.message
        else if json.recenttracks.total == "0"
          @trigger "error", "User has no scrobbles logged."
        else
          @trigger "success", json
      error: (jqXHR, textStatus, errorThrown) =>
        @trigger "error", textStatus
      dataType: "jsonp"
      timeout: 20000 # seems reasonable to wait 20s
