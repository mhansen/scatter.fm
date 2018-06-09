window.Request = Backbone.Model.extend({
  run() {
    return $.ajax({
      url: "http://ws.audioscrobbler.com/2.0/",
      data: {
        method: "user.getrecenttracks",
        user: this.get("user"),
        api_key: "274b18a7aa58eea083ce78c0135953fd",
        format: "json",
        limit: "200",
        page: this.get("page")
      },
      success: json => {
        if (json.error === 29) {
          return this.trigger("ratelimited", json.message);
        } else if (json.error) {
          return this.trigger("error", json.message);
        } else if (json.recenttracks.total === "0") {
          return this.trigger("error", "User has no scrobbles logged.");
        } else {
          return this.trigger("success", json);
        }
      },
      error: (jqXHR, textStatus, errorThrown) => {
        return this.trigger("error", textStatus);
      },
      dataType: "jsonp",
      timeout: 20000
    });
  }
}); // seems reasonable to wait 20s
