<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'
import { useCalculator } from '@/composables/useCalculator'
import CalculatorDisplay from './CalculatorDisplay.vue'
import ScientificKeypad from './ScientificKeypad.vue'
import TickerTape from './TickerTape.vue'

const calc = useCalculator()

function handleKeydown(e: KeyboardEvent) {
  if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return

  if (e.key >= '0' && e.key <= '9') {
    calc.appendToExpression(e.key)
  } else if (e.key === '.') {
    calc.appendToExpression('.')
  } else if (e.key === '+') {
    calc.appendToExpression('+')
  } else if (e.key === '-') {
    calc.appendToExpression('−')
  } else if (e.key === '*') {
    calc.appendToExpression('×')
  } else if (e.key === '/') {
    e.preventDefault()
    calc.appendToExpression('÷')
  } else if (e.key === '(' || e.key === ')') {
    calc.appendToExpression(e.key)
  } else if (e.key === '^') {
    calc.appendToExpression('^')
  } else if (e.key === 'Enter' || e.key === '=') {
    e.preventDefault()
    calc.evaluate()
  } else if (e.key === 'Escape' || e.key === 'Delete') {
    calc.clear()
  } else if (e.key === 'Backspace') {
    calc.backspace()
  }
}

onMounted(() => window.addEventListener('keydown', handleKeydown))
onUnmounted(() => window.removeEventListener('keydown', handleKeydown))
</script>

<template>
  <div class="grid grid-cols-1 lg:grid-cols-[1fr_320px] gap-6">
    <!-- Calculator Panel -->
    <div class="rounded-2xl border bg-card shadow-sm overflow-hidden">
      <div class="p-2 sm:p-4">
        <div class="flex items-center justify-between mb-3">
          <h2 class="text-lg font-semibold">Scientific Calculator</h2>
        </div>

        <CalculatorDisplay
          :expression="calc.expression.value"
          :display="calc.display.value"
          :error="calc.error.value"
          :loading="calc.loading.value"
        />

        <ScientificKeypad
          @input="calc.appendToExpression($event)"
          @clear="calc.clear()"
          @evaluate="calc.evaluate()"
          @backspace="calc.backspace()"
        />
      </div>
    </div>

    <!-- Ticker Tape Panel -->
    <TickerTape
      :calculations="calc.calculations.value"
      :has-history="calc.hasHistory.value"
      @delete="calc.deleteCalculation($event)"
      @clear-all="calc.clearAllCalculations()"
    />
  </div>
</template>
