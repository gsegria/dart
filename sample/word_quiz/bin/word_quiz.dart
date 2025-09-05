import 'dart:io';

void main() {
  final questions = {
    'apple': '蘋果',
    'banana': '香蕉',
    'cat': '貓',
    'dog': '狗',
    'sun': '太陽',
  };

  int score = 0;

  print('🎯 單字小測驗開始！請輸入對應的中文意思。\n');

  for (var word in questions.keys) {
    stdout.write('👉 $word: ');
    String? answer = stdin.readLineSync();

    if (answer == null || answer.trim().isEmpty) {
      print('⚠️ 未輸入，跳過。\n');
      continue;
    }

    if (answer.trim() == questions[word]) {
      print('✅ 正確！\n');
      score++;
    } else {
      print('❌ 錯誤，正確答案是：${questions[word]}\n');
    }
  }

  print('🎉 測驗結束！你總共答對了 $score / ${questions.length} 題。');
}
