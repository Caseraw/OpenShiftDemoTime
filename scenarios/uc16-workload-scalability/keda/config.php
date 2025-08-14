<?php
$link = new mysqli("mysql", "demo", "demo", "keda_php");

// Check connection
if($link === false){
    die("ERROR: Could not connect. " . mysqli_connect_error());
}

$ddl_sql = "CREATE TABLE IF NOT EXISTS request_counter ( id INT PRIMARY KEY AUTO_INCREMENT, count INT NOT NULL DEFAULT 0);";
mysqli_query($link, $ddl_sql);

$result = $mysqli->query("SELECT count FROM request_counter WHERE id = 1");
$row = $result->fetch_assoc();
if ($row === null) {
    mysqli_query($link,"INSERT INTO request_counter (count) VALUES (0);");
}

?>