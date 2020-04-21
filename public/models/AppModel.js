// Global state that I couldn't find a more specific place for
// It's all used to form the path of the URL.
window.AppModel = Backbone.Model.extend({
  user() { return this.get("user"); },
  initialize() {
    this.set({ user: null });
    this.set({ filterTerm: "" });
  },
  filterRegex() { return new RegExp(this.get("filterTerm"), "i"); },
  validate(attrs) {
    try {
      new RegExp(attrs.filterTerm, "i");
      return null;
    } catch (error) {
      return `Whoops! That's not a regular expression: ${error}`;
    }
  }
});
