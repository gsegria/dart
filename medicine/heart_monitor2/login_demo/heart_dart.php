<?php
header('Content-Type: application/json');
require_once 'db_connect.php';

$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
$bpm     = isset($_POST['bpm']) ? intval($_POST['bpm']) : 0;
$mode    = isset($_POST['mode']) ? $_POST['mode'] : 'rest';

if ($user_id <= 0 || $bpm <= 0) {
    echo json_encode(["status" => "error", "msg" => "缺少參數"]);
    exit;
}

$sql = "INSERT INTO heart_data (user_id, bpm, mode) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("iis", $user_id, $bpm, $mode);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "msg" => "上傳成功"]);
} else {
    echo json_encode(["status" => "error", "msg" => "資料庫錯誤"]);
}
