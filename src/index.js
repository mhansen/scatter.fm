$("#userForm").submit(function (e) {
  e.preventDefault();
  let username = $("#userInput").val();
  document.location.href = `graph.html#/user/${username}`;
});
