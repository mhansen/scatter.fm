(function() {
  var LastFmLinkView, UsernameView, lastFmLinkView, usernameView;
  UsernameView = Backbone.View.extend({
    el: "#user",
    render: function() {
      return $(this.el).text(appModel.get("user"));
    }
  });
  usernameView = new UsernameView;
  appModel.bind("change:user", function() {
    return usernameView.render();
  });
  LastFmLinkView = Backbone.View.extend({
    el: "#lastfm_link",
    render: function() {
      var user;
      user = appModel.get("user");
      return $(this.el).attr("href", "http://www.last.fm/user/" + user);
    }
  });
  lastFmLinkView = new LastFmLinkView;
  appModel.bind("change:user", function() {
    return lastFmLinkView.render();
  });
}).call(this);
