<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Services\Documents\MetadataSuggestionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DocumentMetadataSuggestionController extends Controller
{
    use FindsOwnedChild;

    public function suggest(
        Request $request,
        string $childId,
        MetadataSuggestionService $service
    ): JsonResponse {
        $this->findOwnedChild($childId);

        $data = $request->validate([
            'filename' => ['nullable', 'string', 'max:255'],
            'context_text' => ['nullable', 'string', 'max:500'],
            'ocr_snippet' => ['nullable', 'string', 'max:1000'],
            'language_hint' => ['nullable', 'string', 'max:64'],
        ]);

        $suggestions = $service->suggest($data);

        return response()->json([
            'data' => $suggestions,
        ]);
    }
}
