import React from 'react'
import ReactDOM from 'react-dom/client'
import { LiveReactProvider } from './providers/live-react-provider'
import type { ViewHookInterface } from 'phoenix_live_view'

export interface LiveReactHooks extends ViewHookInterface {
  _Component: React.ComponentType<any>,
  _root: ReactDOM.Root,
  _render?: (() => void) | undefined,
}

function getHooks (props: ViewHookInterface) {
  return {
    pushEvent: props.pushEvent,
    pushEventTo: props.pushEventTo,
    handleEvent: props.handleEvent,
    removeHandleEvent: props.removeHandleEvent,
    upload: props.upload,
    uploadTo: props.uploadTo,
  }
}

export function getComponentTree (
  Component: React.ElementType,
  props: ViewHookInterface,
  children: React.ReactNode[]
): React.ReactElement {
  const componentInstance: React.ReactElement = React.createElement(Component, props, ...children)

  return React.createElement(
    LiveReactProvider,
    getHooks(props),
    componentInstance
  )
}
