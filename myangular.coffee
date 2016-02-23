LAST_FM_API_KEY = "274b18a7aa58eea083ce78c0135953fd"

m = angular.module 'scatter.fm', []

m.controller 'indexCtrl', ($scope, $location) ->
  $scope.visualise = ->
    if $scope.username
      $location.path "/user/#{$scope.username}"

m.factory 'fetch_page', ($http, $timeout, random) ->
  (username, page, callback) ->
    backoff_and_try_request = (try_num) =>
      try_request = ->
        backoff_and_retry = -> backoff_and_try_request try_num + 1
        $http.jsonp("//ws.audioscrobbler.com/2.0/?callback=JSON_CALLBACK",
          timeout: 20000 # seems reasonable
          params:
            method: "user.getrecenttracks"
            user: username
            api_key: LAST_FM_API_KEY
            format: "json"
            limit: "200"
            page: page
        ).success((json) =>
          switch
            when json.error == 29
              console.log "ratelimited. backing off - try #{try_num} for this req"
              backoff_and_retry() # ratelimited
            when json.error
              callback null, "unknown error: #{json.error}"
            when json.recenttracks.total == "0"
              callback null, "no scrobbles for this user"
            else callback json
        ).error(-> backoff_and_retry()) # probably a transient error
      # Uncapped randomised exponential decay starting at 100ms
      wait = 100 * Math.pow(2, try_num) * random()
      $timeout try_request, wait

    backoff_and_try_request 0

m.factory 'fetch_scrobbles', (add_json_to_scrobbles, fetch_page, scrobbles, $rootScope) ->
  (username) ->
    # fetch the first page
    fetch_page username, 1, (json, err) =>
      throw err if err
      add_json_to_scrobbles json
      console.log scrobbles

      totalPages = parseInt json.recenttracks["@attr"].totalPages
      return if totalPages == 1

      pages_to_fetch = [2..totalPages]

      in_flight_requests = 0
      fetch_another_page = ->
        in_flight_requests++
        fetch_page username, pages_to_fetch.pop(), (json, err) ->
          throw err if err
          add_json_to_scrobbles json
          console.log scrobbles.length
          in_flight_requests--

      $rootScope.$watch((-> in_flight_requests), ->
        if in_flight_requests < 4 and pages_to_fetch.length > 0
          fetch_another_page()
      )

m.value 'scrobbles', []
m.value 'scrobbleStats',
  minTime: Infinity
  maxTime: -Infinity

m.value 'random', Math.random

m.factory 'add_json_to_scrobbles', (scrobbles, scrobbleStats) ->
  (json) ->
    for scrobble in json.recenttracks.track
      # Pull out just the information we need, because memory has been known
      # to run out with large datasets (e.g. 5 years of scrobbles). Leave the
      # rest to be GC'd.
      
      # You might think every scrobble has a date, but nope. 'now playing'
      # songs don't have a date, and they can break things. Skip them.
      continue if not scrobble['date']?
      d = new Date(scrobble['date']['uts'] * 1000)
      date = d.getTime()
      my_scrobble =
        track: scrobble['name']
        artist: scrobble['artist']['#text']
        album: scrobble['album']['#text']
        date: date
        time: d.getHours() + (d.getMinutes() / 60)
      if scrobble['image'][1] && scrobble['image'][1]['#text']
        my_scrobble.image = scrobble['image'][1]['#text']

      scrobbles.push my_scrobble
      scrobbleStats.minTime = date if date < scrobbleStats.minTime
      scrobbleStats.maxTime = date if date > scrobbleStats.maxTime

m.controller 'userCtrl', (scrobbles, $scope, $location, $routeParams, fetch_scrobbles, scrobbleStats) ->
  $scope.username = $routeParams.username
  scrobbles.length = 0 # clear
  $scope.scrobbles = scrobbles
  
  if $scope.username
    fetch_scrobbles $scope.username

  $scope.showFeedback = true
  $scope.showSearch = true
  $scope.filterTerm
  $scope.filterRegex = ->
    new RegExp @get("filterTerm"), "i"
  $scope.validate = ->
    try
      new RegExp $scope.filterTerm, "i"
      return null
    catch error
      return "Whoops! That's not a regular expression: " + error

  $scope.svgWidth = 1000
  $scope.svgHeight = 600

  $scope.y = (scrobble) -> (scrobble.time / 24) * $scope.svgHeight
  $scope.x = (scrobble) ->
     $scope.svgWidth * ((scrobble.date - scrobbleStats.minTime) /
                        (scrobbleStats.maxTime - scrobbleStats.minTime))

  $scope.activeArtist = null
  $scope.class = (scrobble) -> if scrobble.artist == $scope.activeArtist then 'active' else ''
  $scope.setActiveArtist = (artist) ->
    $scope.activeArtist = artist
    console.log($scope.activeArtist)


m.directive 'scatterSearch', ->
  return {
    restrict: 'E'
    templateUrl: 'search_directive.html'
  }

m.config ($routeProvider) ->
  $routeProvider.when '/',
    controller: 'indexCtrl'
    templateUrl: 'index_partial.html'
  $routeProvider.when '/user/:username',
    controller: 'userCtrl'
    templateUrl: 'user_partial.html'
