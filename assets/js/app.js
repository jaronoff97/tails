import '../css/app.css'

import 'phoenix_html'
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import topbar from 'topbar'
import { getHooks } from './live_react'

import { TailsApp } from './pages/TailsApp'

const hooks = {
  ...getHooks({
    TailsApp,
  }),
}

const csrfToken = document
  ?.querySelector("meta[name='csrf-token']")
  ?.getAttribute('content')

const liveSocket = new LiveSocket('/live', Socket, {
  hooks: hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
})

topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', () => topbar.show(300))
window.addEventListener('phx:page-loading-stop', () => topbar.hide())

liveSocket.connect()

window.liveSocket = liveSocket
