$("#share_link").click(() => $("#share_link").select());
$("#share_link").val(document.URL);
$(window).on("hashchange", () => $("#share_link").val(document.URL));
$("#share-btn").on("click", () => $("#share-dialog").toggle());
$("#share-dialog .close").on("click", () => $("#share-dialog").hide());
