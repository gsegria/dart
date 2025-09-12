<?php
header('Content-Type: application/json');
require_once 'db_connect.php';

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 1;

$sql = "SELECT id, user_id, bpm, mode, timestamp 
        FROM heart_data 
        WHERE user_id = ? 
        ORDER BY id DESC 
        LIMIT 50";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

// 反轉順序，讓最舊的在前
echo json_encode(["status" => "success", "data" => array_reverse($data)]);
