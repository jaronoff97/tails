import '../css/app.css'

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'

// Establish Phoenix Socket and LiveView configuration.
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import topbar from 'topbar'
import { getHooks } from './live_react'

import { EditorView, basicSetup } from 'codemirror'
import { EditorState, Compartment } from '@codemirror/state'
import * as yamlMode from '@codemirror/legacy-modes/mode/yaml'
import { json } from '@codemirror/lang-json'
import { StreamLanguage } from '@codemirror/language'
import { oneDark } from '@codemirror/theme-one-dark'
import { tomorrow } from 'thememirror'

const yaml = StreamLanguage.define(yamlMode.yaml)
let language = new Compartment, tabSize = new Compartment
let editorTheme = new Compartment()

let state = EditorState.create({
  extensions: [
    basicSetup,
    yaml,
    language.of(json()),
    darkModeEnabled() ? editorTheme.of(oneDark) : tomorrow,
  ],
})

function darkModeEnabled() {
  if (window.matchMedia) {
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return true
    } else {
      return false
    }
  } else {
    return false
  }
}

// React component hooks from live_react
const { ReactHook } = getHooks({
  // Register React components here as they are created
  // e.g. MyComponent: () => import('./components/MyComponent').then(m => m.default)
})

// CodeMirror hooks
const codeMirrorHooks = {
  DataViewer: {
    updated() {
      let textarea = this.el
      let content = textarea.value
      let new_state = this.view.state.update({
        changes: { from: 0, to: this.view.state.doc.length, insert: content },
      })
      this.view.dispatch(new_state)
    },
    mounted() {
      this.view = new EditorView({
        doc: 'data',
        height: 100,
        state: state,
        parent: document.getElementById('data-viewer'),
      })
      let textarea = this.el
      let content = textarea.value
      let new_state = this.view.state.update({
        changes: { from: 0, to: this.view.state.doc.length, insert: content },
      })
      this.view.dispatch(new_state)
    },
  },
  EditorForm: {
    updated() {
      this.view = new EditorView({
        doc: 'config',
        height: 100,
        state: state,
        parent: document.getElementById('editor'),
      })
      let textarea = this.el
      let content = textarea.value
      let new_state = this.view.state.update({
        changes: { from: 0, to: this.view.state.doc.length, insert: content },
      })
      this.view.dispatch(new_state)
    },
  },
}

const hooks = {
  ReactHook,
  ...codeMirrorHooks,
}

const csrfToken = document
  ?.querySelector("meta[name='csrf-token']")
  ?.getAttribute('content')

const liveSocket = new LiveSocket('/live', Socket, {
  hooks: hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', () => topbar.show(300))
window.addEventListener('phx:page-loading-stop', () => topbar.hide())
window.addEventListener('phx:js-exec', ({ detail }) => {
  document.querySelectorAll(detail.to).forEach((el) => {
    liveSocket.execJS(el, el.getAttribute(detail.attr))
  })
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
