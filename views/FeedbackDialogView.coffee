$("#feedback").click ->
  $("#feedback-dialog").toggle()
$("#feedback-dialog .close").click -> $("#feedback-dialog").hide()
