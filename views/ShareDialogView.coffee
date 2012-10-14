$("#share_link").click ->
  $("#share_link").select()

$("#share_link").val(document.URL)
$(window).bind "hashchange", -> $("#share_link").val(document.URL)

$("#share-btn").click ->
  $("#share-dialog").toggle()
$("#share-dialog .close").click -> $("#share-dialog").hide()
