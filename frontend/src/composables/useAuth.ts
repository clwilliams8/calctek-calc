import { ref, computed } from 'vue'
import { Capacitor } from '@capacitor/core'
import { Browser } from '@capacitor/browser'
import { apolloClient } from '@/graphql/client'
import { GET_ME } from '@/graphql/queries'

interface User {
  id: string
  name: string
  email: string
  avatar: string | null
}

const user = ref<User | null>(null)
const token = ref<string | null>(localStorage.getItem('auth_token'))
const loading = ref(false)

export function useAuth() {
  const isAuthenticated = computed(() => !!token.value)

  function setToken(newToken: string) {
    token.value = newToken
    localStorage.setItem('auth_token', newToken)
  }

  function signOut() {
    token.value = null
    user.value = null
    loading.value = false
    localStorage.removeItem('auth_token')
  }

  async function fetchUser(): Promise<void> {
    if (!token.value) return

    try {
      const { data } = await apolloClient.query({
        query: GET_ME,
        fetchPolicy: 'network-only',
      })
      if (data?.me) {
        user.value = data.me
      }
    } catch {
      signOut()
    } finally {
      loading.value = false
    }
  }

  function signIn(): void {
    loading.value = true
    const authUrl = `${import.meta.env.VITE_API_URL}/auth/google/redirect`

    if (Capacitor.isNativePlatform()) {
      Browser.open({ url: `${authUrl}?platform=mobile` })
    } else {
      window.location.replace(authUrl)
    }
  }

  return {
    user,
    token,
    isAuthenticated,
    loading,
    setToken,
    signIn,
    signOut,
    fetchUser,
  }
}
