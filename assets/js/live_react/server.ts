import React from 'react'
import { renderToString } from 'react-dom/server'
import { getComponentTree } from './utils'
import type { ViewHookInterface } from 'phoenix_live_view'

function getChildren (slots: Record<string, string>): React.ReactElement[] {
  if (!slots?.default) {
    return []
  }

  return [
    React.createElement('div', {
      dangerouslySetInnerHTML: { __html: slots.default.trim() },
    }),
  ]
}

export function getRender (
  components: Record<string, React.ComponentType<unknown>>
): (name: string, props: ViewHookInterface, slots: Record<string, string>) => string {
  return function render (name: string, props: ViewHookInterface, slots: Record<string, string>): string {
    const Component = components[name]
    if (!Component) {
      throw new Error(`Component '${name}' not found`)
    }
    const children = getChildren(slots)
    const tree = getComponentTree(Component, props, children)

    return renderToString(tree)
  }
}
