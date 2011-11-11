$("#userForm").submit (e) ->
  e.preventDefault()
  username = $("#userInput").val()
  document.location.href = "graph.html#/user/#{username}"

$ -> mpq.track "Splash Page"
