<?php
$redis = new Redis();
$redis->connect('redis', 6379);

$count = $redis->get('request_count');
header('Content-Type: text/plain');
echo "php_requests_total {$count}\n";
?>
