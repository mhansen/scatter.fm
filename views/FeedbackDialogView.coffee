$("#feedback").on "click", ->
  $("#feedback-dialog").toggle()
$("#feedback-dialog .close").on "click", ->
  $("#feedback-dialog").hide()
