import { createContext } from 'react'

export const LiveReactContext = createContext<Record<string, unknown> | null>(null)
