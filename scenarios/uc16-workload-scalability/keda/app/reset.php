<?php
$mysqli = new mysqli("mysql", "demo", "demo", "keda_php");

if ($mysqli->connect_errno) {
    die("Failed to connect to MySQL: " . $mysqli->connect_error);
}

// Increment counter
$mysqli->query("UPDATE request_counter SET count = 1 WHERE id = 1");

// Get current count
$result = $mysqli->query("SELECT count FROM request_counter WHERE id = 1");
$row = $result->fetch_assoc();
echo "Requests are back to: " . $row['count'];
?>
