window.scrobbles = []
window.fetch_scrobbles = (args) ->
    if not args.user then throw "Invalid Username"

    append_all_scrobbles_in_page = (page) ->
        for scrobble in page.recenttracks.track
            # Pull out just the information we need, because memory can run
            # out with large datasets.
            if not scrobble['date']? then continue # 'now playing' songs don't have a date
            my_scrobble = {
                track: scrobble['name']
                artist: scrobble['artist']['#text']

                album: scrobble['album']['#text']
                date: new Date(scrobble['date']['uts'] * 1000)
            }
            if scrobble['image'][1] && scrobble['image'][1]['#text']
                my_scrobble.image = scrobble['image'][1]['#text']
            window.scrobbles.push(my_scrobble)

    params = {
        method: "user.getrecenttracks"
        user: args.user
        api_key: "b25b959554ed76058ac220b7b2e0a026"
        format: "json"
        limit: "200"
    }
    url = "http://ws.audioscrobbler.com/2.0/"

    fetch_scrobble_page = (num, callback) ->
        params['page'] = num
        $.ajax {
            url: url
            data: params
            success: callback
            error: (e) -> console.log e #todo, handle properly
            dataType: "jsonp"
        }

    # fetch first page
    fetch_scrobble_page 1, (data, textStatus, jqXHR) ->
        return args.onerror(data.error, data.message) if data.error
        return args.onerror(null, "User has zero scrobbles.") if data.recenttracks.total == "0"

        append_all_scrobbles_in_page data
        totalPages = parseInt data["recenttracks"]["@attr"]["totalPages"]
        pagesToFetch = [2..totalPages]

        # limit our queries to one per second
        timer = setInterval () ->
            if pagesToFetch.length == 0
                clearInterval(timer)
                return
            page = pagesToFetch.pop()
            is_final_request = pagesToFetch.length == 0
            fetch_scrobble_page page, (data, textStatus, jqXHR) ->
                append_all_scrobbles_in_page data
                    # toconsider: what if the final request is lost
                if is_final_request
                then args.onfinished scrobbles
                else args.onprogress {
                        scrobbles: scrobbles
                        thisPage: page
                        totalPages: totalPages
                    }
        , 1000
