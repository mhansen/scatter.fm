AppRouter = Backbone.Router.extend
  routes:
    "/user/:user": "load_user"
    "/user/:user/": "load_user"
    "/user/:user/filter/:searchterm": "load_and_search"
  load_user: (user) -> appModel.set user: user
  load_and_search: (user, filterTerm) ->
    appModel.set user: user, filterTerm: filterTerm
window.router = new AppRouter

Backbone.history.start()
