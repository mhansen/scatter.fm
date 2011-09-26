# Global state that I couldn't find a more specific place for
# It's all used to form the path of the URL.
window.AppModel = Backbone.Model.extend
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
