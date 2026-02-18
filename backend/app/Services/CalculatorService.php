<?php

namespace App\Services;

use App\Models\Calculation;
use App\Models\User;
use NXP\MathExecutor;

class CalculatorService
{
    private MathExecutor $executor;

    public function __construct()
    {
        $this->executor = new MathExecutor();
    }

    public function calculate(User $user, float $operandA, string $operator, float $operandB): Calculation
    {
        $validOperators = ['+', '-', '*', '/'];

        if (! in_array($operator, $validOperators)) {
            throw new \InvalidArgumentException("Invalid operator: {$operator}. Must be one of: +, -, *, /");
        }

        if ($operator === '/' && $operandB == 0) {
            throw new \InvalidArgumentException('Division by zero');
        }

        $result = match ($operator) {
            '+' => $operandA + $operandB,
            '-' => $operandA - $operandB,
            '*' => $operandA * $operandB,
            '/' => $operandA / $operandB,
        };

        $expression = $this->formatNumber($operandA)." {$operator} ".$this->formatNumber($operandB).' = '.$this->formatNumber($result);

        return $user->calculations()->create([
            'expression' => $expression,
            'operator' => $operator,
            'operand_a' => $operandA,
            'operand_b' => $operandB,
            'result' => $result,
        ]);
    }

    public function evaluateExpression(User $user, string $expression): Calculation
    {
        $normalized = $this->normalizeExpression($expression);
        $result = $this->executor->execute($normalized);

        $displayExpression = "{$expression} = ".$this->formatNumber($result);

        return $user->calculations()->create([
            'expression' => $displayExpression,
            'operator' => null,
            'operand_a' => null,
            'operand_b' => null,
            'result' => $result,
        ]);
    }

    private function normalizeExpression(string $expression): string
    {
        $open = substr_count($expression, '(');
        $close = substr_count($expression, ')');

        if ($close > $open) {
            // Remove excess closing parens from the right
            $excess = $close - $open;
            for ($i = 0; $i < $excess; $i++) {
                $pos = strrpos($expression, ')');
                $expression = substr_replace($expression, '', $pos, 1);
            }
        } elseif ($open > $close) {
            // Append missing closing parens
            $expression .= str_repeat(')', $open - $close);
        }

        return $expression;
    }

    private function formatNumber(float $number): string
    {
        if ($number == (int) $number) {
            return (string) (int) $number;
        }

        return rtrim(rtrim(number_format($number, 10, '.', ''), '0'), '.');
    }
}
