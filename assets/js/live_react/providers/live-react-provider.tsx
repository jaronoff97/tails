import React from 'react'
import { LiveReactContext } from '../contexts/live-react-context'

export function LiveReactProvider ({
  children,
  ...props
}: React.PropsWithChildren<Record<string, unknown>>) {
  return (
    <LiveReactContext.Provider value={props}>
      {children}
    </LiveReactContext.Provider>
  )
}
