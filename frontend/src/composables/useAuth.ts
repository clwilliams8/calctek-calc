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

  function signIn(): void {
    loading.value = true
    window.location.href = `${import.meta.env.VITE_API_URL}/auth/google/redirect`
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
