$("#share_link").click ->
  $("#share_link").select()
  mpq.track 'Selected Share Link',

$("#share_link").val(document.URL)
$(window).bind "hashchange", -> $("#share_link").val(document.URL)

$("#share-btn").click ->
  mpq.track 'Clicked Share Button',
    mp_note: 'User clicked the Share This Graph button, popping up a dialog.'
  $("#share-dialog").toggle()
$("#share-dialog .close").click -> $("#share-dialog").hide()
