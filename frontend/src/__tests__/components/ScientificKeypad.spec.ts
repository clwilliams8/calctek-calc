import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ScientificKeypad from '@/components/ScientificKeypad.vue'

describe('ScientificKeypad', () => {
  it('renders all digit buttons (0-9)', () => {
    const wrapper = mount(ScientificKeypad)
    for (let i = 0; i <= 9; i++) {
      const btn = wrapper.findAll('button').find(b => b.text().trim() === String(i))
      expect(btn, `digit ${i} should exist`).toBeTruthy()
    }
  })

  it('renders operator buttons', () => {
    const wrapper = mount(ScientificKeypad)
    const operators = ['+', '−', '×', '÷', '=']
    for (const op of operators) {
      const btn = wrapper.findAll('button').find(b => b.text().trim() === op)
      expect(btn, `operator ${op} should exist`).toBeTruthy()
    }
  })

  it('renders scientific function buttons', () => {
    const wrapper = mount(ScientificKeypad)
    const functions = ['sin', 'cos', 'tan', 'ln', 'log₁₀', '√x', 'x²', 'xʸ', 'π', 'e']
    for (const fn of functions) {
      const btn = wrapper.findAll('button').find(b => b.text().trim() === fn)
      expect(btn, `function ${fn} should exist`).toBeTruthy()
    }
  })

  it('emits input event with digit value when digit clicked', async () => {
    const wrapper = mount(ScientificKeypad)
    const btn5 = wrapper.findAll('button').find(b => b.text().trim() === '5')!
    await btn5.trigger('click')
    expect(wrapper.emitted('input')).toBeTruthy()
    expect(wrapper.emitted('input')![0]).toEqual(['5'])
  })

  it('emits input event with operator when operator clicked', async () => {
    const wrapper = mount(ScientificKeypad)
    const btnPlus = wrapper.findAll('button').find(b => b.text().trim() === '+')!
    await btnPlus.trigger('click')
    expect(wrapper.emitted('input')![0]).toEqual(['+'])
  })

  it('emits input with "sin(" when sin button clicked', async () => {
    const wrapper = mount(ScientificKeypad)
    const btnSin = wrapper.findAll('button').find(b => b.text().trim() === 'sin')!
    await btnSin.trigger('click')
    expect(wrapper.emitted('input')![0]).toEqual(['sin('])
  })

  it('emits input with "sqrt(" when √x button clicked', async () => {
    const wrapper = mount(ScientificKeypad)
    const btnSqrt = wrapper.findAll('button').find(b => b.text().trim() === '√x')!
    await btnSqrt.trigger('click')
    expect(wrapper.emitted('input')![0]).toEqual(['sqrt('])
  })

  it('emits clear event when AC clicked', async () => {
    const wrapper = mount(ScientificKeypad)
    const btnAC = wrapper.findAll('button').find(b => b.text().trim() === 'AC')!
    await btnAC.trigger('click')
    expect(wrapper.emitted('clear')).toBeTruthy()
  })

  it('emits evaluate event when = clicked', async () => {
    const wrapper = mount(ScientificKeypad)
    const btnEq = wrapper.findAll('button').find(b => b.text().trim() === '=')!
    await btnEq.trigger('click')
    expect(wrapper.emitted('evaluate')).toBeTruthy()
  })

  it('emits backspace event when ⌫ clicked', async () => {
    const wrapper = mount(ScientificKeypad)
    const btnBs = wrapper.findAll('button').find(b => b.text().trim() === '⌫')!
    await btnBs.trigger('click')
    expect(wrapper.emitted('backspace')).toBeTruthy()
  })

  it('emits input with π constant value', async () => {
    const wrapper = mount(ScientificKeypad)
    const btnPi = wrapper.findAll('button').find(b => b.text().trim() === 'π')!
    await btnPi.trigger('click')
    expect(wrapper.emitted('input')![0]).toEqual([String(Math.PI)])
  })

  it('emits input with e constant value', async () => {
    const wrapper = mount(ScientificKeypad)
    const btnE = wrapper.findAll('button').find(b => b.text().trim() === 'e')!
    await btnE.trigger('click')
    expect(wrapper.emitted('input')![0]).toEqual([String(Math.E)])
  })

  it('emits input with "^2" for x² button', async () => {
    const wrapper = mount(ScientificKeypad)
    const btn = wrapper.findAll('button').find(b => b.text().trim() === 'x²')!
    await btn.trigger('click')
    expect(wrapper.emitted('input')![0]).toEqual(['^2'])
  })

  it('emits input with "^" for xʸ button', async () => {
    const wrapper = mount(ScientificKeypad)
    const btn = wrapper.findAll('button').find(b => b.text().trim() === 'xʸ')!
    await btn.trigger('click')
    expect(wrapper.emitted('input')![0]).toEqual(['^'])
  })
})
