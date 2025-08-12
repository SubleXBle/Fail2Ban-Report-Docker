<?php
// includes/get-blocklist.php

header('Content-Type: application/json');

// Directory containing blocklist files
//$archiveDir = dirname(__DIR__) . '/../archive/';
$archiveDir = realpath(__DIR__ . '/../archive');
if (!$archiveDir) {
    http_response_code(500);
    die('Archive directory not found.');
}
$archiveDir .= '/';


// Get all files ending with ".blocklist.json"
$blocklistFiles = glob($archiveDir . '*.blocklist.json');

if (!$blocklistFiles) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'No blocklist files found.'
    ]);
    exit;
}

$allEntries = [];

foreach ($blocklistFiles as $file) {
    $content = file_get_contents($file);
    if ($content === false) {
        // Skip file if reading fails, optionally log the error
        continue;
    }
    $data = json_decode($content, true);
    if (!is_array($data)) {
        // Skip invalid JSON files
        continue;
    }
    // Append all entries from this file
    $allEntries = array_merge($allEntries, $data);
}

// Optional: sort entries by timestamp descending or IP ascending, etc.
// usort($allEntries, function($a, $b) {
//     return strcmp($b['timestamp'], $a['timestamp']); // newest first
// });

// Output the aggregated blocklist entries as JSON
echo json_encode([
    'success' => true,
    'entries' => $allEntries
]);
