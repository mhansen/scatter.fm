function fetch_scrobbles(args) {
    if (!args.user) {
        throw "Invalid Username";
    }
    var scrobbles = [];
    function append_all_scrobbles_in_page(page) {
        _.each(page.recenttracks.track, function(scrobble) {
            // Pull out just the information we need, because memory can run
            // out with large datasets.
            var my_scrobble = {
                track: scrobble['name'],
                artist: scrobble['artist']['#text'],
                album: scrobble['album']['#text'],
                date: new Date(scrobble['date']['uts'] * 1000),
            }
            if (scrobble['image'][1] && scrobble['image'][1]['#text']) {
                my_scrobble.image = scrobble['image'][1]['#text'];
            }
            scrobbles.push(my_scrobble);
        });
    }

    var params = {
        method: "user.getrecenttracks",
        user: args.user,
        api_key: "b25b959554ed76058ac220b7b2e0a026",
        format: "json",
        limit: "200" 
    };
    var url = "http://ws.audioscrobbler.com/2.0/";

    function fetch_scrobble_page(num, callback) {
        console.log('Fetching page '+ num);
        params['page'] = num;
        $.ajax({
            url: url,
            data: params,
            success: callback,
            error: _.bind(console.log, console), //todo, handle properly
            dataType: "jsonp"
        });
    }

    // fetch first page
    fetch_scrobble_page(1, function (data, textStatus, jqXHR) {
        if (data.error) {
            return args.onerror(data.error, data.message);
        }
        if (data.recenttracks.total == "0") {
            return args.onerror(null, "User has zero scrobbles.");
        }
        append_all_scrobbles_in_page(data);
        var totalPages = parseInt(data["recenttracks"]["@attr"]["totalPages"]);
        console.log(totalPages + " pages total.");
        var pagesToFetch = _.range(2, totalPages + 1);

        // limit our queries to one per second
        var timer = setInterval(function() {
            if (pagesToFetch.length == 0) {
                clearInterval(timer);
                return;
            }
            var page = pagesToFetch.pop();
            var finalRequest = pagesToFetch.length == 0;
            fetch_scrobble_page(page, function (data, textStatus, jqXHR) {
                append_all_scrobbles_in_page(data);
                if (finalRequest) {
                    args.onfinished(scrobbles); // toconsider: what if the final request is lost
                } else {
                    args.onprogress({
                        scrobbles: scrobbles,
                        thisPage: page,
                        totalPages: totalPages
                    });
                }
            });
        }, 1000);
    });
}
