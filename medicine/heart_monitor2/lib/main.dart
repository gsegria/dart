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

enum DisplayMode { local, database, both }

class HeartHomePage extends StatefulWidget {
  @override
  _HeartHomePageState createState() => _HeartHomePageState();
}

class _HeartHomePageState extends State<HeartHomePage> {
  final int userId = 32;
  final String uploadUrl = 'http://localhost/login_demo/heart_dart.php';
  final String listUrl = 'http://localhost/login_demo/heart_list_draw.php';

  String mode = 'rest';
  DisplayMode displayMode = DisplayMode.both;

  List<Map<String, dynamic>> localHistory = [];
  List<Map<String, dynamic>> dbHistory = [];

  Timer? bpmTimer;
  Timer? modeTimer;
  Timer? fetchTimer;

  @override
  void initState() {
    super.initState();
    bpmTimer = Timer.periodic(Duration(seconds: 1), (_) => generateBPM());
    modeTimer = Timer.periodic(Duration(seconds: 10), (_) => toggleMode());
    fetchTimer = Timer.periodic(Duration(seconds: 5), (_) => fetchBPMData());
  }

  @override
  void dispose() {
    bpmTimer?.cancel();
    modeTimer?.cancel();
    fetchTimer?.cancel();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      mode = (mode == 'rest') ? 'exercise' : 'rest';
    });
  }

  int generateRandomBPM() {
    final rand = Random();
    if (mode == 'rest') return 55 + rand.nextInt(26);
    return 90 + rand.nextInt(61);
  }

  void generateBPM() {
    int bpm = generateRandomBPM();
    final now = DateTime.now().toIso8601String();
    setState(() {
      localHistory.add({'timestamp': now, 'bpm': bpm, 'mode': mode});
      if (localHistory.length > 50) localHistory.removeAt(0);
    });
    
    // 立即打印要上傳的資料
    print('上傳資料: bpm=$bpm mode=$mode');

    uploadBPM(bpm);
  }

  Future<void> uploadBPM(int bpm) async {
  try {
    final response = await http.post(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'user_id': userId.toString(),
        'bpm': bpm.toString(),
        'mode': mode,
      },
    );

    // 立即打印 PHP 回傳的內容
    print('回傳: ${response.body}');

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


  Future<void> fetchBPMData() async {
    try {
      final response = await http.get(Uri.parse('$listUrl?user_id=$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            dbHistory = List<Map<String, dynamic>>.from(data['data']);
            if (dbHistory.length > 50) {
              dbHistory = dbHistory.sublist(dbHistory.length - 50);
            }
          });
        }
      }
    } catch (e) {
      print('抓取失敗: $e');
    }
  }

  Color modeColor(String mode) => mode == 'rest' ? Colors.blue : Colors.red;

  List<Map<String, dynamic>> getDisplayData() {
    if (displayMode == DisplayMode.local) return localHistory;
    if (displayMode == DisplayMode.database) return dbHistory;
    return [...localHistory, ...dbHistory]..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
  }

  void resetData() {
    setState(() {
      localHistory.clear();
      dbHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<LineChartBarData> chartData = [];

    if (displayMode == DisplayMode.local || displayMode == DisplayMode.both) {
      chartData.add(
        LineChartBarData(
          spots: localHistory
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), (e.value['bpm'] as int).toDouble()))
              .toList(),
          isCurved: true,
          color: Colors.red,
          dotData: FlDotData(show: false),
          barWidth: 2,
        ),
      );
    }

    if (displayMode == DisplayMode.database || displayMode == DisplayMode.both) {
      chartData.add(
        LineChartBarData(
          spots: dbHistory
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), (e.value['bpm'] as int).toDouble()))
              .toList(),
          isCurved: true,
          color: Colors.blue,
          dotData: FlDotData(show: false),
          barWidth: 2,
        ),
      );
    }

    final displayData = getDisplayData();

    return Scaffold(
      appBar: AppBar(title: Text('心跳模擬器')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 模式與切換
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('目前模式: $mode', style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    DropdownButton<DisplayMode>(
                      value: displayMode,
                      items: [
                        DropdownMenuItem(child: Text('本地'), value: DisplayMode.local),
                        DropdownMenuItem(child: Text('資料庫'), value: DisplayMode.database),
                        DropdownMenuItem(child: Text('本地+資料庫'), value: DisplayMode.both),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => displayMode = v);
                      },
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(onPressed: resetData, child: Text('清除列表')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // 心率顯示
            if (displayMode == DisplayMode.local || displayMode == DisplayMode.both)
              Text(
                '本地心率: ${localHistory.isNotEmpty ? localHistory.last['bpm'] : 0} BPM',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            if (displayMode == DisplayMode.database || displayMode == DisplayMode.both)
              Text(
                '資料庫心率: ${dbHistory.isNotEmpty ? dbHistory.last['bpm'] : 0} BPM',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            SizedBox(height: 20),
            // 圖表
            Expanded(
              flex: 2,
              child: LineChart(
                LineChartData(
                  minY: 40,
                  maxY: 160,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: chartData,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Table
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: displayData.length,
                itemBuilder: (context, index) {
                  final e = displayData[index];
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
