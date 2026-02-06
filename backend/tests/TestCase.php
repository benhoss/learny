<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Support\Facades\DB;

abstract class TestCase extends BaseTestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        $this->clearMongoCollections([
            'users',
            'child_profiles',
            'mastery_profiles',
            'concepts',
            'documents',
            'learning_packs',
            'games',
            'game_results',
            'revision_sessions',
            'learning_memory_events',
        ]);
    }

    protected function clearMongoCollections(array $collections): void
    {
        $db = DB::connection('mongodb')->getDatabase();
        $existing = [];

        foreach ($db->listCollections() as $collection) {
            $existing[] = $collection->getName();
        }

        foreach ($collections as $name) {
            if (in_array($name, $existing, true)) {
                $db->dropCollection($name);
            }
        }
    }

    protected function extractId(array $payload): string
    {
        if (isset($payload['_id'])) {
            return (string) $payload['_id'];
        }

        if (isset($payload['id'])) {
            return (string) $payload['id'];
        }

        return '';
    }
}
