import React, { useState } from 'react'

interface FilterSidebarProps {
  availableFilters: Record<string, string[]>
  availableResourceFilters: Record<string, string[]>
  streamOptions: Array<{ id: string; name: string; stream: string }>
  activeStream: string
  onChangeStream: (value: string) => void
  onUpdateFilter: (filterType: string, key: string, action: string, val: string) => void
  onAddColumn: (columnType: string, key: string) => void
}

export function FilterSidebar({
  availableFilters,
  availableResourceFilters,
  streamOptions,
  activeStream,
  onChangeStream,
  onUpdateFilter,
  onAddColumn,
}: FilterSidebarProps) {
  return (
    <div className="w-64 shrink-0 space-y-4 overflow-y-auto">
      <div className="space-y-2">
        <h3 className="text-sm font-semibold">Telemetry Type</h3>
        {streamOptions.map((opt) => (
          <label key={opt.id} className="flex items-center gap-2 text-sm cursor-pointer">
            <input
              type="radio"
              name="stream"
              value={opt.id}
              checked={activeStream === opt.id}
              onChange={() => onChangeStream(opt.id)}
              className="text-blue-600"
            />
            {opt.name}
          </label>
        ))}
      </div>

      <FilterGroup
        title="Attributes"
        filters={availableFilters}
        filterType="attributes"
        columnType="attributes"
        onUpdateFilter={onUpdateFilter}
        onAddColumn={onAddColumn}
      />

      <FilterGroup
        title="Resource Attributes"
        filters={availableResourceFilters}
        filterType="resource"
        columnType="resource"
        onUpdateFilter={onUpdateFilter}
        onAddColumn={onAddColumn}
      />
    </div>
  )
}

function FilterGroup({
  title,
  filters,
  filterType,
  columnType,
  onUpdateFilter,
  onAddColumn,
}: {
  title: string
  filters: Record<string, string[]>
  filterType: string
  columnType: string
  onUpdateFilter: (filterType: string, key: string, action: string, val: string) => void
  onAddColumn: (columnType: string, key: string) => void
}) {
  const entries = Object.entries(filters || {})
  if (entries.length === 0) return null

  return (
    <div className="space-y-2">
      <h3 className="text-sm font-semibold">{title}</h3>
      {entries.map(([key, values]) => (
        <FilterDropdown
          key={key}
          label={key}
          values={Array.isArray(values) ? values : Array.from(values as any)}
          onInclude={(val) => onUpdateFilter(filterType, key, 'include', val)}
          onExclude={(val) => onUpdateFilter(filterType, key, 'exclude', val)}
          onAddColumn={() => onAddColumn(columnType, key)}
        />
      ))}
    </div>
  )
}

function FilterDropdown({
  label,
  values,
  onInclude,
  onExclude,
  onAddColumn,
}: {
  label: string
  values: string[]
  onInclude: (val: string) => void
  onExclude: (val: string) => void
  onAddColumn: () => void
}) {
  const [open, setOpen] = useState(false)
  const [search, setSearch] = useState('')

  const filtered = values.filter((v) => v.toLowerCase().includes(search.toLowerCase()))

  return (
    <div className="border border-zinc-200 dark:border-zinc-600 rounded-md">
      <button
        onClick={() => setOpen(!open)}
        className="flex items-center justify-between w-full px-3 py-2 text-sm text-left hover:bg-zinc-50 dark:hover:bg-zinc-700 transition"
      >
        <span className="truncate font-medium">{label}</span>
        <div className="flex items-center gap-1">
          <button
            onClick={(e) => {
              e.stopPropagation()
              onAddColumn()
            }}
            className="text-xs px-1.5 py-0.5 rounded bg-zinc-200 dark:bg-zinc-600 hover:bg-zinc-300 dark:hover:bg-zinc-500"
            title="Add as column"
          >
            +col
          </button>
          <svg
            className={`w-4 h-4 transition-transform ${open ? 'rotate-180' : ''}`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        </div>
      </button>
      {open && (
        <div className="border-t border-zinc-200 dark:border-zinc-600 p-2 space-y-1 max-h-48 overflow-y-auto">
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search..."
            className="w-full px-2 py-1 text-xs border border-zinc-300 dark:border-zinc-500 rounded bg-transparent"
          />
          {filtered.map((val) => (
            <div key={val} className="flex items-center justify-between text-xs py-0.5">
              <span className="truncate flex-1 mr-2">{val}</span>
              <div className="flex gap-1 shrink-0">
                <button
                  onClick={() => onInclude(val)}
                  className="px-1.5 py-0.5 rounded bg-green-100 text-green-800 hover:bg-green-200 dark:bg-green-900 dark:text-green-300 dark:hover:bg-green-800"
                >
                  +
                </button>
                <button
                  onClick={() => onExclude(val)}
                  className="px-1.5 py-0.5 rounded bg-red-100 text-red-800 hover:bg-red-200 dark:bg-red-900 dark:text-red-300 dark:hover:bg-red-800"
                >
                  −
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
