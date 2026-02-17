<script setup lang="ts">
import { Trash2, History } from 'lucide-vue-next'
import TickerTapeItem from './TickerTapeItem.vue'

interface Calculation {
  id: string
  expression: string
  result: number
  created_at: string
}

defineProps<{
  calculations: Calculation[]
  hasHistory: boolean
}>()

const emit = defineEmits<{
  delete: [id: string]
  'clear-all': []
}>()
</script>

<template>
  <div class="rounded-2xl border bg-card shadow-sm overflow-hidden flex flex-col h-[360px] lg:h-[520px]">
    <div class="p-4 border-b flex items-center justify-between">
      <div class="flex items-center gap-2">
        <History class="h-5 w-5 text-muted-foreground" />
        <h2 class="text-lg font-semibold">History</h2>
        <span v-if="hasHistory" class="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded-full">
          {{ calculations.length }}
        </span>
      </div>
      <button
        v-if="hasHistory"
        @click="emit('clear-all')"
        class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm rounded-md text-destructive border border-destructive/20 hover:bg-destructive/10 transition-colors"
      >
        <Trash2 class="h-3.5 w-3.5" />
        Clear All
      </button>
    </div>

    <div class="flex-1 overflow-y-auto p-4">
      <div v-if="!hasHistory" class="flex flex-col items-center justify-center h-full text-center text-muted-foreground">
        <History class="h-12 w-12 mb-3 opacity-30" />
        <p class="text-sm">No calculations yet</p>
        <p class="text-xs">Your calculation history will appear here</p>
      </div>

      <div v-else class="space-y-2">
        <TickerTapeItem
          v-for="calc in calculations"
          :key="calc.id"
          :calculation="calc"
          @delete="emit('delete', calc.id)"
        />
      </div>
    </div>
  </div>
</template>
