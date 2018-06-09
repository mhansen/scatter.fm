$("#userForm").submit(function(e) {
  e.preventDefault();
  let username = $("#userInput").val();
  return document.location.href = `graph.html#/user/${username}`;
});
