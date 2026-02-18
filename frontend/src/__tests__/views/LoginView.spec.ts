import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { ref, computed } from 'vue'

// Mock useAuth
const mockSignIn = vi.fn()
const mockLoading = ref(false)
const mockIsAuthenticated = ref(false)

vi.mock('@/composables/useAuth', () => ({
  useAuth: () => ({
    signIn: mockSignIn,
    loading: mockLoading,
    isAuthenticated: computed(() => mockIsAuthenticated.value),
  }),
}))

// Mock vue-router
const mockPush = vi.fn()
vi.mock('vue-router', () => ({
  useRouter: () => ({
    push: mockPush,
  }),
}))

import LoginView from '@/views/LoginView.vue'

describe('LoginView', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    mockLoading.value = false
    mockIsAuthenticated.value = false
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

  it('calls signIn and navigates to / on success', async () => {
    mockSignIn.mockImplementation(async () => {
      mockIsAuthenticated.value = true
    })

    const wrapper = mount(LoginView)
    await wrapper.find('button').trigger('click')
    await flushPromises()

    expect(mockSignIn).toHaveBeenCalled()
    expect(mockPush).toHaveBeenCalledWith('/')
  })

  it('does not navigate if signIn does not authenticate', async () => {
    mockSignIn.mockResolvedValue(undefined)

    const wrapper = mount(LoginView)
    await wrapper.find('button').trigger('click')
    await flushPromises()

    expect(mockSignIn).toHaveBeenCalled()
    expect(mockPush).not.toHaveBeenCalled()
  })
})
