<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class NotificationEvent extends Model
{
    use HasFactory;

    protected $collection = 'notification_events';

    protected $fillable = [
        'event_id',
        'source_event_id',
        'campaign_key',
        'audience',
        'recipient_user_id',
        'user_id',
        'child_id',
        'channel',
        'dedupe_key',
        'idempotency_key',
        'status',
        'suppression_reason',
        'provider_message_id',
        'scheduled_for',
        'sent_at',
        'failure_reason',
        'failed_terminal_at',
        'consent_state',
        'policy_version',
        'context_payload',
        'priority',
        'read_at',
        'opened_at',
    ];

    protected $casts = [
        'scheduled_for' => 'datetime',
        'sent_at' => 'datetime',
        'failed_terminal_at' => 'datetime',
        'read_at' => 'datetime',
        'opened_at' => 'datetime',
        'context_payload' => 'array',
    ];
}
