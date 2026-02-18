<?php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_health_endpoint(): void
    {
        $response = $this->get('/health');

        $response->assertStatus(200);
        $response->assertJsonStructure(['status', 'framework']);
    }
}
