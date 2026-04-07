import path from 'path'
import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { liveReactPlugin } from './js/live_react/vite-plugin'

export default defineConfig(({ command }) => {
  const isDev = command !== 'build'

  return {
    base: isDev ? undefined : '/assets',
    plugins: [
      react(),
      liveReactPlugin(),
      tailwindcss(),
    ],
    ssr: {
      noExternal: isDev ? undefined : true,
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, '.'),
      },
    },
    optimizeDeps: {
      include: ['phoenix', 'phoenix_html', 'phoenix_live_view'],
    },
    build: {
      commonjsOptions: { transformMixedEsModules: true },
      target: 'es2020',
      outDir: '../priv/static/assets',
      emptyOutDir: true,
      sourcemap: isDev,
      manifest: false,
      rollupOptions: {
        input: {
          app: path.resolve(__dirname, './js/app.js'),
        },
        output: {
          entryFileNames: '[name].js',
          chunkFileNames: '[name].js',
          assetFileNames: '[name][extname]',
        },
      },
    },
  }
})
