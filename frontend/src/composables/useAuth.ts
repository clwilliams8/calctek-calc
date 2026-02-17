import { ref, computed } from 'vue'
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
    }
  }

  function signIn(): Promise<void> {
    loading.value = true

    return new Promise((resolve, reject) => {
      const width = 500
      const height = 600
      const left = window.screenX + (window.innerWidth - width) / 2
      const top = window.screenY + (window.innerHeight - height) / 2

      const popup = window.open(
        `${import.meta.env.VITE_API_URL}/auth/google/redirect`,
        'google-oauth',
        `width=${width},height=${height},left=${left},top=${top},popup=true`,
      )

      if (!popup) {
        loading.value = false
        reject(new Error('Popup blocked. Please allow popups for this site.'))
        return
      }

      const cleanup = () => {
        window.removeEventListener('message', onMessage)
        clearInterval(pollTimer)
      }

      function onMessage(event: MessageEvent) {
        const apiUrl = import.meta.env.VITE_API_URL
        if (event.origin !== apiUrl) return
        if (event.data?.type !== 'oauth-callback') return

        cleanup()

        const receivedToken = event.data.token
        if (receivedToken) {
          setToken(receivedToken)
          fetchUser()
            .then(() => {
              loading.value = false
              resolve()
            })
            .catch((err) => {
              loading.value = false
              reject(err)
            })
        } else {
          loading.value = false
          reject(new Error('No token received'))
        }
      }

      const pollTimer = setInterval(() => {
        if (popup.closed) {
          cleanup()
          loading.value = false
          resolve()
        }
      }, 500)

      window.addEventListener('message', onMessage)
    })
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
