class UsernameView extends Backbone.View {
    render() {
        let user = appModel.get("user");
        $(".user_link").text(user);
        $(".user_link").attr("href", `http://www.last.fm/user/${user}`);
        return this;
    }
}
const usernameView = new UsernameView();
appModel.on("change:user", () => usernameView.render());
