window.Request = Backbone.Model.extend({
  run() {
    return $.ajax({
      url: "https://ws.audioscrobbler.com/2.0/",
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
          this.trigger("ratelimited", json.message);
        } else if (json.error) {
          this.trigger("error", json.message);
        } else if (json.recenttracks.total === "0") {
          this.trigger("error", "User has no scrobbles logged.");
        } else {
          this.trigger("success", json);
        }
      },
      error: (jqXHR, textStatus, errorThrown) => {
        this.trigger("error", textStatus);
      },
      dataType: "jsonp" //, timeout: 20000. Timeout error handling is flawed.
    });
  }
});
