var app = Elm.Main.fullscreen();
app.ports.fromElm.subscribe(function (data) {
    console.log((new Date()).toISOString(), "fromElm ->", JSON.stringify(data, null, "  "));
});

var msg = {
    msg: "Ping",
};
console.log((new Date()).toISOString(), "toElm ->", JSON.stringify(msg, null, "  "));
app.ports.toElm.send(msg);
