import React, { useEffect, useCallback } from 'react'

interface SlideoverProps {
  open: boolean
  onClose: () => void
  children: React.ReactNode
}

export function Slideover({ open, onClose, children }: SlideoverProps) {
  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    },
    [onClose]
  )

  useEffect(() => {
    if (open) {
      document.addEventListener('keydown', handleKeyDown)
      return () => document.removeEventListener('keydown', handleKeyDown)
    }
  }, [open, handleKeyDown])

  if (!open) return null

  return (
    <div className="relative z-50">
      <div className="fixed inset-0 bg-black/30 transition-opacity" onClick={onClose} />
      <div className="fixed inset-y-0 right-0 flex max-w-full pl-10">
        <div className="w-screen max-w-md transform transition-transform">
          <div className="flex h-full flex-col overflow-y-auto bg-zinc-50 dark:bg-gray-700 shadow-xl">
            <div className="flex items-center justify-between px-4 py-3 border-b border-zinc-200 dark:border-zinc-600">
              <div />
              <button
                onClick={onClose}
                className="rounded-md text-zinc-400 hover:text-zinc-500 dark:hover:text-zinc-300"
              >
                <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
            <div className="flex-1 overflow-y-auto">{children}</div>
          </div>
        </div>
      </div>
    </div>
  )
}
