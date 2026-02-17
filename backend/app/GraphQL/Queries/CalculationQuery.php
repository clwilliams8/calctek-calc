<?php

namespace App\GraphQL\Queries;

use Illuminate\Support\Collection;

class CalculationQuery
{
    public function resolve($_, array $args): Collection
    {
        return auth()->user()->calculations()->orderBy('created_at', 'desc')->get();
    }
}
