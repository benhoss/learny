<?php

namespace Database\Factories;

use App\Models\Document;
use Illuminate\Database\Eloquent\Factories\Factory;

class DocumentFactory extends Factory
{
    protected $model = Document::class;

    public function definition(): array
    {
        return [
            'user_id' => null,
            'child_profile_id' => null,
            'status' => 'queued',
            'original_filename' => 'worksheet.pdf',
            'storage_disk' => 's3',
            'storage_path' => 'children/demo/documents/'.$this->faker->uuid().'.pdf',
            'mime_type' => 'application/pdf',
            'size_bytes' => 1024,
        ];
    }
}
