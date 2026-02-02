<?php

namespace App\Services\Ocr;

interface OcrClientInterface
{
    public function extractText(string $disk, string $path, ?string $mimeType = null): string;
}
