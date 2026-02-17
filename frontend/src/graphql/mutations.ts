import gql from 'graphql-tag'

export const CALCULATE = gql`
  mutation Calculate($input: CalculateInput!) {
    calculate(input: $input) {
      id
      expression
      operator
      operand_a
      operand_b
      result
      created_at
    }
  }
`

export const EVALUATE_EXPRESSION = gql`
  mutation EvaluateExpression($expression: String!) {
    evaluateExpression(expression: $expression) {
      id
      expression
      operator
      operand_a
      operand_b
      result
      created_at
    }
  }
`

export const DELETE_CALCULATION = gql`
  mutation DeleteCalculation($id: ID!) {
    deleteCalculation(id: $id) {
      id
    }
  }
`

export const CLEAR_CALCULATIONS = gql`
  mutation ClearCalculations {
    clearCalculations
  }
`
