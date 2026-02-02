<?php

namespace App\Console\Commands;

use App\Jobs\ProcessDocumentOcr;
use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\LearningPack;
use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class TestQuizFromPdf extends Command
{
    protected $signature = 'learny:test-quiz {file : Path or URL to a PDF/image file} {--email=parent@example.com} {--name=CLI Parent} {--child=Sarah} {--grade=Grade 6} {--wait=1}';

    protected $description = 'Upload a local file, trigger OCR/pack/game generation, and print the resulting quiz payload.';

    public function handle(): int
    {
        $filePath = $this->argument('file');
        if (! is_string($filePath) || $filePath === '') {
            $this->error('File path or URL is required.');
            return self::FAILURE;
        }

        $isUrl = filter_var($filePath, FILTER_VALIDATE_URL) !== false;
        if (! $isUrl && ! file_exists($filePath)) {
            $this->error('File not found: '.$filePath);
            return self::FAILURE;
        }

        $email = (string) $this->option('email');
        $name = (string) $this->option('name');
        $childName = (string) $this->option('child');
        $grade = (string) $this->option('grade');
        $wait = (int) $this->option('wait');

        $user = User::where('email', $email)->first();
        if (! $user) {
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'password' => Hash::make(Str::random(24)),
            ]);
        }

        $child = ChildProfile::where('user_id', (string) $user->_id)
            ->where('name', $childName)
            ->first();
        if (! $child) {
            $child = ChildProfile::create([
                'user_id' => (string) $user->_id,
                'name' => $childName,
                'grade_level' => $grade,
            ]);
        }

        $diskName = config('filesystems.default', 'local');
        $extension = pathinfo(parse_url($filePath, PHP_URL_PATH) ?? $filePath, PATHINFO_EXTENSION) ?: 'pdf';
        $originalFilename = basename(parse_url($filePath, PHP_URL_PATH) ?? $filePath);

        if ($isUrl) {
            $path = $filePath;
            $diskName = 'url';
        } else {
            $disk = Storage::disk($diskName);
            $path = sprintf(
                'children/%s/documents/%s.%s',
                (string) $child->_id,
                (string) Str::uuid(),
                $extension
            );

            $disk->put($path, file_get_contents($filePath), ['visibility' => 'private']);
        }

        $document = Document::create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'original_filename' => $originalFilename,
            'storage_disk' => $diskName,
            'storage_path' => $path,
            'mime_type' => $isUrl ? ($extension ? "image/{$extension}" : 'application/octet-stream') : (mime_content_type($filePath) ?: 'application/pdf'),
            'size_bytes' => $isUrl ? 0 : filesize($filePath),
        ]);

        $this->info('Document queued: '.$document->_id);
        ProcessDocumentOcr::dispatch((string) $document->_id);

        if ($wait <= 0) {
            return self::SUCCESS;
        }

        $this->line('Waiting for pack + quiz generation...');
        $pack = null;
        for ($i = 0; $i < 20; $i += 1) {
            $pack = LearningPack::where('document_id', (string) $document->_id)->first();
            if ($pack) {
                break;
            }
            sleep(2);
        }

        if (! $pack) {
            $this->error('No learning pack generated yet. Ensure queue worker is running.');
            return self::FAILURE;
        }

        $quiz = null;
        for ($i = 0; $i < 20; $i += 1) {
            $quiz = $pack->games()->where('type', 'quiz')->first();
            if ($quiz) {
                break;
            }
            sleep(2);
        }
        if (! $quiz) {
            $this->error('No quiz game generated yet. Ensure queue worker is running.');
            return self::FAILURE;
        }

        $this->info('Pack: '.$pack->_id.' | Quiz game: '.$quiz->_id);
        $this->line(json_encode($quiz->payload, JSON_PRETTY_PRINT));

        return self::SUCCESS;
    }
}
