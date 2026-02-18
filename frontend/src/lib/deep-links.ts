import { App } from '@capacitor/app'
import { Browser } from '@capacitor/browser'
import { Capacitor } from '@capacitor/core'
import type { Router } from 'vue-router'

export function registerDeepLinks(router: Router) {
  if (!Capacitor.isNativePlatform()) return

  App.addListener('appUrlOpen', ({ url }) => {
    try {
      const parsed = new URL(url)

      if (parsed.protocol === 'calctekapp:') {
        const path = parsed.hostname + parsed.pathname
        const searchParams = parsed.searchParams

        if (path.startsWith('auth/callback')) {
          const token = searchParams.get('token')
          if (token) {
            Browser.close().catch(() => {})
            router.push(`/auth/callback?token=${token}`)
            return
          }
        }
      }
    } catch (e) {
      console.error('Failed to handle deep link:', url, e)
    }
  })
}
