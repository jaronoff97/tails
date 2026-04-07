import React from 'react'

interface DataViewerProps {
  data: any
}

export function DataViewer({ data }: DataViewerProps) {
  if (!data || Object.keys(data).length === 0) {
    return (
      <div className="p-6 text-zinc-400">
        Click a row to view its data.
      </div>
    )
  }

  const formatted = (() => {
    try {
      // Remove resource from the displayed data for cleaner view
      const { resource, ...rest } = data
      return JSON.stringify(rest, null, 2)
    } catch {
      return JSON.stringify(data, null, 2)
    }
  })()

  const attributes = data.attributes || []
  const resourceAttrs = data.resource || []

  return (
    <div className="p-6 space-y-6 dark:text-slate-300">
      {attributes.length > 0 && (
        <div>
          <h3 className="text-sm font-semibold mb-2">Attributes</h3>
          <KeyValueTable entries={attributes} />
        </div>
      )}

      {resourceAttrs.length > 0 && (
        <div>
          <h3 className="text-sm font-semibold mb-2">Resource Attributes</h3>
          <KeyValueTable entries={resourceAttrs} />
        </div>
      )}

      <div>
        <h3 className="text-sm font-semibold mb-2">Raw Data</h3>
        <pre className="bg-zinc-100 dark:bg-zinc-800 rounded-md p-4 text-xs overflow-x-auto whitespace-pre-wrap font-mono max-h-96 overflow-y-auto">
          {formatted}
        </pre>
      </div>
    </div>
  )
}

function KeyValueTable({ entries }: { entries: any[] }) {
  return (
    <table className="w-full text-sm">
      <thead>
        <tr className="border-b border-zinc-200 dark:border-zinc-600">
          <th className="text-left py-1 px-2 font-medium text-zinc-500">Key</th>
          <th className="text-left py-1 px-2 font-medium text-zinc-500">Value</th>
        </tr>
      </thead>
      <tbody>
        {entries.map((entry: any, idx: number) => (
          <tr key={idx} className="border-b border-zinc-100 dark:border-zinc-700">
            <td className="py-1 px-2 font-mono text-xs">{entry.key}</td>
            <td className="py-1 px-2 text-xs">{stringFromValue(entry.value)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}

function stringFromValue(value: any): string {
  if (value == null) return ''
  if (typeof value === 'string') return value
  if (value.stringValue != null) return value.stringValue
  if (value.intValue != null) return String(value.intValue)
  if (value.doubleValue != null) return String(value.doubleValue)
  if (value.boolValue != null) return String(value.boolValue)
  return JSON.stringify(value)
}
