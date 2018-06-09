let LAST_FM_API_KEY = "274b18a7aa58eea083ce78c0135953fd";

let m = angular.module('scatter.fm', []);

m.controller('indexCtrl', ($scope, $location) =>
  $scope.visualise = function() {
    if ($scope.username) {
      return $location.path(`/user/${$scope.username}`);
    }
  }
);

m.factory('fetch_page', ($http, $timeout, random) =>
  function(username, page, callback) {
    var backoff_and_try_request = try_num => {
      let try_request = function() {
        let backoff_and_retry = () => backoff_and_try_request(try_num + 1);
        return $http.jsonp("//ws.audioscrobbler.com/2.0/?callback=JSON_CALLBACK", {
          timeout: 20000, // seems reasonable
          params: {
            method: "user.getrecenttracks",
            user: username,
            api_key: LAST_FM_API_KEY,
            format: "json",
            limit: "200",
            page
          }
        }
        ).success(json => {
          switch (false) {
            case json.error !== 29:
              console.log(`ratelimited. backing off - try ${try_num} for this req`);
              return backoff_and_retry(); // ratelimited
            case !json.error:
              return callback(null, `unknown error: ${json.error}`);
            case json.recenttracks.total !== "0":
              return callback(null, "no scrobbles for this user");
            default: return callback(json);
          }
        }).error(() => backoff_and_retry()); // probably a transient error
      };
      // Uncapped randomised exponential decay starting at 100ms
      let wait = 100 * Math.pow(2, try_num) * random();
      return $timeout(try_request, wait);
    };

    return backoff_and_try_request(0);
  }
);

m.factory('fetch_scrobbles', (add_json_to_scrobbles, fetch_page, scrobbles, $rootScope) =>
  username =>
    // fetch the first page
    fetch_page(username, 1, (json, err) => {
      if (err) { throw err; }
      add_json_to_scrobbles(json);
      console.log(scrobbles);

      let totalPages = parseInt(json.recenttracks["@attr"].totalPages);
      if (totalPages === 1) { return; }

      let pages_to_fetch = __range__(2, totalPages, true);

      let in_flight_requests = 0;
      let fetch_another_page = function() {
        in_flight_requests++;
        return fetch_page(username, pages_to_fetch.pop(), function(json, err) {
          if (err) { throw err; }
          add_json_to_scrobbles(json);
          console.log(scrobbles.length);
          return in_flight_requests--;
        });
      };

      return $rootScope.$watch((() => in_flight_requests), function() {
        if ((in_flight_requests < 4) && (pages_to_fetch.length > 0)) {
          return fetch_another_page();
        }
      });
    })
  
);

m.value('scrobbles', []);
m.value('scrobbleStats', {
  minTime: Infinity,
  maxTime: -Infinity
}
);

m.value('random', Math.random);

m.factory('add_json_to_scrobbles', (scrobbles, scrobbleStats) =>
  json =>
    (() => {
      let result = [];
      for (let scrobble of Array.from(json.recenttracks.track)) {
      // Pull out just the information we need, because memory has been known
      // to run out with large datasets (e.g. 5 years of scrobbles). Leave the
      // rest to be GC'd.
      
      // You might think every scrobble has a date, but nope. 'now playing'
      // songs don't have a date, and they can break things. Skip them.
        if ((scrobble['date'] == null)) { continue; }
        let d = new Date(scrobble['date']['uts'] * 1000);
        let date = d.getTime();
        let my_scrobble = {
          track: scrobble['name'],
          artist: scrobble['artist']['#text'],
          album: scrobble['album']['#text'],
          date,
          time: d.getHours() + (d.getMinutes() / 60)
        };
        if (scrobble['image'][1] && scrobble['image'][1]['#text']) {
          my_scrobble.image = scrobble['image'][1]['#text'];
        }

        scrobbles.push(my_scrobble);
        if (date < scrobbleStats.minTime) { scrobbleStats.minTime = date; }
        if (date > scrobbleStats.maxTime) { result.push(scrobbleStats.maxTime = date); } else {
          result.push(undefined);
        }
      }
      return result;
    })()
  
);

m.controller('userCtrl', function(scrobbles, $scope, $location, $routeParams, fetch_scrobbles, scrobbleStats) {
  $scope.username = $routeParams.username;
  scrobbles.length = 0; // clear
  $scope.scrobbles = scrobbles;
  
  if ($scope.username) {
    fetch_scrobbles($scope.username);
  }

  $scope.showFeedback = true;
  $scope.showSearch = true;
  $scope.filterTerm;
  $scope.filterRegex = function() {
    return new RegExp(this.get("filterTerm"), "i");
  };
  $scope.validate = function() {
    try {
      new RegExp($scope.filterTerm, "i");
      return null;
    } catch (error) {
      return `Whoops! That's not a regular expression: ${error}`;
    }
  };

  $scope.svgWidth = 1000;
  $scope.svgHeight = 600;

  $scope.y = scrobble => (scrobble.time / 24) * $scope.svgHeight;
  $scope.x = scrobble =>
     $scope.svgWidth * ((scrobble.date - scrobbleStats.minTime) /
                        (scrobbleStats.maxTime - scrobbleStats.minTime))
   ;

  $scope.activeArtist = null;
  $scope.class = function(scrobble) { if (scrobble.artist === $scope.activeArtist) { return 'active'; } else { return ''; } };
  return $scope.setActiveArtist = function(artist) {
    $scope.activeArtist = artist;
    return console.log($scope.activeArtist);
  };
});


m.directive('scatterSearch', () =>
  ({
    restrict: 'E',
    templateUrl: 'search_directive.html'
  })
);

m.config(function($routeProvider) {
  $routeProvider.when('/', {
    controller: 'indexCtrl',
    templateUrl: 'index_partial.html'
  }
  );
  return $routeProvider.when('/user/:username', {
    controller: 'userCtrl',
    templateUrl: 'user_partial.html'
  }
  );
});

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}