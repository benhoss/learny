<?php

namespace App\Services\Ocr;

use Prism\Prism\Enums\Provider;
use Prism\Prism\Facades\Prism;
use Prism\Prism\ValueObjects\Media\Document as PrismDocument;
use RuntimeException;

class PrismOcrClient implements OcrClientInterface
{
    public function extractText(string $disk, string $path, ?string $mimeType = null): string
    {
        $model = config('prism.mistral.ocr_model', 'mistral-ocr-latest');

        if (! config('prism.providers.mistral.api_key')) {
            throw new RuntimeException('Mistral API key is not configured.');
        }

        $document = $this->resolveDocument($disk, $path, $mimeType);
        $response = Prism::provider(Provider::Mistral)->ocr($model, $document);

        $text = trim($response->toText());

        if ($text === '') {
            throw new RuntimeException('Mistral OCR response did not contain text.');
        }

        return $text;
    }

    protected function resolveDocument(string $disk, string $path, ?string $mimeType): PrismDocument
    {
        if (filter_var($path, FILTER_VALIDATE_URL) !== false) {
            return PrismDocument::fromUrl($path, $mimeType);
        }

        $url = $this->diskUrl($disk, $path);
        if ($url) {
            return PrismDocument::fromUrl($url, $mimeType);
        }

        return PrismDocument::fromStoragePath($path, $disk);
    }

    protected function diskUrl(string $disk, string $path): ?string
    {
        $storage = \Illuminate\Support\Facades\Storage::disk($disk);

        if (method_exists($storage, 'temporaryUrl')) {
            try {
                $temporaryUrl = $storage->temporaryUrl($path, now()->addMinutes(10));
                if ($temporaryUrl && filter_var($temporaryUrl, FILTER_VALIDATE_URL) !== false) {
                    return $temporaryUrl;
                }
            } catch (\Throwable) {
                // ignore and fall back to public URL
            }
        }

        if (method_exists($storage, 'url')) {
            try {
                $publicUrl = $storage->url($path);
                if ($publicUrl && filter_var($publicUrl, FILTER_VALIDATE_URL) !== false) {
                    return $publicUrl;
                }
            } catch (\Throwable) {
                return null;
            }
        }

        return null;
    }
}
