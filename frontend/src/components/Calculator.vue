<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'
import { useCalculator } from '@/composables/useCalculator'
import CalculatorDisplay from './CalculatorDisplay.vue'
import CalculatorKeypad from './CalculatorKeypad.vue'
import ExpressionInput from './ExpressionInput.vue'
import TickerTape from './TickerTape.vue'

const calc = useCalculator()

function handleKeydown(e: KeyboardEvent) {
  if (calc.expressionMode.value) return
  if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return

  if (e.key >= '0' && e.key <= '9') {
    calc.inputDigit(e.key)
  } else if (e.key === '.') {
    calc.inputDecimal()
  } else if (['+', '-', '*', '/'].includes(e.key)) {
    calc.selectOperator(e.key)
  } else if (e.key === 'Enter' || e.key === '=') {
    e.preventDefault()
    calc.performCalculation()
  } else if (e.key === 'Escape' || e.key === 'Delete') {
    calc.clear()
  } else if (e.key === 'Backspace') {
    if (calc.display.value.length > 1) {
      calc.display.value = calc.display.value.slice(0, -1)
    } else {
      calc.display.value = '0'
    }
  }
}

onMounted(() => window.addEventListener('keydown', handleKeydown))
onUnmounted(() => window.removeEventListener('keydown', handleKeydown))
</script>

<template>
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <!-- Calculator Panel -->
    <div class="rounded-2xl border bg-card shadow-sm overflow-hidden">
      <div class="p-6">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-semibold">Calculator</h2>
          <div class="flex gap-1 rounded-lg border p-0.5">
            <button
              @click="calc.expressionMode.value = false"
              :class="[
                'px-3 py-1 text-sm rounded-md transition-colors',
                !calc.expressionMode.value ? 'bg-primary text-primary-foreground' : 'hover:bg-accent'
              ]"
            >
              Standard
            </button>
            <button
              @click="calc.expressionMode.value = true"
              :class="[
                'px-3 py-1 text-sm rounded-md transition-colors',
                calc.expressionMode.value ? 'bg-primary text-primary-foreground' : 'hover:bg-accent'
              ]"
            >
              Expression
            </button>
          </div>
        </div>

        <CalculatorDisplay
          :display="calc.display.value"
          :operator="calc.currentOperator.value"
          :previous-operand="calc.previousOperand.value"
          :error="calc.error.value"
          :loading="calc.loading.value"
        />

        <template v-if="calc.expressionMode.value">
          <ExpressionInput
            v-model="calc.expressionInput.value"
            :loading="calc.loading.value"
            @evaluate="calc.evaluateExpression()"
          />
        </template>
        <template v-else>
          <CalculatorKeypad
            :loading="calc.loading.value"
            @digit="calc.inputDigit($event)"
            @decimal="calc.inputDecimal()"
            @operator="calc.selectOperator($event)"
            @equals="calc.performCalculation()"
            @clear="calc.clear()"
          />
        </template>
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
