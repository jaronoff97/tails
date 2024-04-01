// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
// import "./user_socket.js"
import topbar from "../vendor/topbar";

import { EditorView, basicSetup } from "codemirror";
import { EditorState, Compartment } from "@codemirror/state";
import * as yamlMode from "@codemirror/legacy-modes/mode/yaml";
import { json } from "@codemirror/lang-json"
import { StreamLanguage } from "@codemirror/language";

const yaml = StreamLanguage.define(yamlMode.yaml);
let language = new Compartment, tabSize = new Compartment

let state = EditorState.create({
  extensions: [basicSetup, yaml, language.of(json())],
});

hooks = {
  DataViewer: {
    updated() {
      let textarea = this.el;
      let content = textarea.value;
      let new_state = this.view.state.update({
        changes: { from: 0, to: this.view.state.doc.length, insert: content },
      });
      this.view.dispatch(new_state);
    },
    mounted() {
      this.view = new EditorView({
        doc: "data",
        height: 100,
        state: state,
        parent: document.getElementById("data-viewer"),
      });
      let textarea = this.el;

      // Initialise the editor with the content from the form's textarea
      let content = textarea.value;
      let new_state = this.view.state.update({
        changes: { from: 0, to: this.view.state.doc.length, insert: content },
      });
      this.view.dispatch(new_state);
    },
  },
  EditorForm: {
    updated() {
      this.view = new EditorView({
        doc: "config",
        height: 100,
        state: state,
        parent: document.getElementById("editor"),
      });
      let textarea = this.el;

      // Initialise the editor with the content from the form's textarea
      let content = textarea.value;
      let new_state = this.view.state.update({
        changes: { from: 0, to: this.view.state.doc.length, insert: content },
      });
      this.view.dispatch(new_state);
    },
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());
window.addEventListener("phx:js-exec", ({ detail }) => {
  document.querySelectorAll(detail.to).forEach((el) => {
    liveSocket.execJS(el, el.getAttribute(detail.attr));
  });
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
