import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { ref } from 'vue'

// Mock useAuth
const mockSignIn = vi.fn()
const mockLoading = ref(false)

vi.mock('@/composables/useAuth', () => ({
  useAuth: () => ({
    signIn: mockSignIn,
    loading: mockLoading,
  }),
}))

import LoginView from '@/views/LoginView.vue'

describe('LoginView', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    mockLoading.value = false
  })

  it('renders sign-in button', () => {
    const wrapper = mount(LoginView)
    expect(wrapper.text()).toContain('Sign in with Google')
  })

  it('shows "Signing in..." when loading', () => {
    mockLoading.value = true
    const wrapper = mount(LoginView)
    expect(wrapper.text()).toContain('Signing in...')
  })

  it('disables button when loading', () => {
    mockLoading.value = true
    const wrapper = mount(LoginView)
    const button = wrapper.find('button')
    expect(button.attributes('disabled')).toBeDefined()
  })

  it('calls signIn on button click', async () => {
    const wrapper = mount(LoginView)
    await wrapper.find('button').trigger('click')

    expect(mockSignIn).toHaveBeenCalled()
  })
})
