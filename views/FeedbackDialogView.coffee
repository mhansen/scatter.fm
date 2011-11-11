$("#feedback").click ->
  mpq.track 'clicked on "Give Feedback"'
  $("#feedback-dialog").toggle()
$("#feedback-dialog .close").click -> $("#feedback-dialog").hide()
