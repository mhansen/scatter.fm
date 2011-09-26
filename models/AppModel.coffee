# Global state that I couldn't find a more specific place for
# It's all used to form the path of the URL.
AppModel = Backbone.Model.extend
  user: -> @get "user"
  initialize: ->
    @set user: null
    @set filterTerm: ""
  filterRegex: -> new RegExp @get("filterTerm"), "i"
  validate: (attrs) ->
    try
      new RegExp attrs.filterTerm, "i"
      return null
    catch error
      return "Whoops! That's not a regular expression: " + error

window.appModel = new AppModel

appModel.bind "change", (model) ->
  path = "/"
  if model.user()
    # Update the URL path
    path = "/user/" + model.user()
    if model.get("filterTerm")
      path += "/filter/" + model.get("filterTerm")
  router.navigate path

$("#searchForm").submit (e) ->
  e.preventDefault()
  appModel.set filterTerm: filterBoxView.val()

appModel.bind "change:user", ->
  if appModel.user()
    fetchModel.fetch_scrobbles appModel.user()
