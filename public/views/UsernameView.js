let UsernameView = Backbone.View.extend({
    render() {
        let user = appModel.get("user");
        $(".user_link").text(user);
        $(".user_link").attr("href", `http://www.last.fm/user/${user}`);
    }
});
let usernameView = new UsernameView;
appModel.on("change:user", () => usernameView.render());
