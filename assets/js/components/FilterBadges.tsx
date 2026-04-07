import React from 'react'

interface FilterBadgesProps {
  filters: Record<string, [string, string]>
  resourceFilters: Record<string, [string, string]>
  onRemoveFilter: (key: string, filterType: string) => void
}

export function FilterBadges({ filters, resourceFilters, onRemoveFilter }: FilterBadgesProps) {
  const filterEntries = Object.entries(filters || {})
  const resourceFilterEntries = Object.entries(resourceFilters || {})

  if (filterEntries.length === 0 && resourceFilterEntries.length === 0) return null

  return (
    <div className="py-2">
      <div className="flex flex-wrap gap-2">
        {filterEntries.length > 0 && (
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-sm font-medium text-zinc-500">Attributes:</span>
            {filterEntries.map(([key, [action, val]]) => (
              <Badge
                key={`attr-${key}`}
                label={`${key}:${val}`}
                variant={action}
                onRemove={() => onRemoveFilter(key, 'attributes')}
              />
            ))}
          </div>
        )}
        {resourceFilterEntries.length > 0 && (
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-sm font-medium text-zinc-500">Resource:</span>
            {resourceFilterEntries.map(([key, [action, val]]) => (
              <Badge
                key={`res-${key}`}
                label={`${key}:${val}`}
                variant={action}
                onRemove={() => onRemoveFilter(key, 'resource')}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

function Badge({
  label,
  variant,
  onRemove,
}: {
  label: string
  variant: string
  onRemove: () => void
}) {
  const isInclude = variant === 'include'
  const colors = isInclude
    ? 'text-green-800 bg-green-100 dark:bg-green-900 dark:text-green-300'
    : 'text-red-800 bg-red-100 dark:bg-red-900 dark:text-red-300'
  const btnColors = isInclude
    ? 'text-green-400 hover:bg-green-200 hover:text-green-900 dark:hover:bg-green-800 dark:hover:text-green-300'
    : 'text-red-400 hover:bg-red-200 hover:text-red-900 dark:hover:bg-red-800 dark:hover:text-red-300'

  return (
    <span className={`inline-flex items-center px-2 py-1 text-sm font-medium rounded ${colors}`}>
      {label}
      <button
        type="button"
        onClick={onRemove}
        className={`inline-flex items-center p-1 ms-2 text-sm bg-transparent rounded-sm ${btnColors}`}
      >
        <svg className="w-2 h-2" fill="none" viewBox="0 0 14 14">
          <path
            stroke="currentColor"
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
          />
        </svg>
      </button>
    </span>
  )
}
