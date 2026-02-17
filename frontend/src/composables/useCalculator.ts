import { ref, computed, watch } from 'vue'
import { useMutation, useQuery } from '@vue/apollo-composable'
import { CALCULATE, EVALUATE_EXPRESSION, DELETE_CALCULATION, CLEAR_CALCULATIONS } from '@/graphql/mutations'
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

export function useCalculator() {
  const display = ref('0')
  const previousOperand = ref<number | null>(null)
  const currentOperator = ref<string | null>(null)
  const waitingForSecondOperand = ref(false)
  const expressionMode = ref(false)
  const expressionInput = ref('')
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

  const { mutate: calculateMutate } = useMutation(CALCULATE)
  const { mutate: evaluateMutate } = useMutation(EVALUATE_EXPRESSION)
  const { mutate: deleteMutate } = useMutation(DELETE_CALCULATION)
  const { mutate: clearMutate } = useMutation(CLEAR_CALCULATIONS)

  function inputDigit(digit: string) {
    error.value = null
    if (waitingForSecondOperand.value) {
      display.value = digit
      waitingForSecondOperand.value = false
    } else {
      display.value = display.value === '0' ? digit : display.value + digit
    }
  }

  function inputDecimal() {
    if (waitingForSecondOperand.value) {
      display.value = '0.'
      waitingForSecondOperand.value = false
      return
    }
    if (!display.value.includes('.')) {
      display.value += '.'
    }
  }

  function selectOperator(operator: string) {
    error.value = null
    const current = parseFloat(display.value)

    if (previousOperand.value !== null && !waitingForSecondOperand.value) {
      performCalculation()
      return
    }

    previousOperand.value = current
    currentOperator.value = operator
    waitingForSecondOperand.value = true
  }

  async function performCalculation() {
    if (previousOperand.value === null || !currentOperator.value) return

    const operandB = parseFloat(display.value)
    loading.value = true
    error.value = null

    try {
      const result = await calculateMutate({
        input: {
          operand_a: previousOperand.value,
          operator: currentOperator.value,
          operand_b: operandB,
        },
      })

      if (result?.data?.calculate) {
        display.value = String(result.data.calculate.result)
        previousOperand.value = null
        currentOperator.value = null
        waitingForSecondOperand.value = false
        await refetchCalculations()
      }
    } catch (e: any) {
      error.value = e.graphQLErrors?.[0]?.message || e.message || 'Calculation failed'
    } finally {
      loading.value = false
    }
  }

  async function evaluateExpression() {
    if (!expressionInput.value.trim()) return

    loading.value = true
    error.value = null

    try {
      const result = await evaluateMutate({
        expression: expressionInput.value,
      })

      if (result?.data?.evaluateExpression) {
        display.value = String(result.data.evaluateExpression.result)
        expressionInput.value = ''
        await refetchCalculations()
      }
    } catch (e: any) {
      error.value = e.graphQLErrors?.[0]?.message || e.message || 'Invalid expression'
    } finally {
      loading.value = false
    }
  }

  function clear() {
    display.value = '0'
    previousOperand.value = null
    currentOperator.value = null
    waitingForSecondOperand.value = false
    expressionInput.value = ''
    error.value = null
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
    display,
    previousOperand,
    currentOperator,
    waitingForSecondOperand,
    expressionMode,
    expressionInput,
    error,
    calculations,
    loading,
    hasHistory,
    inputDigit,
    inputDecimal,
    selectOperator,
    performCalculation,
    evaluateExpression,
    clear,
    deleteCalculation,
    clearAllCalculations,
    refetchCalculations,
  }
}
