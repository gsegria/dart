// client.dart
import 'dart:io';
import 'dart:convert';

void main() async {
  final String serverIp = '192.168.0.138'; // 請換成你的 Python server IP
  final int port = 65432;

  try {
    Socket socket = await Socket.connect(serverIp, port);
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

    // 發送訊息
    String message = "Hello from Dart!";
    socket.write(message);
    print("Sent: $message");

    // 接收 server 回應
    socket.listen(
      (List<int> data) {
        print("Server: ${utf8.decode(data)}");
        socket.destroy(); // 關閉連線
      },
      onError: (error) {
        print("Error: $error");
        socket.destroy();
      },
      onDone: () {
        print("Connection closed by server.");
      },
    );
  } catch (e) {
    print("Could not connect: $e");
  }
}
