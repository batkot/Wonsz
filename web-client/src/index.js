require('./static/theme.scss');

const { Elm } = require('./Main.elm');
const env = require('./environment.js');
env.authToken = window.localStorage.getItem("AuthToken");

const initSettings = 
    { 
        node: document.getElementById('elm-container'),
        flags: env
    };
const app = Elm.Main.init(initSettings);

app.ports.setLocalStorageKey.subscribe(function([key, value]) {
    window.localStorage.setItem(key, value);
});
