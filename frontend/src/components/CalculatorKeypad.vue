<script setup lang="ts">
defineProps<{
  loading: boolean
}>()

const emit = defineEmits<{
  digit: [value: string]
  decimal: []
  operator: [value: string]
  equals: []
  clear: []
}>()

const buttons = [
  { label: 'C', action: () => emit('clear'), class: 'col-span-2 bg-destructive/10 text-destructive hover:bg-destructive/20' },
  { label: '/', action: () => emit('operator', '/'), class: 'bg-primary/10 text-primary hover:bg-primary/20' },
  { label: '*', action: () => emit('operator', '*'), class: 'bg-primary/10 text-primary hover:bg-primary/20' },
  { label: '7', action: () => emit('digit', '7') },
  { label: '8', action: () => emit('digit', '8') },
  { label: '9', action: () => emit('digit', '9') },
  { label: '-', action: () => emit('operator', '-'), class: 'bg-primary/10 text-primary hover:bg-primary/20' },
  { label: '4', action: () => emit('digit', '4') },
  { label: '5', action: () => emit('digit', '5') },
  { label: '6', action: () => emit('digit', '6') },
  { label: '+', action: () => emit('operator', '+'), class: 'bg-primary/10 text-primary hover:bg-primary/20' },
  { label: '1', action: () => emit('digit', '1') },
  { label: '2', action: () => emit('digit', '2') },
  { label: '3', action: () => emit('digit', '3') },
  { label: '=', action: () => emit('equals'), class: 'row-span-2 bg-primary text-primary-foreground hover:bg-primary/90' },
  { label: '0', action: () => emit('digit', '0'), class: 'col-span-2' },
  { label: '.', action: () => emit('decimal') },
]
</script>

<template>
  <div class="grid grid-cols-4 gap-2">
    <button
      v-for="btn in buttons"
      :key="btn.label"
      @click="btn.action()"
      :disabled="loading"
      :class="[
        'h-14 rounded-lg font-semibold text-lg transition-colors border',
        'hover:brightness-95 active:scale-95',
        'disabled:opacity-50 disabled:cursor-not-allowed',
        btn.class || 'bg-card hover:bg-accent'
      ]"
    >
      {{ btn.label }}
    </button>
  </div>
</template>
