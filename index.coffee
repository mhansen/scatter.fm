appModel.bind "change:user", ->
  user = appModel.user()

  redraw_on_response_number = 1
  fetch_scrobbles user

  fetchModel.bind "change:numPagesFetched", ->
    if fetchModel.get("numPagesFetched") == redraw_on_response_number
      # Redrawing is slow as hell, and O(n2) if we draw it n times.
      # So only draw it log2(n) times, for O(nlogn) load times.  Do
      # this by only drawing on response 1, 2, 4, 8, 16... etc until
      # the final response.
      redraw_on_response_number *= 2
      resetAndRedrawScrobbles()

  fetchModel.bind "change:isFetching", (model, wasFetching) ->
    if wasFetching and not model.get("isFetching")
      # force redraw on the last response
      resetAndRedrawScrobbles()

  fetchModel.bind "error", (message) ->
    alert "Last.FM Error: #{message}"
