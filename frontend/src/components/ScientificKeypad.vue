<script setup lang="ts">
const emit = defineEmits<{
  input: [value: string]
  clear: []
  evaluate: []
  backspace: []
}>()

interface ButtonDef {
  label: string
  value?: string
  action?: 'clear' | 'evaluate' | 'backspace'
  class?: string
}

const rows: ButtonDef[][] = [
  // Row 1: Parentheses, memory, clear
  [
    { label: '(', value: '(' },
    { label: ')', value: ')' },
    { label: 'mc', value: '' },
    { label: 'm+', value: '' },
    { label: 'm−', value: '' },
    { label: 'mr', value: '' },
    { label: 'AC', action: 'clear', class: 'bg-muted-foreground/20' },
    { label: '⌫', action: 'backspace', class: 'bg-muted-foreground/20' },
    { label: '%', value: '/100' },
    { label: '÷', value: '÷', class: 'bg-orange-500 text-white hover:bg-orange-600' },
  ],
  // Row 2: Scientific functions + 7-8-9 + multiply
  [
    { label: 'x²', value: '^2' },
    { label: 'x³', value: '^3' },
    { label: 'xʸ', value: '^' },
    { label: 'eˣ', value: 'exp(' },
    { label: '10ˣ', value: '10^' },
    { label: '1/x', value: '1/' },
    { label: '7', value: '7' },
    { label: '8', value: '8' },
    { label: '9', value: '9' },
    { label: '×', value: '×', class: 'bg-orange-500 text-white hover:bg-orange-600' },
  ],
  // Row 3: More scientific + 4-5-6 + subtract
  [
    { label: '√x', value: 'sqrt(' },
    { label: '∛x', value: 'cbrt(' },
    { label: 'ʸ√x', value: '^(1/' },
    { label: 'ln', value: 'ln(' },
    { label: 'log₁₀', value: 'log10(' },
    { label: 'x!', value: '!' },
    { label: '4', value: '4' },
    { label: '5', value: '5' },
    { label: '6', value: '6' },
    { label: '−', value: '−', class: 'bg-orange-500 text-white hover:bg-orange-600' },
  ],
  // Row 4: Trig + 1-2-3 + add
  [
    { label: 'sin', value: 'sin(' },
    { label: 'cos', value: 'cos(' },
    { label: 'tan', value: 'tan(' },
    { label: 'sinh', value: 'sinh(' },
    { label: 'cosh', value: 'cosh(' },
    { label: 'tanh', value: 'tanh(' },
    { label: '1', value: '1' },
    { label: '2', value: '2' },
    { label: '3', value: '3' },
    { label: '+', value: '+', class: 'bg-orange-500 text-white hover:bg-orange-600' },
  ],
  // Row 5: Constants + 0 + decimal + equals
  [
    { label: 'π', value: String(Math.PI) },
    { label: 'e', value: String(Math.E) },
    { label: 'Rand', value: String(Math.random()) },
    { label: 'EE', value: 'e' },
    { label: '+/−', value: '(-' },
    { label: 'Abs', value: 'abs(' },
    { label: '0', value: '0' },
    { label: '', value: '' },
    { label: '.', value: '.' },
    { label: '=', action: 'evaluate', class: 'bg-orange-500 text-white hover:bg-orange-600' },
  ],
]

function handleClick(btn: ButtonDef) {
  if (btn.action === 'clear') {
    emit('clear')
  } else if (btn.action === 'evaluate') {
    emit('evaluate')
  } else if (btn.action === 'backspace') {
    emit('backspace')
  } else if (btn.value) {
    emit('input', btn.value)
  }
}
</script>

<template>
  <div class="grid grid-cols-10 gap-1">
    <template v-for="(row, ri) in rows" :key="ri">
      <button
        v-for="(btn, ci) in row"
        :key="`${ri}-${ci}`"
        @click="handleClick(btn)"
        :disabled="!btn.label"
        :class="[
          'h-10 rounded-lg text-xs font-medium transition-colors select-none',
          'flex items-center justify-center',
          btn.class || 'bg-muted hover:bg-muted/80',
          !btn.label ? 'invisible' : '',
        ]"
      >
        {{ btn.label }}
      </button>
    </template>
  </div>
</template>
