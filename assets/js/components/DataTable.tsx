import React from 'react'

interface DataTableProps {
  columns: string[]
  customColumns: string[]
  resourceColumns: string[]
  records: any[]
  remoteTapStarted: boolean
  onRowClick: (row: any) => void
  onRemoveColumn: (column: string, columnType: string) => void
}

export function DataTable({
  columns = [],
  customColumns = [],
  resourceColumns = [],
  records = [],
  remoteTapStarted,
  onRowClick,
  onRemoveColumn,
}: DataTableProps) {
  const customCols = Array.isArray(customColumns) ? customColumns : Array.from(customColumns as any)
  const resourceCols = Array.isArray(resourceColumns)
    ? resourceColumns
    : Array.from(resourceColumns as any)

  if (!remoteTapStarted) {
    return (
      <div className="flex-1 flex items-center justify-center text-zinc-400 dark:text-zinc-500 py-20">
        <p className="text-lg">Toggle Remote Tap or connect via OpAMP to start streaming data.</p>
      </div>
    )
  }

  return (
    <div className="flex-1 overflow-x-auto">
      <table className="w-full text-sm text-left">
        <thead className="text-xs uppercase bg-zinc-50 dark:bg-zinc-800 sticky top-0">
          <tr>
            {columns.map((col) => (
              <th key={col} className="px-3 py-2 font-medium text-zinc-600 dark:text-zinc-300">
                {col}
              </th>
            ))}
            {customCols.map((col) => (
              <th
                key={`custom-${col}`}
                className="px-3 py-2 font-medium text-yellow-600 dark:text-yellow-400"
              >
                <div className="flex items-center gap-1">
                  {col}
                  <button
                    onClick={() => onRemoveColumn(col, 'attributes')}
                    className="text-zinc-400 hover:text-red-500"
                  >
                    ×
                  </button>
                </div>
              </th>
            ))}
            {resourceCols.map((col) => (
              <th
                key={`resource-${col}`}
                className="px-3 py-2 font-medium text-blue-600 dark:text-blue-400"
              >
                <div className="flex items-center gap-1">
                  {col}
                  <button
                    onClick={() => onRemoveColumn(col, 'resource')}
                    className="text-zinc-400 hover:text-red-500"
                  >
                    ×
                  </button>
                </div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-zinc-100 dark:divide-zinc-700">
          {records.map((record, idx) => (
            <tr
              key={record.id || idx}
              onClick={() => onRowClick(record)}
              className="hover:bg-zinc-50 dark:hover:bg-zinc-800 cursor-pointer transition"
            >
              {columns.map((col) => (
                <td key={col} className="px-3 py-2 text-xs truncate max-w-xs">
                  {formatCellValue(record, col)}
                </td>
              ))}
              {customCols.map((col) => (
                <td
                  key={`custom-${col}`}
                  className="px-3 py-2 text-xs truncate max-w-xs text-yellow-700 dark:text-yellow-300"
                >
                  {getAttributeValue(record, 'attributes', col)}
                </td>
              ))}
              {resourceCols.map((col) => (
                <td
                  key={`resource-${col}`}
                  className="px-3 py-2 text-xs truncate max-w-xs text-blue-700 dark:text-blue-300"
                >
                  {getAttributeValue(record, 'resource', col)}
                </td>
              ))}
            </tr>
          ))}
          {records.length === 0 && (
            <tr>
              <td
                colSpan={columns.length + customCols.length + resourceCols.length}
                className="px-3 py-8 text-center text-zinc-400"
              >
                Waiting for data...
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  )
}

function formatCellValue(record: any, column: string): string {
  const val = record[column]
  if (val == null) return ''
  if (typeof val === 'object') return JSON.stringify(val)
  if (column.toLowerCase().includes('time') && typeof val === 'string' && val.length > 10) {
    try {
      const ns = BigInt(val)
      const ms = Number(ns / 1000000n)
      return new Date(ms).toISOString()
    } catch {
      return String(val)
    }
  }
  return String(val)
}

function getAttributeValue(record: any, attrType: string, key: string): string {
  const attrs = record[attrType]
  if (!Array.isArray(attrs)) return ''
  const attr = attrs.find((a: any) => a.key === key)
  if (!attr) return ''
  return stringFromValue(attr.value)
}

function stringFromValue(value: any): string {
  if (value == null) return ''
  if (typeof value === 'string') return value
  if (value.stringValue != null) return value.stringValue
  if (value.intValue != null) return String(value.intValue)
  if (value.doubleValue != null) return String(value.doubleValue)
  if (value.boolValue != null) return String(value.boolValue)
  if (value.bytesValue != null) return value.bytesValue
  if (value.arrayValue != null) return JSON.stringify(value.arrayValue)
  if (value.kvlistValue != null) return JSON.stringify(value.kvlistValue)
  return JSON.stringify(value)
}
