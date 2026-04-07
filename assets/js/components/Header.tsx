import React from 'react'

interface HeaderProps {
  shouldStream: boolean
  remoteTapStarted: boolean
  agent: any
  onToggleStream: () => void
  onToggleRemoteTap: () => void
  onRequestConfig: () => void
  onShowConfig: () => void
}

export function Header({
  shouldStream,
  remoteTapStarted,
  agent,
  onToggleStream,
  onToggleRemoteTap,
  onRequestConfig,
  onShowConfig,
}: HeaderProps) {
  const hasAgent = agent?.id != null

  return (
    <header className="px-4 sm:px-6 lg:px-8">
      <div className="flex items-center justify-between border-b border-zinc-200 dark:border-zinc-600 py-3 text-sm">
        <div className="flex items-center gap-4">
          <a href="/">
            <img src="/images/logo.svg" width="36" alt="Tails" />
          </a>
          <p className="bg-brand/5 text-brand rounded-full px-2 font-medium leading-6">
            OTC Live Tail
          </p>
          <a
            href="https://github.com/jaronoff97/tails"
            className="hover:text-zinc-700 dark:hover:text-zinc-300"
            target="_blank"
            rel="noopener noreferrer"
          >
            <GithubIcon />
          </a>
        </div>

        <div className="flex items-center gap-4">
          <button
            onClick={onToggleStream}
            className="inline-flex items-center gap-2 rounded-md px-3 py-1.5 text-sm font-medium border border-zinc-300 dark:border-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-600 transition"
          >
            {shouldStream ? (
              <>
                <PlayIcon /> Streaming
              </>
            ) : (
              <>
                <PauseIcon /> Paused
              </>
            )}
          </button>

          <label className="inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              className="sr-only peer"
              checked={remoteTapStarted}
              onChange={onToggleRemoteTap}
            />
            <div className="relative w-11 h-6 bg-gray-200 rounded-full peer dark:bg-gray-700 peer-focus:ring-4 peer-focus:ring-green-300 dark:peer-focus:ring-green-800 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-green-600" />
            <span className="ms-3 text-sm">Toggle Remote Tap</span>
          </label>

          {hasAgent ? (
            <span className="inline-flex items-center gap-1 text-green-600 dark:text-green-400 text-sm font-medium">
              <CheckIcon /> Agent Connected
            </span>
          ) : (
            <button
              onClick={onRequestConfig}
              className="inline-flex items-center gap-2 rounded-md px-3 py-1.5 text-sm font-medium border border-zinc-300 dark:border-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-600 transition"
            >
              <RefreshIcon /> Connect via OpAMP
            </button>
          )}

          {hasAgent && (
            <button
              onClick={onShowConfig}
              className="rounded-md px-3 py-1.5 text-sm font-medium hover:bg-zinc-100 dark:hover:bg-zinc-600 transition"
            >
              Show Config
            </button>
          )}
        </div>
      </div>
    </header>
  )
}

function PlayIcon() {
  return (
    <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
      <path
        fillRule="evenodd"
        d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z"
        clipRule="evenodd"
      />
    </svg>
  )
}

function PauseIcon() {
  return (
    <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
      <path
        fillRule="evenodd"
        d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z"
        clipRule="evenodd"
      />
    </svg>
  )
}

function RefreshIcon() {
  return (
    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
        d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
      />
    </svg>
  )
}

function CheckIcon() {
  return (
    <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
      <path
        fillRule="evenodd"
        d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
        clipRule="evenodd"
      />
    </svg>
  )
}

function GithubIcon() {
  return (
    <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
      <path
        fillRule="evenodd"
        d="M12.006 2a9.847 9.847 0 00-6.484 2.44 10.32 10.32 0 00-3.393 6.17 10.48 10.48 0 001.317 6.955 10.045 10.045 0 005.4 4.418c.504.095.683-.223.683-.494 0-.245-.01-1.052-.014-1.908-2.78.62-3.366-1.21-3.366-1.21a2.711 2.711 0 00-1.11-1.5c-.907-.637.07-.621.07-.621.317.044.62.163.885.346.266.183.487.426.647.71.135.253.318.476.538.655a2.079 2.079 0 002.37.196c.045-.52.27-1.006.635-1.37-2.219-.259-4.554-1.138-4.554-5.07a4.022 4.022 0 011.031-2.75 3.77 3.77 0 01.096-2.713s.839-.275 2.749 1.05a9.26 9.26 0 015.004 0c1.906-1.325 2.74-1.05 2.74-1.05.37.858.406 1.828.101 2.713a4.017 4.017 0 011.029 2.75c0 3.939-2.339 4.805-4.564 5.058a2.471 2.471 0 01.679 1.897c0 1.372-.012 2.477-.012 2.814 0 .272.18.592.687.492a10.05 10.05 0 005.388-4.421 10.473 10.473 0 001.313-6.948 10.32 10.32 0 00-3.39-6.165A9.847 9.847 0 0012.007 2z"
        clipRule="evenodd"
      />
    </svg>
  )
}
