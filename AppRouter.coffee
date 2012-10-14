AppRouter = Backbone.Router.extend
  routes:
    "/user/:user": (user) ->
      appModel.set user: user
    "/user/:user/": (user) ->
      appModel.set user: user
    "/user/:user/filter/:searchterm": (user, filterTerm) ->
      appModel.set
        user: user
        filterTerm: filterTerm
window.router = new AppRouter

Backbone.history.start()
