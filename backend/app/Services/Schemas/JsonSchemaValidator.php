<?php

namespace App\Services\Schemas;

use JsonSchema\Validator;
use RuntimeException;

class JsonSchemaValidator
{
    public function validate(array $payload, string $schemaPath): void
    {
        if (! file_exists($schemaPath)) {
            throw new RuntimeException('Schema file not found: '.$schemaPath);
        }

        $schema = json_decode(file_get_contents($schemaPath));
        $data = json_decode(json_encode($payload));

        $validator = new Validator();
        $validator->validate($data, $schema);

        if (! $validator->isValid()) {
            $messages = array_map(
                fn (array $error) => sprintf('%s: %s', $error['property'], $error['message']),
                $validator->getErrors()
            );

            throw new RuntimeException('Schema validation failed: '.implode('; ', $messages));
        }
    }
}
