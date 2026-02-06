<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Throwable;

class EnsureGameResultsIdempotencyIndex extends Command
{
    protected $signature = 'learny:ensure-game-results-idempotency-index {--apply : Create the unique index when preflight passes}';

    protected $description = 'Preflight duplicate (child_profile_id, game_id) rows and optionally create unique index.';

    public function handle(): int
    {
        $collection = DB::connection('mongodb')->getDatabase()->selectCollection('game_results');

        $duplicates = iterator_to_array($collection->aggregate([
            [
                '$group' => [
                    '_id' => [
                        'child_profile_id' => '$child_profile_id',
                        'game_id' => '$game_id',
                    ],
                    'count' => ['$sum' => 1],
                ],
            ],
            [
                '$match' => [
                    'count' => ['$gt' => 1],
                ],
            ],
            [
                '$limit' => 20,
            ],
        ]), false);

        if (! empty($duplicates)) {
            $this->error('Duplicate game_results found for (child_profile_id, game_id). Resolve duplicates before applying unique index.');
            foreach ($duplicates as $row) {
                $childId = $row->_id->child_profile_id ?? 'unknown';
                $gameId = $row->_id->game_id ?? 'unknown';
                $count = $row->count ?? 0;
                $this->line(sprintf(' - child_profile_id=%s, game_id=%s, count=%s', (string) $childId, (string) $gameId, (string) $count));
            }

            return self::FAILURE;
        }

        $this->info('Preflight passed: no duplicate (child_profile_id, game_id) rows found.');

        if (! $this->option('apply')) {
            $this->line('Dry run complete. Re-run with --apply to create index.');

            return self::SUCCESS;
        }

        foreach ($collection->listIndexes() as $index) {
            if (($index->getName() ?? '') === 'game_results_child_game_unique') {
                $this->info('Index already exists: game_results_child_game_unique');

                return self::SUCCESS;
            }
        }

        try {
            $indexName = $collection->createIndex(
                ['child_profile_id' => 1, 'game_id' => 1],
                ['name' => 'game_results_child_game_unique', 'unique' => true]
            );
            $this->info(sprintf('Created index: %s', (string) $indexName));
        } catch (Throwable $e) {
            $this->error('Failed to create index: '.$e->getMessage());

            return self::FAILURE;
        }

        return self::SUCCESS;
    }
}
