import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(HeartApp());

class HeartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '心跳模擬器',
      home: HeartHomePage(),
    );
  }
}

class HeartHomePage extends StatefulWidget {
  @override
  _HeartHomePageState createState() => _HeartHomePageState();
}

class _HeartHomePageState extends State<HeartHomePage> {
  final int userId = 1;
  final String serverUrl = 'http://localhost/login_demo/heart_dart.php';
  String mode = 'rest';
  List<Map<String, dynamic>> bpmHistory = [];

  Timer? timer;
  Timer? modeTimer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) => generateBPM());
    modeTimer = Timer.periodic(Duration(seconds: 10), (_) => toggleMode());
  }

  @override
  void dispose() {
    timer?.cancel();
    modeTimer?.cancel();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      mode = (mode == 'rest') ? 'exercise' : 'rest';
    });
  }

  int generateRandomBPM() {
    final rand = Random();
    if (mode == 'rest') return 55 + rand.nextInt(26); // 55~80
    return 90 + rand.nextInt(61); // 90~150
  }

  void generateBPM() {
    int bpm = generateRandomBPM();
    final now = DateTime.now().toIso8601String();
    setState(() {
      bpmHistory.add({'timestamp': now, 'bpm': bpm, 'mode': mode});
      if (bpmHistory.length > 50) bpmHistory.removeAt(0);
    });
    uploadBPM(bpm);
  }

  Future<void> uploadBPM(int bpm) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': userId.toString(),
          'bpm': bpm.toString(),
          'mode': mode,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != 'success') {
          print('上傳失敗: ${data['msg']}');
        }
      } else {
        print('HTTP 錯誤: ${response.statusCode}');
      }
    } catch (e) {
      print('連線失敗: $e');
    }
  }

  Color modeColor(String mode) => mode == 'rest' ? Colors.blue : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('心跳模擬器')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('目前模式: $mode', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              '目前心率: ${bpmHistory.isNotEmpty ? bpmHistory.last['bpm'] : 0} BPM',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 40,
                  maxY: 160,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(showTitles: false),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: bpmHistory
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), (e.value['bpm'] as int).toDouble()))
                          .toList(),
                      isCurved: true,
                      colors: bpmHistory.map((e) => modeColor(e['mode'])).toList(),
                      dotData: FlDotData(show: false),
                      barWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: bpmHistory.length,
                itemBuilder: (context, index) {
                  final e = bpmHistory[index];
                  return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text('${e['bpm']} BPM'),
                    subtitle: Text('${e['timestamp']}'),
                    trailing: Text(
                      e['mode'],
                      style: TextStyle(color: modeColor(e['mode'])),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
