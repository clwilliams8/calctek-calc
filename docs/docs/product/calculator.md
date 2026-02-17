# Calculator Product Spec

## Problem & Context

Users need a reliable, web-accessible calculator that goes beyond simple arithmetic. Existing browser calculators are either too basic (no expression support) or too complex (scientific calculators with steep learning curves). Additionally, users frequently want to review previous calculations but have no persistent history.

CalcTek Calculator solves this by providing:

1. A clean, intuitive keypad for basic operations.
2. An expression input mode for complex math (`sqrt(144)`, `2^8`, `(3+4)*5`).
3. A persistent ticker-tape history tied to the user's Google account.
4. Simple history management (delete one, clear all).

---

## User Stories

### US-1: Basic Calculation

> **As a** signed-in user,
> **I want to** perform basic arithmetic using a calculator keypad,
> **so that** I can quickly compute addition, subtraction, multiplication, and division.

**Acceptance Criteria:**

- [ ] The keypad displays buttons for digits `0-9`, operators `+`, `-`, `*`, `/`, a decimal point, and an equals button.
- [ ] Pressing digits and an operator builds a visible expression on the display (e.g., `12 + 5`).
- [ ] Pressing `=` sends the calculation to the backend via the `calculate` GraphQL mutation.
- [ ] The result is displayed on screen and the calculation is appended to the ticker tape.
- [ ] Division by zero displays a clear error message without crashing.

---

### US-2: Expression Mode

> **As a** signed-in user,
> **I want to** type a complex math expression into a text input,
> **so that** I can evaluate expressions like `sqrt(144)`, `2^8`, or `(10 + 5) * 3`.

**Acceptance Criteria:**

- [ ] An expression input field is available alongside or as an alternative to the keypad.
- [ ] The user can type any expression supported by MathExecutor (e.g., `sqrt`, `^`, parentheses, trigonometric functions).
- [ ] Pressing Enter or a submit button sends the expression to the backend via the `evaluateExpression` GraphQL mutation.
- [ ] The full expression and its result are displayed and appended to the ticker tape.
- [ ] Invalid expressions display a user-friendly error message.

---

### US-3: Calculation History (Ticker Tape)

> **As a** signed-in user,
> **I want to** see a scrollable history of my previous calculations,
> **so that** I can reference or verify past results.

**Acceptance Criteria:**

- [ ] The ticker tape is displayed alongside the calculator.
- [ ] Each entry shows the expression and its result (e.g., `12 + 5 = 17`).
- [ ] Entries are ordered newest-first.
- [ ] History is loaded from the backend via the `calculations` GraphQL query on page load.
- [ ] New calculations appear in the ticker tape immediately without a page reload.

---

### US-4: Google Sign-In

> **As a** visitor,
> **I want to** sign in with my Google account,
> **so that** my calculation history is saved and private to me.

**Acceptance Criteria:**

- [ ] A "Sign in with Google" button is displayed when the user is not authenticated.
- [ ] Clicking the button initiates the Google OAuth flow via the `/auth/google/redirect` endpoint.
- [ ] On successful authentication, the user is redirected back to the app with a valid Sanctum bearer token.
- [ ] The user's name and avatar are displayed in the app header.
- [ ] All GraphQL requests include the bearer token in the `Authorization` header.
- [ ] Unauthenticated users cannot access the calculator or history.

---

### US-5: Delete a Calculation

> **As a** signed-in user,
> **I want to** delete a single calculation from my history,
> **so that** I can remove entries I no longer need.

**Acceptance Criteria:**

- [ ] Each ticker tape entry has a delete action (icon or button).
- [ ] Clicking delete sends the `deleteCalculation` GraphQL mutation with the calculation's ID.
- [ ] The entry is removed from the ticker tape immediately without a page reload.
- [ ] Only the owner of the calculation can delete it.

---

### US-6: Clear All Calculations

> **As a** signed-in user,
> **I want to** clear my entire calculation history,
> **so that** I can start fresh.

**Acceptance Criteria:**

- [ ] A "Clear" or "Clear All" button is visible in the ticker tape area.
- [ ] Clicking the button sends the `clearCalculations` GraphQL mutation.
- [ ] All entries are removed from the ticker tape immediately.
- [ ] A confirmation prompt is shown before clearing to prevent accidental deletion.
- [ ] Only the authenticated user's calculations are deleted.

---

## GraphQL API Contract

The following schema defines the API surface for all calculator features:

```graphql
type Query {
    me: User @auth
    calculations: [Calculation!]! @guard
}

type Mutation {
    calculate(input: CalculateInput!): Calculation! @guard
    evaluateExpression(expression: String!): Calculation! @guard
    deleteCalculation(id: ID!): Calculation @guard
    clearCalculations: Boolean! @guard
}

input CalculateInput {
    operand_a: Float!
    operator: String!
    operand_b: Float!
}

type Calculation {
    id: ID!
    expression: String!
    operator: String
    operand_a: Float
    operand_b: Float
    result: Float!
    created_at: DateTime!
}

type User {
    id: ID!
    name: String!
    email: String!
    avatar: String
}
```
