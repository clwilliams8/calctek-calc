import { describe, it, expect, vi, beforeEach } from 'vitest'

// Mock Apollo client
const mockQuery = vi.fn()
const mockMutate = vi.fn()

vi.mock('@/graphql/client', () => ({
  apolloClient: {
    query: (...args: unknown[]) => mockQuery(...args),
    mutate: (...args: unknown[]) => mockMutate(...args),
  },
}))

vi.mock('@vue/apollo-composable', () => ({
  useMutation: () => ({ mutate: mockMutate }),
  useQuery: () => ({
    onResult: vi.fn(),
    refetch: vi.fn(),
  }),
}))

import { useCalculator } from '@/composables/useCalculator'

describe('useCalculator', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('initializes with empty expression and "0" display', () => {
    const calc = useCalculator()
    expect(calc.expression.value).toBe('')
    expect(calc.display.value).toBe('0')
  })

  it('appendToExpression builds expression', () => {
    const calc = useCalculator()
    calc.appendToExpression('5')
    expect(calc.expression.value).toBe('5')
    calc.appendToExpression('+')
    expect(calc.expression.value).toBe('5+')
    calc.appendToExpression('3')
    expect(calc.expression.value).toBe('5+3')
  })

  it('appendToExpression handles function buttons', () => {
    const calc = useCalculator()
    calc.appendToExpression('sin(')
    expect(calc.expression.value).toBe('sin(')
    calc.appendToExpression('3.14')
    calc.appendToExpression(')')
    expect(calc.expression.value).toBe('sin(3.14)')
  })

  it('clear resets expression and display', () => {
    const calc = useCalculator()
    calc.appendToExpression('5+3')
    calc.clear()
    expect(calc.expression.value).toBe('')
    expect(calc.display.value).toBe('0')
    expect(calc.error.value).toBeNull()
  })

  it('backspace removes last character', () => {
    const calc = useCalculator()
    calc.appendToExpression('123')
    calc.backspace()
    expect(calc.expression.value).toBe('12')
  })

  it('backspace on empty expression does nothing', () => {
    const calc = useCalculator()
    calc.backspace()
    expect(calc.expression.value).toBe('')
  })

  it('backspace removes multi-char function', () => {
    const calc = useCalculator()
    calc.appendToExpression('sin(')
    calc.backspace()
    expect(calc.expression.value).toBe('')
  })

  it('evaluate sends expression to backend', async () => {
    mockMutate.mockResolvedValue({
      data: {
        evaluateExpression: {
          id: '1',
          expression: '5+3 = 8',
          result: 8,
        },
      },
    })

    const calc = useCalculator()
    calc.appendToExpression('5+3')
    await calc.evaluate()

    expect(mockMutate).toHaveBeenCalled()
    expect(calc.display.value).toBe('8')
  })

  it('evaluate handles errors gracefully', async () => {
    mockMutate.mockRejectedValue({
      graphQLErrors: [{ message: 'Invalid expression' }],
    })

    const calc = useCalculator()
    calc.appendToExpression('???')
    await calc.evaluate()

    expect(calc.error.value).toBeTruthy()
  })

  it('does not evaluate empty expression', async () => {
    const calc = useCalculator()
    await calc.evaluate()
    expect(mockMutate).not.toHaveBeenCalled()
  })
})
