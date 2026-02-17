<script setup lang="ts">
import { Loader2 } from 'lucide-vue-next'

defineProps<{
  display: string
  operator: string | null
  previousOperand: number | null
  error: string | null
  loading: boolean
}>()
</script>

<template>
  <div class="rounded-xl bg-muted p-4 mb-4 relative">
    <div v-if="previousOperand !== null && operator" class="text-right text-sm text-muted-foreground mb-1">
      {{ previousOperand }} {{ operator }}
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
