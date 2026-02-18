<script setup lang="ts">
import { Loader2 } from 'lucide-vue-next'

defineProps<{
  expression: string
  display: string
  error: string | null
  loading: boolean
}>()
</script>

<template>
  <div class="rounded-xl bg-muted p-4 mb-4">
    <div class="text-right text-sm text-muted-foreground mb-1 h-5 truncate font-mono">
      {{ expression || '\u00A0' }}
    </div>
    <div class="text-right text-3xl font-mono font-bold truncate flex items-center justify-end gap-2">
      <Loader2 v-if="loading" class="h-5 w-5 animate-spin text-muted-foreground" />
      <span>{{ display }}</span>
    </div>
    <div v-if="error" class="text-right text-sm text-destructive mt-1 animate-pulse">
      {{ error }}
    </div>
  </div>
</template>
