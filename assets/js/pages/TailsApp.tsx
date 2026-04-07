import React, { useState, useEffect, useCallback } from 'react'
import { usePhoenixSocket } from '../hooks/use-phoenix-socket'
import { Header } from '../components/Header'
import { FilterBadges } from '../components/FilterBadges'
import { FilterSidebar } from '../components/FilterSidebar'
import { DataTable } from '../components/DataTable'
import { Slideover } from '../components/Slideover'
import { CollectorPanel } from '../components/CollectorPanel'
import { DataViewer } from '../components/DataViewer'

const MAX_RECORDS = 1000

interface TailsAppProps {
  // Initial state passed from LiveView as props
  stream_options: Array<{ id: string; name: string; stream: string }>
  columns: Record<string, string[]>
}

export function TailsApp({ stream_options = [], columns = {} }: TailsAppProps) {
  const { pushEvent, handleEvent } = usePhoenixSocket()

  // UI state
  const [collectorOpen, setCollectorOpen] = useState(false)
  const [rowDataOpen, setRowDataOpen] = useState(false)
  const [selectedRow, setSelectedRow] = useState<any>(null)

  // Server-synced state
  const [shouldStream, setShouldStream] = useState(true)
  const [remoteTapStarted, setRemoteTapStarted] = useState(false)
  const [activeStream, setActiveStream] = useState('spans')
  const [agent, setAgent] = useState<any>({})
  const [customColumns, setCustomColumns] = useState<string[]>([])
  const [resourceColumns, setResourceColumns] = useState<string[]>([])
  const [filters, setFilters] = useState<Record<string, [string, string]>>({})
  const [resourceFilters, setResourceFilters] = useState<Record<string, [string, string]>>({})
  const [availableFilters, setAvailableFilters] = useState<Record<string, string[]>>({})
  const [availableResourceFilters, setAvailableResourceFilters] = useState<Record<string, string[]>>({})
  const [records, setRecords] = useState<any[]>([])

  // Listen for server-pushed events
  useEffect(() => {
    handleEvent('records', (payload: { records: any[] }) => {
      setRecords((prev) => {
        const next = [...payload.records, ...prev]
        return next.slice(0, MAX_RECORDS)
      })
    })

    handleEvent('agent_update', (payload: any) => {
      setAgent(payload)
    })

    handleEvent('state_update', (payload: any) => {
      if (payload.should_stream !== undefined) setShouldStream(payload.should_stream)
      if (payload.remote_tap_started !== undefined) setRemoteTapStarted(payload.remote_tap_started)
      if (payload.active_stream !== undefined) setActiveStream(payload.active_stream)
      if (payload.custom_columns !== undefined) setCustomColumns(payload.custom_columns)
      if (payload.resource_columns !== undefined) setResourceColumns(payload.resource_columns)
      if (payload.filters !== undefined) setFilters(payload.filters)
      if (payload.resource_filters !== undefined) setResourceFilters(payload.resource_filters)
      if (payload.available_filters !== undefined) setAvailableFilters(payload.available_filters)
      if (payload.available_resource_filters !== undefined) setAvailableResourceFilters(payload.available_resource_filters)
    })

    handleEvent('reset_records', () => {
      setRecords([])
    })
  }, [handleEvent])

  const push = useCallback(
    (event: string, payload: any = {}) => {
      pushEvent(event, payload)
    },
    [pushEvent]
  )

  const activeColumns = columns?.[activeStream] || []

  return (
    <div className="min-h-screen">
      <Header
        shouldStream={shouldStream}
        remoteTapStarted={remoteTapStarted}
        agent={agent}
        onToggleStream={() => push('toggle_stream')}
        onToggleRemoteTap={() => push('toggle_remote_tap')}
        onRequestConfig={() => push('request_config')}
        onShowConfig={() => setCollectorOpen(true)}
      />

      <main className="px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-full">
          <hr className="border-zinc-200 dark:border-zinc-600" />

          <FilterBadges
            filters={filters}
            resourceFilters={resourceFilters}
            onRemoveFilter={(key, filterType) =>
              push('remove_attr_filter', { key, filter_type: filterType })
            }
          />

          <hr className="border-zinc-200 dark:border-zinc-600" />

          <Slideover open={collectorOpen} onClose={() => setCollectorOpen(false)}>
            <CollectorPanel agent={agent} />
          </Slideover>

          <Slideover open={rowDataOpen} onClose={() => setRowDataOpen(false)}>
            <DataViewer data={selectedRow} />
          </Slideover>
        </div>

        <div className="flex mt-6 gap-4">
          <FilterSidebar
            availableFilters={availableFilters}
            availableResourceFilters={availableResourceFilters}
            streamOptions={stream_options}
            activeStream={activeStream}
            onChangeStream={(value) => push('change_stream', { value })}
            onUpdateFilter={(filterType, key, action, val) =>
              push('update_filters', {
                filter_type: filterType,
                key,
                action,
                val,
                value: '',
              })
            }
            onAddColumn={(columnType, key) =>
              push('update_columns', { column_type: columnType, key })
            }
          />

          <DataTable
            columns={activeColumns}
            customColumns={customColumns}
            resourceColumns={resourceColumns}
            records={records}
            remoteTapStarted={remoteTapStarted}
            onRowClick={(row) => {
              setSelectedRow(row)
              setRowDataOpen(true)
            }}
            onRemoveColumn={(column, columnType) =>
              push('remove_column', { column, column_type: columnType })
            }
          />
        </div>
      </main>
    </div>
  )
}
