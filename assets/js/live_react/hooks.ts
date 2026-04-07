import React from 'react'
import ReactDOM from 'react-dom/client'
import { getComponentTree } from './utils'
import type { LiveReactHooks } from './utils'
import type { ViewHookInterface } from 'phoenix_live_view'

function getAttributeJson (el: HTMLElement, attributeName: string): Record<string, any> {
  const data = el.getAttribute(attributeName)
  return data
    ? JSON.parse(data)
    : {}
}

function getChildren (hook: {
  el: HTMLElement,
  pushEvent: ViewHookInterface['pushEvent'],
  pushEventTo: ViewHookInterface['pushEventTo'],
  handleEvent: ViewHookInterface['handleEvent'],
  removeHandleEvent: ViewHookInterface['removeHandleEvent'],
  upload: ViewHookInterface['upload'],
  uploadTo: ViewHookInterface['uploadTo'],
}): React.ReactElement[] {
  const dataSlots = getAttributeJson(hook.el, 'data-slots')
  if (!dataSlots?.default) {
    return []
  }

  return [
    React.createElement('div', {
      dangerouslySetInnerHTML: { __html: atob(dataSlots.default).trim() },
    }),
  ]
}

function getProps (hook: LiveReactHooks): LiveReactHooks {
  return {
    el: hook.el,
    ...getAttributeJson(hook.el, 'data-props'),
    liveSocket: hook.liveSocket,
    js: hook.js,
    pushEvent: hook.pushEvent?.bind(hook),
    pushEventTo: hook.pushEventTo?.bind(hook),
    handleEvent: hook.handleEvent?.bind(hook),
    removeHandleEvent: hook.removeHandleEvent?.bind(hook),
    upload: hook.upload?.bind(hook),
    uploadTo: hook.uploadTo?.bind(hook),
    _root: hook._root,
    _Component: hook._Component,
    _render: hook._render ?? undefined,
  }
}

export function getHooks (components: Record<string, React.ComponentType<any>>): { ReactHook: Record<string, any> } {
  const ReactHook = {
    _render (this: LiveReactHooks) {
      const tree = getComponentTree(
        this._Component,
        getProps(this),
        getChildren(this)
      )
      this._root?.render(tree)
    },
    mounted (this: LiveReactHooks) {
      const componentName = this.el.getAttribute('data-name')
      if (!componentName) {
        throw new Error('Component name must be provided')
      }

      this._Component = components[componentName]
      if (!this._Component) {
        throw new Error(`Component '${componentName}' not found in components object`)
      }

      const isSSR = this.el.hasAttribute('data-ssr')

      if (isSSR) {
        const tree = getComponentTree(
          this._Component,
          getProps(this),
          getChildren(this)
        )
        this._root = ReactDOM.hydrateRoot(this.el, tree)
      } else {
        this._root = ReactDOM.createRoot(this.el)
        this._render?.()
      }
    },
    updated (this: LiveReactHooks) {
      if (this._root) {
        this._render?.()
      }
    },
    destroyed (this: LiveReactHooks) {
      if (this._root) {
        window.addEventListener(
          'phx:page-loading-stop',
          () => this._root?.unmount(),
          { once: true }
        )
      }
    },
  }

  return { ReactHook }
}
