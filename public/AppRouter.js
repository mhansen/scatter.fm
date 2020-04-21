let AppRouter = Backbone.Router.extend({
  routes: {
    "user/:user": "user",
    "user/:user/": "user",
    "user/:user/filter/:searchterm": "search"
  }
});
window.router = new AppRouter;

router.on("route:user", user => appModel.set({ user }));

router.on("route:search", (user, filterTerm) =>
  appModel.set({
    user,
    filterTerm
  })
);

Backbone.history.start();
