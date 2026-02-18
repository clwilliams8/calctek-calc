<?php

namespace Tests\Feature;

use App\Models\Calculation;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GraphQLCalculationTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    private function graphql(string $query, array $variables = [], ?User $user = null): \Illuminate\Testing\TestResponse
    {
        $request = $this->postJson('/graphql', [
            'query' => $query,
            'variables' => $variables,
        ]);

        if ($user) {
            return $this->actingAs($user)->postJson('/graphql', [
                'query' => $query,
                'variables' => $variables,
            ]);
        }

        return $request;
    }

    public function test_calculate_requires_auth(): void
    {
        $response = $this->postJson('/graphql', [
            'query' => 'mutation { calculate(input: { operand_a: 2, operator: "+", operand_b: 3 }) { id result } }',
        ]);

        $response->assertOk();
        $response->assertJsonPath('errors.0.message', 'Unauthenticated.');
    }

    public function test_calculate_mutation(): void
    {
        $response = $this->actingAs($this->user)->postJson('/graphql', [
            'query' => '
                mutation Calculate($input: CalculateInput!) {
                    calculate(input: $input) {
                        id
                        expression
                        result
                    }
                }
            ',
            'variables' => [
                'input' => [
                    'operand_a' => 10,
                    'operator' => '+',
                    'operand_b' => 5,
                ],
            ],
        ]);

        $response->assertOk();
        $this->assertEquals(15, $response->json('data.calculate.result'));
        $response->assertJsonPath('data.calculate.expression', '10 + 5 = 15');
    }

    public function test_evaluate_expression_mutation(): void
    {
        $response = $this->actingAs($this->user)->postJson('/graphql', [
            'query' => '
                mutation EvaluateExpression($expression: String!) {
                    evaluateExpression(expression: $expression) {
                        id
                        expression
                        result
                    }
                }
            ',
            'variables' => [
                'expression' => 'sqrt(144)',
            ],
        ]);

        $response->assertOk();
        $this->assertEquals(12, $response->json('data.evaluateExpression.result'));
    }

    public function test_evaluate_expression_requires_auth(): void
    {
        $response = $this->postJson('/graphql', [
            'query' => 'mutation { evaluateExpression(expression: "2+3") { id result } }',
        ]);

        $response->assertOk();
        $response->assertJsonPath('errors.0.message', 'Unauthenticated.');
    }

    public function test_calculations_query(): void
    {
        // Create some calculations
        $this->user->calculations()->create([
            'expression' => '2 + 3 = 5',
            'operator' => '+',
            'operand_a' => 2,
            'operand_b' => 3,
            'result' => 5,
        ]);

        $this->user->calculations()->create([
            'expression' => '10 * 2 = 20',
            'operator' => '*',
            'operand_a' => 10,
            'operand_b' => 2,
            'result' => 20,
        ]);

        $response = $this->actingAs($this->user)->postJson('/graphql', [
            'query' => '{ calculations { id expression result } }',
        ]);

        $response->assertOk();
        $this->assertCount(2, $response->json('data.calculations'));
    }

    public function test_calculations_query_only_returns_own(): void
    {
        $otherUser = User::factory()->create();

        $this->user->calculations()->create([
            'expression' => '2 + 3 = 5',
            'operator' => '+',
            'operand_a' => 2,
            'operand_b' => 3,
            'result' => 5,
        ]);

        $otherUser->calculations()->create([
            'expression' => '10 * 2 = 20',
            'operator' => '*',
            'operand_a' => 10,
            'operand_b' => 2,
            'result' => 20,
        ]);

        $response = $this->actingAs($this->user)->postJson('/graphql', [
            'query' => '{ calculations { id expression result } }',
        ]);

        $response->assertOk();
        $this->assertCount(1, $response->json('data.calculations'));
    }

    public function test_delete_calculation(): void
    {
        $calc = $this->user->calculations()->create([
            'expression' => '2 + 3 = 5',
            'operator' => '+',
            'operand_a' => 2,
            'operand_b' => 3,
            'result' => 5,
        ]);

        $response = $this->actingAs($this->user)->postJson('/graphql', [
            'query' => '
                mutation DeleteCalculation($id: ID!) {
                    deleteCalculation(id: $id) { id }
                }
            ',
            'variables' => ['id' => $calc->id],
        ]);

        $response->assertOk();
        $this->assertDatabaseMissing('calculations', ['id' => $calc->id]);
    }

    public function test_cannot_delete_others_calculation(): void
    {
        $otherUser = User::factory()->create();
        $calc = $otherUser->calculations()->create([
            'expression' => '2 + 3 = 5',
            'operator' => '+',
            'operand_a' => 2,
            'operand_b' => 3,
            'result' => 5,
        ]);

        $response = $this->actingAs($this->user)->postJson('/graphql', [
            'query' => '
                mutation DeleteCalculation($id: ID!) {
                    deleteCalculation(id: $id) { id }
                }
            ',
            'variables' => ['id' => $calc->id],
        ]);

        $response->assertOk();
        $this->assertNotNull($response->json('errors'));
        $this->assertDatabaseHas('calculations', ['id' => $calc->id]);
    }

    public function test_clear_calculations(): void
    {
        $this->user->calculations()->create([
            'expression' => '2 + 3 = 5',
            'operator' => '+',
            'operand_a' => 2,
            'operand_b' => 3,
            'result' => 5,
        ]);

        $this->user->calculations()->create([
            'expression' => '10 * 2 = 20',
            'operator' => '*',
            'operand_a' => 10,
            'operand_b' => 2,
            'result' => 20,
        ]);

        $response = $this->actingAs($this->user)->postJson('/graphql', [
            'query' => 'mutation { clearCalculations }',
        ]);

        $response->assertOk();
        $response->assertJsonPath('data.clearCalculations', true);
        $this->assertCount(0, $this->user->calculations()->get());
    }

    public function test_me_query(): void
    {
        $response = $this->actingAs($this->user)->postJson('/graphql', [
            'query' => '{ me { id name email } }',
        ]);

        $response->assertOk();
        $response->assertJsonPath('data.me.name', $this->user->name);
        $response->assertJsonPath('data.me.email', $this->user->email);
    }
}
