import gql from 'graphql-tag'

export const GET_CALCULATIONS = gql`
  query GetCalculations {
    calculations {
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

export const GET_ME = gql`
  query GetMe {
    me {
      id
      name
      email
      avatar
    }
  }
`
