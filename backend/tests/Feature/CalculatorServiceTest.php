<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\CalculatorService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CalculatorServiceTest extends TestCase
{
    use RefreshDatabase;

    private CalculatorService $service;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new CalculatorService;
        $this->user = User::factory()->create();
    }

    public function test_addition(): void
    {
        $calc = $this->service->calculate($this->user, 2, '+', 3);
        $this->assertEquals(5.0, $calc->result);
        $this->assertEquals('2 + 3 = 5', $calc->expression);
    }

    public function test_subtraction(): void
    {
        $calc = $this->service->calculate($this->user, 10, '-', 3);
        $this->assertEquals(7.0, $calc->result);
    }

    public function test_multiplication(): void
    {
        $calc = $this->service->calculate($this->user, 4, '*', 5);
        $this->assertEquals(20.0, $calc->result);
    }

    public function test_division(): void
    {
        $calc = $this->service->calculate($this->user, 10, '/', 2);
        $this->assertEquals(5.0, $calc->result);
    }

    public function test_division_by_zero_throws(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Division by zero');
        $this->service->calculate($this->user, 10, '/', 0);
    }

    public function test_invalid_operator_throws(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid operator');
        $this->service->calculate($this->user, 10, '^', 2);
    }

    public function test_result_formatting_no_trailing_zeros(): void
    {
        $calc = $this->service->calculate($this->user, 10, '/', 4);
        $this->assertEquals(2.5, $calc->result);
        $this->assertStringContainsString('2.5', $calc->expression);
    }

    public function test_decimal_operations(): void
    {
        $calc = $this->service->calculate($this->user, 1.5, '+', 2.5);
        $this->assertEquals(4.0, $calc->result);
    }

    public function test_negative_numbers(): void
    {
        $calc = $this->service->calculate($this->user, -5, '+', 3);
        $this->assertEquals(-2.0, $calc->result);
    }

    public function test_calculation_persisted_to_database(): void
    {
        $calc = $this->service->calculate($this->user, 2, '+', 3);
        $this->assertDatabaseHas('calculations', [
            'id' => $calc->id,
            'user_id' => $this->user->id,
            'result' => 5.0,
        ]);
    }

    public function test_evaluate_expression_basic(): void
    {
        $calc = $this->service->evaluateExpression($this->user, '(3 + 4) * 2');
        $this->assertEquals(14.0, $calc->result);
    }

    public function test_evaluate_expression_sqrt(): void
    {
        $calc = $this->service->evaluateExpression($this->user, 'sqrt(144)');
        $this->assertEquals(12.0, $calc->result);
    }

    public function test_evaluate_expression_sin_zero(): void
    {
        $calc = $this->service->evaluateExpression($this->user, 'sin(0)');
        $this->assertEquals(0.0, $calc->result);
    }

    public function test_evaluate_expression_power(): void
    {
        $calc = $this->service->evaluateExpression($this->user, '2^8');
        $this->assertEquals(256.0, $calc->result);
    }

    public function test_evaluate_expression_log(): void
    {
        $calc = $this->service->evaluateExpression($this->user, 'log(1)');
        $this->assertEquals(0.0, $calc->result);
    }

    public function test_evaluate_expression_complex(): void
    {
        $calc = $this->service->evaluateExpression($this->user, 'sqrt(16) + 2^3');
        $this->assertEquals(12.0, $calc->result);
    }

    public function test_evaluate_expression_persisted(): void
    {
        $calc = $this->service->evaluateExpression($this->user, '2 + 3');
        $this->assertDatabaseHas('calculations', [
            'id' => $calc->id,
            'user_id' => $this->user->id,
        ]);
    }

    public function test_evaluate_invalid_expression_throws(): void
    {
        $this->expectException(\Exception::class);
        $this->service->evaluateExpression($this->user, '???');
    }

    public function test_evaluate_requirement_expression(): void
    {
        $calc = $this->service->evaluateExpression($this->user, 'sqrt((((9*9)/12)+(13-4))*2)^2)');
        $this->assertEquals(31.5, $calc->result);
    }

    public function test_evaluate_expression_missing_closing_parens(): void
    {
        $calc = $this->service->evaluateExpression($this->user, '(2+3');
        $this->assertEquals(5.0, $calc->result);
    }

    public function test_evaluate_expression_balanced_parens_unchanged(): void
    {
        $calc = $this->service->evaluateExpression($this->user, 'sqrt(16)');
        $this->assertEquals(4.0, $calc->result);
    }
}
