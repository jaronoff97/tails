function hotUpdateType (path: string): 'css-update' | 'js-update' | null {
  if (path.endsWith('css')) {return 'css-update'}
  if (path.endsWith('js')) {return 'js-update'}
  return null
}

function jsonResponse (res: any, statusCode: number, data: Record<string, unknown>) {
  res.statusCode = statusCode
  res.setHeader('Content-Type', 'application/json')
  res.end(JSON.stringify(data))
}

function jsonMiddleware (req: any, res: any, next: () => void) {
  let data = ''

  req.on('data', (chunk: string) => {
    data += chunk
  })

  req.on('end', () => {
    try {
      req.body = JSON.parse(data)
      next()
    } catch (error) {
      jsonResponse(res, 400, { error: 'Invalid JSON' })
    }
  })

  req.on('error', (err: any) => {
    console.error(err)
    jsonResponse(res, 500, { error: 'Internal Server Error' })
  })
}

interface LiveReactHotUpdate {
  file: string
  modules: unknown[]
  server: any
  timestamp: number
}

export function liveReactPlugin (opts: { path?: string, entrypoint?: string } = {}) {
  return {
    name: 'live-react',
    handleHotUpdate ({ file, modules, server, timestamp }: LiveReactHotUpdate) {
      if (file.match(/\.(heex|ex)$/)) {
        const invalidatedModules = new Set()
        for (const mod of modules) {
          server.moduleGraph.invalidateModule(
            mod,
            invalidatedModules,
            timestamp,
            true
          )
        }

        const updates = Array.from(invalidatedModules)
          .filter((m: any) => hotUpdateType(m.file))
          .map((m: any) => ({
            type: hotUpdateType(m.file),
            path: m.url,
            acceptedPath: m.url,
            timestamp: timestamp,
          }))

        server.ws.send({ type: 'update', updates: updates })

        return []
      }
    },
    configureServer (server: any) {
      process.stdin.on('close', () => process.exit(0))
      process.stdin.resume()

      const path = opts.path || '/ssr_render'
      const entrypoint = opts.entrypoint || './js/server.js'
      server.middlewares.use(function liveReactMiddleware (req: any, res: any, next: any) {
        if (req.method == 'POST' && req.url.split('?', 1)[0] === path) {
          jsonMiddleware (req, res, async() => {
            try {
              const render = (await server.ssrLoadModule(entrypoint)).render
              const html = await render(
                req.body.name,
                req.body.props,
                req.body.slots
              )
              res.end(html)
            } catch (e) {
              server.ssrFixStacktrace(e)
              jsonResponse(res, 500, { error: e })
            }
          })
        } else {
          next()
        }
      })
    },
  }
}
