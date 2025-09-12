<?php
$host = "localhost";
$user = "root";
$pass = "";
$dbname = "medmon";

$conn = new mysqli($host, $user, $pass, $dbname);
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "msg" => "連線失敗: " . $conn->connect_error]));
}
$conn->set_charset("utf8");
