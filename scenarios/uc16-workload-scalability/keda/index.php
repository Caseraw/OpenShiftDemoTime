<?php
$redis = new Redis();
$redis->connect('redis', 6379);

// Increment request counter
$redis->incr('request_count');

// Return something
echo "Hello! Requests so far: " . $redis->get('request_count');
?>
