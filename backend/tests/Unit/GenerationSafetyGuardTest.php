<?php

namespace Tests\Unit;

use App\Services\Safety\GenerationSafetyGuard;
use Tests\TestCase;

class GenerationSafetyGuardTest extends TestCase
{
    public function test_it_returns_pass_when_payload_is_safe(): void
    {
        config()->set('learny.ai_guardrails.blocked_terms', ['blocked-term']);

        $guard = new GenerationSafetyGuard();
        $result = $guard->evaluate([
            'summary' => 'Helpful math learning content for students.',
        ]);

        $this->assertSame('pass', $result['result']);
        $this->assertSame(0, $result['risk_points']);
        $this->assertSame([], $result['reason_codes']);
    }

    public function test_it_returns_fail_when_blocked_term_is_detected_case_insensitively(): void
    {
        config()->set('learny.ai_guardrails.blocked_terms', ['HoW To ChEaT']);

        $guard = new GenerationSafetyGuard();
        $result = $guard->evaluate([
            'summary' => 'Tips about HOW TO CHEAT on exams.',
        ]);

        $this->assertSame('fail', $result['result']);
        $this->assertSame(80, $result['risk_points']);
        $this->assertContains('unsafe_content_detected', $result['reason_codes']);
        $this->assertSame(['HoW To ChEaT'], $result['details']['matched_terms']);
    }

    public function test_it_fails_closed_when_payload_cannot_be_serialized(): void
    {
        config()->set('learny.ai_guardrails.blocked_terms', ['anything']);

        $guard = new GenerationSafetyGuard();
        $result = $guard->evaluate([
            'summary' => "\xB1\x31",
        ]);

        $this->assertSame('fail', $result['result']);
        $this->assertSame(100, $result['risk_points']);
        $this->assertContains('payload_serialization_failed', $result['reason_codes']);
    }
}
