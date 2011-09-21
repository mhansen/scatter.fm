UsernameView = Backbone.View.extend
  el: "#user"
  render: -> $(@el).text appModel.get("user")

usernameView = new UsernameView
appModel.bind "change:user", -> usernameView.render()

LastFmLinkView = Backbone.View.extend
  el: "#lastfm_link"
  render: ->
    user = appModel.get "user"
    $(@el).attr "href", "http://www.last.fm/user/#{user}"

lastFmLinkView = new LastFmLinkView
appModel.bind "change:user", -> lastFmLinkView.render()
