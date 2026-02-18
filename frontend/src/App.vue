<script setup lang="ts">
import { onMounted } from 'vue'
import AppHeader from '@/components/AppHeader.vue'
import { useAuth } from '@/composables/useAuth'
import { registerDeepLinks } from '@/lib/deep-links'
import router from '@/router'

const { isAuthenticated, fetchUser } = useAuth()

onMounted(async () => {
  registerDeepLinks(router)

  const saved = localStorage.getItem('theme')
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
  if (saved === 'dark' || (!saved && prefersDark)) {
    document.documentElement.classList.add('dark')
  }

  if (isAuthenticated.value) {
    await fetchUser()
  }
})
</script>

<template>
  <div class="min-h-screen bg-background">
    <AppHeader />
    <main class="container mx-auto px-2 sm:px-4 py-4 sm:py-8 max-w-5xl">
      <RouterView />
    </main>
  </div>
</template>
