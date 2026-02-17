import { ref, computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_ME } from '@/graphql/queries'

interface User {
  id: string
  name: string
  email: string
  avatar: string | null
}

const user = ref<User | null>(null)
const token = ref<string | null>(localStorage.getItem('auth_token'))

export function useAuth() {
  const isAuthenticated = computed(() => !!token.value)

  function setToken(newToken: string) {
    token.value = newToken
    localStorage.setItem('auth_token', newToken)
  }

  function signIn() {
    window.location.href = `${import.meta.env.VITE_API_URL}/auth/google/redirect`
  }

  function signOut() {
    token.value = null
    user.value = null
    localStorage.removeItem('auth_token')
  }

  function fetchUser() {
    if (!token.value) return

    const { onResult, onError } = useQuery(GET_ME)

    onResult((result) => {
      if (result.data?.me) {
        user.value = result.data.me
      }
    })

    onError(() => {
      signOut()
    })
  }

  return {
    user,
    token,
    isAuthenticated,
    setToken,
    signIn,
    signOut,
    fetchUser,
  }
}
