<script setup lang="ts">
import { Send } from 'lucide-vue-next'

const model = defineModel<string>({ required: true })

defineProps<{
  loading: boolean
}>()

const emit = defineEmits<{
  evaluate: []
}>()

function handleKeydown(e: KeyboardEvent) {
  if (e.key === 'Enter') {
    emit('evaluate')
  }
}
</script>

<template>
  <div class="space-y-3">
    <p class="text-sm text-muted-foreground">
      Enter a math expression (e.g., <code class="bg-muted px-1 rounded text-xs">sqrt((9*9)/12 + (13-4)) * 2^3</code>)
    </p>
    <div class="flex gap-2">
      <input
        v-model="model"
        @keydown="handleKeydown"
        type="text"
        placeholder="e.g., sqrt(144) + 2^3"
        class="flex-1 h-12 rounded-lg border bg-background px-4 text-lg font-mono focus:outline-none focus:ring-2 focus:ring-ring"
        :disabled="loading"
      />
      <button
        @click="emit('evaluate')"
        :disabled="loading || !model.trim()"
        class="h-12 px-4 rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed inline-flex items-center gap-2"
      >
        <Send class="h-4 w-4" />
        Evaluate
      </button>
    </div>
  </div>
</template>
