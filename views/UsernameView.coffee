UsernameView = Backbone.View.extend
  el: "#user_link"
  render: ->
    user = appModel.get("user")
    $(@el).text user
    $(@el).attr "href", "http://www.last.fm/user/#{user}"

usernameView = new UsernameView
appModel.bind "change:user", -> usernameView.render()
