import { ref, computed, watch } from 'vue'
import { useMutation, useQuery } from '@vue/apollo-composable'
import { EVALUATE_EXPRESSION, DELETE_CALCULATION, CLEAR_CALCULATIONS } from '@/graphql/mutations'
import { GET_CALCULATIONS } from '@/graphql/queries'

interface Calculation {
  id: string
  expression: string
  operator: string | null
  operand_a: number | null
  operand_b: number | null
  result: number
  created_at: string
}

// Multi-char tokens that backspace should remove as a unit
const FUNCTION_TOKENS = ['sin(', 'cos(', 'tan(', 'sinh(', 'cosh(', 'tanh(', 'sqrt(', 'cbrt(', 'log(', 'ln(', 'exp(', 'abs(']

export function useCalculator() {
  const expression = ref('')
  const display = ref('0')
  const error = ref<string | null>(null)
  const calculations = ref<Calculation[]>([])
  const loading = ref(false)

  const { onResult: onCalcResult, refetch: refetchCalculations } = useQuery(GET_CALCULATIONS, null, {
    fetchPolicy: 'network-only',
  })

  onCalcResult((result) => {
    if (result.data?.calculations) {
      calculations.value = result.data.calculations
    }
  })

  const { mutate: evaluateMutate } = useMutation(EVALUATE_EXPRESSION)
  const { mutate: deleteMutate } = useMutation(DELETE_CALCULATION)
  const { mutate: clearMutate } = useMutation(CLEAR_CALCULATIONS)

  function appendToExpression(text: string) {
    error.value = null
    expression.value += text
    // Update display to show the expression being built
    display.value = expression.value || '0'
  }

  function clear() {
    expression.value = ''
    display.value = '0'
    error.value = null
  }

  function backspace() {
    if (!expression.value) return

    // Check if expression ends with a multi-char function token
    for (const token of FUNCTION_TOKENS) {
      if (expression.value.endsWith(token)) {
        expression.value = expression.value.slice(0, -token.length)
        display.value = expression.value || '0'
        return
      }
    }

    // Remove last character
    expression.value = expression.value.slice(0, -1)
    display.value = expression.value || '0'
  }

  async function evaluate() {
    if (!expression.value.trim()) return

    loading.value = true
    error.value = null

    // Translate display operators to math operators for the backend
    let expr = expression.value
    expr = expr.replaceAll('×', '*')
    expr = expr.replaceAll('÷', '/')
    expr = expr.replaceAll('−', '-')
    // Replace ln( with log( for MathExecutor (which uses log for natural log)
    expr = expr.replaceAll('ln(', 'log(')
    // Replace log₁₀ syntax — we use log10( in the expression
    expr = expr.replaceAll('log10(', 'log10(')

    try {
      const result = await evaluateMutate({
        expression: expr,
      })

      if (result?.data?.evaluateExpression) {
        display.value = String(result.data.evaluateExpression.result)
        expression.value = ''
        await refetchCalculations()
      }
    } catch (e: any) {
      error.value = e.graphQLErrors?.[0]?.message || e.message || 'Invalid expression'
    } finally {
      loading.value = false
    }
  }

  async function deleteCalculation(id: string) {
    try {
      await deleteMutate({ id })
      await refetchCalculations()
    } catch (e: any) {
      error.value = e.message
    }
  }

  async function clearAllCalculations() {
    try {
      await clearMutate()
      await refetchCalculations()
    } catch (e: any) {
      error.value = e.message
    }
  }

  // Auto-dismiss errors after 4 seconds
  let errorTimeout: ReturnType<typeof setTimeout> | null = null
  watch(error, (val) => {
    if (errorTimeout) clearTimeout(errorTimeout)
    if (val) {
      errorTimeout = setTimeout(() => { error.value = null }, 4000)
    }
  })

  const hasHistory = computed(() => calculations.value.length > 0)

  return {
    expression,
    display,
    error,
    calculations,
    loading,
    hasHistory,
    appendToExpression,
    clear,
    backspace,
    evaluate,
    deleteCalculation,
    clearAllCalculations,
    refetchCalculations,
  }
}
