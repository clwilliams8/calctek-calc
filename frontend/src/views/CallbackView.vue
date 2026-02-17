<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { Loader2 } from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const { setToken, fetchUser } = useAuth()

onMounted(async () => {
  const token = route.query.token as string | undefined

  if (token) {
    setToken(token)
    await fetchUser()
    router.replace('/')
  } else {
    router.replace('/login')
  }
})
</script>

<template>
  <div class="flex flex-col items-center justify-center py-20 gap-3">
    <Loader2 class="h-8 w-8 animate-spin text-primary" />
    <p class="text-muted-foreground">Signing in...</p>
  </div>
</template>
