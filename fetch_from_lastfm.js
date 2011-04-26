function fetch_scrobbles(username, callback) {
    if (!username) {
        throw "Invalid Username";
    }
    var scrobbles = [];
    function append_all_scrobbles_in_page(page) {
        _.each(page.recenttracks.track, function(scrobble) {
            scrobbles.push(scrobble);
        });
    }

    var params = {
        method: "user.getrecenttracks",
        user: username,
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
            fetch_scrobble_page(page, function (data, textStatus, jqXHR) {
                append_all_scrobbles_in_page(data);
                callback(scrobbles);
            });
        }, 1000);
    });
}
