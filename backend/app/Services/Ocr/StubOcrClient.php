<?php

namespace App\Services\Ocr;

use Illuminate\Support\Facades\Storage;
use RuntimeException;

class StubOcrClient implements OcrClientInterface
{
    public function extractText(string $disk, string $path, ?string $mimeType = null): string
    {
        if (filter_var($path, FILTER_VALIDATE_URL) !== false) {
            $name = basename(parse_url($path, PHP_URL_PATH) ?? $path);
            return sprintf('OCR placeholder for %s', $name);
        }

        $storage = Storage::disk($disk);

        if (! $storage->exists($path)) {
            throw new RuntimeException('OCR source file not found.');
        }

        $name = basename($path);

        return sprintf('OCR placeholder for %s', $name);
    }
}
