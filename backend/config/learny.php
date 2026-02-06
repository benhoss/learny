<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Bound Child Profile (Dev/Staging Only)
    |--------------------------------------------------------------------------
    |
    | When set, API child-scoped routes resolve to this child profile in
    | non-production environments. This is useful for fast local testing while
    | keeping route contracts unchanged.
    |
    */
    'bound_child_profile_id' => env('BOUND_CHILD_PROFILE_ID'),
];
