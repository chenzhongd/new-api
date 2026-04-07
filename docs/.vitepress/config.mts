import { defineConfig } from 'vitepress'

export default defineConfig({
  head: [
    ['meta', { name: 'theme-color', content: '#667eea' }],
    ['link', { rel: 'icon', href: '/logo.png' }]
  ],
  lastUpdated: true
})
