AppModel = Backbone.Model.extend
  user: -> @get("user")
  filterTerm: -> @get("filterTerm")
window.appModel = new AppModel

appModel.bind "change", (model) ->
  # fix the path
  path = "/user/" + model.user()
  if model.filterTerm() then path += "/filter/" + model.filterTerm()
  router.navigate path

appModel.bind "change:filterTerm", (model, oldFilterTerm) ->
  resetAndRedrawScrobbles window.scrobbles

appModel.bind "change:user", (model, oldUser) ->
  window.graph_a_user model.user()

$("#userForm").submit (e) ->
  e.preventDefault()
  appModel.set user: $("#userInput").val()

$("#searchForm").submit (e) ->
  e.preventDefault()
  appModel.set filterTerm: $("#search").val()
