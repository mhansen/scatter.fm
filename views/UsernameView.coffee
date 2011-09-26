UsernameView = Backbone.View.extend
  el: "#user"
  render: -> $(@el).text appModel.get("user")

usernameView = new UsernameView
appModel.bind "change:user", -> usernameView.render()
