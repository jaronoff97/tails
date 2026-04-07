import React from 'react'

interface CollectorPanelProps {
  agent: any
}

export function CollectorPanel({ agent }: CollectorPanelProps) {
  if (!agent?.id) {
    return (
      <div className="p-6 text-zinc-400">
        No agent connected.
      </div>
    )
  }

  const effectiveConfig = getEffectiveConfigBody(agent)

  return (
    <div className="p-6 space-y-6 dark:text-slate-300">
      <div>
        <h2 className="text-lg font-semibold mb-2">
          Collector {agent.id}
        </h2>
      </div>

      {agent.description && (
        <>
          <AttributeTable
            title="Identifying Attributes"
            attributes={agent.description.identifying_attributes}
          />
          <AttributeTable
            title="Non-Identifying Attributes"
            attributes={agent.description.non_identifying_attributes}
          />
        </>
      )}

      {effectiveConfig && (
        <div>
          <h3 className="text-sm font-semibold mb-2">Effective Configuration</h3>
          <pre className="bg-zinc-100 dark:bg-zinc-800 rounded-md p-4 text-xs overflow-x-auto whitespace-pre-wrap font-mono max-h-96 overflow-y-auto">
            {effectiveConfig}
          </pre>
        </div>
      )}
    </div>
  )
}

function AttributeTable({
  title,
  attributes,
}: {
  title: string
  attributes: any[]
}) {
  if (!attributes || attributes.length === 0) return null

  return (
    <div>
      <h3 className="text-sm font-semibold mb-2">{title}</h3>
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-zinc-200 dark:border-zinc-600">
            <th className="text-left py-1 px-2 font-medium text-zinc-500">Key</th>
            <th className="text-left py-1 px-2 font-medium text-zinc-500">Value</th>
          </tr>
        </thead>
        <tbody>
          {attributes.map((attr: any, idx: number) => {
            const key = attr.key || attr['key'] || ''
            const value = extractValue(attr)
            return (
              <tr key={idx} className="border-b border-zinc-100 dark:border-zinc-700">
                <td className="py-1 px-2 font-mono text-xs">{key}</td>
                <td className="py-1 px-2 text-xs">{value}</td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

function extractValue(attr: any): string {
  // Handle proto-converted format: {key, value: {stringValue: "..."}}
  const val = attr.value || attr['value']
  if (val == null) return ''
  if (typeof val === 'string') return val
  if (val.stringValue != null) return val.stringValue
  if (val.intValue != null) return String(val.intValue)
  if (val.doubleValue != null) return String(val.doubleValue)
  if (val.boolValue != null) return String(val.boolValue)
  return JSON.stringify(val)
}

function getEffectiveConfigBody(agent: any): string | null {
  try {
    const configMap = agent.effective_config?.config_map?.config_map
    if (!configMap) return null
    const entry = configMap[''] || Object.values(configMap)[0]
    if (!entry) return null
    return entry.body || entry['body'] || null
  } catch {
    return null
  }
}
