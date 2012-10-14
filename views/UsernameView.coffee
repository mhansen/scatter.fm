UsernameView = Backbone.View.extend
  render: ->
    user = appModel.get("user")
    $(".user_link").text user
    $(".user_link").attr "href", "http://www.last.fm/user/#{user}"

usernameView = new UsernameView
appModel.bind "change:user", -> usernameView.render()
