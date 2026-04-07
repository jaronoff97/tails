import { useCallback, useContext } from 'react'
import { LiveReactContext } from '../live_react/contexts/live-react-context'

export type PushEvent = (event: string, payload?: any, callback?: (reply: any) => void) => void
export type HandleEvent = (event: string, callback: (payload: any) => void) => void
export type RemoveHandleEvent = (ref: any) => void

export interface UsePhoenixSocketType {
  pushEvent: PushEvent
  handleEvent: HandleEvent
  removeHandleEvent: RemoveHandleEvent
}

export function usePhoenixSocket(): UsePhoenixSocketType {
  const context = useContext(LiveReactContext)
  if (!context) {
    throw new Error('usePhoenixSocket must be used within a LiveReactProvider')
  }

  const pushEvent = useCallback(
    (event: string, payload: any = {}, callback?: (reply: any) => void) => {
      const fn = context.pushEvent as PushEvent
      fn?.(event, payload, callback)
    },
    [context.pushEvent]
  )

  const handleEvent = useCallback(
    (event: string, callback: (payload: any) => void) => {
      const fn = context.handleEvent as HandleEvent
      fn?.(event, callback)
    },
    [context.handleEvent]
  )

  const removeHandleEvent = useCallback(
    (ref: any) => {
      const fn = context.removeHandleEvent as RemoveHandleEvent
      fn?.(ref)
    },
    [context.removeHandleEvent]
  )

  return { pushEvent, handleEvent, removeHandleEvent }
}
