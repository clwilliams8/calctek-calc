<script setup lang="ts">
import { X } from 'lucide-vue-next'

interface Calculation {
  id: string
  expression: string
  result: number
  created_at: string
}

defineProps<{
  calculation: Calculation
}>()

const emit = defineEmits<{
  delete: []
}>()
</script>

<template>
  <div class="group flex items-center justify-between rounded-lg border px-3 py-2 hover:bg-accent/50 transition-colors">
    <span class="font-mono text-sm truncate flex-1">
      {{ calculation.expression }}
    </span>
    <button
      @click="emit('delete')"
      class="ml-2 p-1 rounded opacity-0 group-hover:opacity-100 hover:bg-destructive/10 text-destructive transition-all"
    >
      <X class="h-3.5 w-3.5" />
    </button>
  </div>
</template>
