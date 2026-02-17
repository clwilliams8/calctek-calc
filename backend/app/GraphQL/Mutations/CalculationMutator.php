<?php

namespace App\GraphQL\Mutations;

use App\Models\Calculation;
use App\Services\CalculatorService;
use GraphQL\Error\Error;

class CalculationMutator
{
    public function __construct(
        private CalculatorService $calculatorService,
    ) {}

    public function calculate($_, array $args): Calculation
    {
        $user = auth()->user();
        $input = $args['input'];

        try {
            return $this->calculatorService->calculate(
                $user,
                $input['operand_a'],
                $input['operator'],
                $input['operand_b'],
            );
        } catch (\InvalidArgumentException $e) {
            throw new Error($e->getMessage());
        }
    }

    public function evaluateExpression($_, array $args): Calculation
    {
        $user = auth()->user();

        try {
            return $this->calculatorService->evaluateExpression(
                $user,
                $args['expression'],
            );
        } catch (\Throwable $e) {
            throw new Error('Invalid expression: '.$e->getMessage());
        }
    }

    public function deleteCalculation($_, array $args): ?Calculation
    {
        $user = auth()->user();
        $calculation = Calculation::where('id', $args['id'])
            ->where('user_id', $user->id)
            ->first();

        if (! $calculation) {
            throw new Error('Calculation not found');
        }

        $calculation->delete();

        return $calculation;
    }

    public function clearCalculations(): bool
    {
        $user = auth()->user();
        $user->calculations()->delete();

        return true;
    }
}
