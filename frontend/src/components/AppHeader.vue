<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Calculator, LogOut, Moon, Sun } from 'lucide-vue-next'
import { useAuth } from '@/composables/useAuth'

const { user, isAuthenticated, signIn, signOut, loading } = useAuth()

const isDark = ref(false)

onMounted(() => {
  isDark.value = document.documentElement.classList.contains('dark')
})

function toggleDarkMode() {
  isDark.value = !isDark.value
  document.documentElement.classList.toggle('dark', isDark.value)
  localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
}
</script>

<template>
  <header class="border-b bg-card safe-area-top">
    <div class="mx-auto px-3 sm:px-4 h-14 sm:h-16 flex items-center justify-between max-w-5xl">
      <div class="flex items-center gap-2 shrink-0">
        <Calculator class="h-5 w-5 sm:h-6 sm:w-6 text-primary" />
        <span class="text-lg sm:text-xl font-bold">CalcTek</span>
      </div>

      <div class="flex items-center gap-2 sm:gap-3">
        <button
          @click="toggleDarkMode"
          class="p-1.5 sm:p-2 rounded-md hover:bg-accent transition-colors"
          :title="isDark ? 'Switch to light mode' : 'Switch to dark mode'"
        >
          <Sun v-if="isDark" class="h-4 w-4" />
          <Moon v-else class="h-4 w-4" />
        </button>

        <template v-if="isAuthenticated && user">
          <img
            v-if="user.avatar"
            :src="user.avatar"
            :alt="user.name"
            class="h-7 w-7 sm:h-8 sm:w-8 rounded-full"
          />
          <span class="text-sm text-muted-foreground hidden sm:inline">{{ user.name }}</span>
          <button
            @click="signOut"
            class="p-1.5 sm:px-3 sm:py-1.5 text-sm rounded-md border hover:bg-accent transition-colors inline-flex items-center gap-1.5"
          >
            <LogOut class="h-4 w-4" />
            <span class="hidden sm:inline">Sign out</span>
          </button>
        </template>
        <template v-else>
          <button
            @click="signIn"
            :disabled="loading"
            class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium rounded-md bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50"
          >
            <svg class="h-4 w-4 shrink-0" viewBox="0 0 24 24">
              <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z"/>
              <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
              <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            <span class="hidden sm:inline">Sign in with Google</span>
            <span class="sm:hidden">Sign in</span>
          </button>
        </template>
      </div>
    </div>
  </header>
</template>
