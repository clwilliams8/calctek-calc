<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Calculation extends Model
{
    protected $fillable = [
        'user_id',
        'expression',
        'operator',
        'operand_a',
        'operand_b',
        'result',
    ];

    protected $casts = [
        'operand_a' => 'float',
        'operand_b' => 'float',
        'result' => 'float',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
