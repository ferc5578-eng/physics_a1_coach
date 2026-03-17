import 'package:flutter/material.dart';

void main() => runApp(PhysicsQuizApp());

// --- 1. 数据结构定义 (MVP 题库) ---
class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

// 模拟数据库里的 5 道 SUVAT 题目
final List<Question> suvatQuestions = [
  Question(
    id: "Q001",
    text: "A car accelerates uniformly from rest at 2.0 m/s² for 5.0 s. What is its final velocity?",
    options: ["2.5 m/s", "5.0 m/s", "10.0 m/s", "25.0 m/s"],
    correctIndex: 2,
    explanation: "第一步：提取已知条件。from rest 意味着 u=0，a=2.0，t=5.0。求 v。\n第二步：选择公式 v = u + at。\n第三步：计算 v = 0 + (2.0 × 5.0) = 10.0 m/s。",
  ),
  Question(
    id: "Q002",
    text: "An object is dropped from a tall building. Assuming air resistance is negligible (g = 9.81 m/s²), how far does it fall in 3.0 s?",
    options: ["14.7 m", "29.4 m", "44.1 m", "88.2 m"],
    correctIndex: 2,
    explanation: "第一步：提取条件。dropped 意味着 u=0，a=9.81，t=3.0。求位移 s。\n第二步：选择公式 s = ut + ½at²。\n第三步：计算 s = 0 + 0.5 × 9.81 × (3.0)² = 44.145 m ≈ 44.1 m。",
  ),
  Question(
    id: "Q003",
    text: "A train travelling at 20 m/s decelerates uniformly to a halt in 10 s. What is the total distance travelled during this deceleration?",
    options: ["50 m", "100 m", "200 m", "400 m"],
    correctIndex: 1,
    explanation: "第一步：提取条件。u=20，halt 意味着 v=0，t=10。求 s。\n第二步：选择不需要加速度 a 的公式：s = ½(u+v)t。\n第三步：计算 s = 0.5 × (20 + 0) × 10 = 100 m。",
  ),
  Question(
    id: "Q004",
    text: "A ball is thrown vertically upwards with an initial velocity of 15 m/s. What is the maximum height it reaches? (g = 9.81 m/s²)",
    options: ["11.5 m", "15.0 m", "22.9 m", "30.0 m"],
    correctIndex: 0,
    explanation: "第一步：提取条件。u=15，最高点意味着 v=0，向上运动 a = -9.81。求 s。\n第二步：选择不含时间 t 的公式：v² = u² + 2as。\n第三步：代入 0 = 15² + 2(-9.81)s，得出 19.62s = 225，s ≈ 11.47 m。",
  ),
  Question(
    id: "Q005",
    text: "A racing car covers a distance of 50 m while accelerating uniformly from 5.0 m/s at a rate of 3.0 m/s². What is its final velocity?",
    options: ["12.5 m/s", "15.0 m/s", "18.0 m/s", "20.0 m/s"],
    correctIndex: 2,
    explanation: "第一步：提取条件。s=50，u=5.0，a=3.0。求 v。\n第二步：选择公式 v² = u² + 2as。\n第三步：代入 v² = 5.0² + 2(3.0)(50) = 25 + 300 = 325。v = √325 ≈ 18.0 m/s。",
  ),
];

// --- 2. 主程序框架 ---
class PhysicsQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: MainDashboard(),
    );
  }
}

// 全局状态管理（MVP 阶段暂存在内存中）
List<Map<String, dynamic>> wrongQuestions = [];

class MainDashboard extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 动态生成两个 Tab 页面
    final List<Widget> _pages = [
      QuizScreen(onQuizFinished: () => setState(() {})), // 答题页
      MistakeBookScreen(), // 错题本页
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.teal,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Module 1.3 测试'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${wrongQuestions.length}'), // 动态显示错题数量
              isLabelVisible: wrongQuestions.isNotEmpty,
              child: Icon(Icons.menu_book),
            ),
            label: '我的错题本',
          ),
        ],
      ),
    );
  }
}

// --- 3. 刷题引擎 UI ---
class QuizScreen extends StatefulWidget {
  final VoidCallback onQuizFinished;
  QuizScreen({required this.onQuizFinished});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQIndex = 0;
  int? selectedOption;
  bool isSubmitted = false;
  int score = 0;
  bool quizEnded = false;

  void _submitAnswer() {
    if (selectedOption == null) return;
    
    Question currentQ = suvatQuestions[currentQIndex];
    bool isCorrect = (selectedOption == currentQ.correctIndex);

    if (isCorrect) {
      score++;
    } else {
      // 记录到错题本
      bool alreadyExists = wrongQuestions.any((q) => q['question'].id == currentQ.id);
      if (!alreadyExists) {
        wrongQuestions.add({
          'question': currentQ,
          'user_answer': currentQ.options[selectedOption!],
        });
      }
    }

    setState(() {
      isSubmitted = true;
    });
  }

  void _nextQuestion() {
    if (currentQIndex < suvatQuestions.length - 1) {
      setState(() {
        currentQIndex++;
        selectedOption = null;
        isSubmitted = false;
      });
    } else {
      setState(() {
        quizEnded = true;
      });
      widget.onQuizFinished(); // 通知外层更新错题数量
    }
  }

  void _restartQuiz() {
    setState(() {
      currentQIndex = 0;
      selectedOption = null;
      isSubmitted = false;
      score = 0;
      quizEnded = false;
      wrongQuestions.clear();
    });
    widget.onQuizFinished();
  }

  @override
  Widget build(BuildContext context) {
    if (quizEnded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎯 测试完成！', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('你的得分: $score / ${suvatQuestions.length}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: Icon(Icons.refresh),
              label: Text('重新测试'),
            ),
            SizedBox(height: 20),
            Text('💡 提示：点击底部导航栏查看错题本解析', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    Question q = suvatQuestions[currentQIndex];

    return Scaffold(
      appBar: AppBar(title: Text('SUVAT 运动方程测试 (${currentQIndex + 1}/${suvatQuestions.length})')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(q.text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            SizedBox(height: 30),
            ...List.generate(q.options.length, (index) {
              Color buttonColor = Colors.white;
              Color textColor = Colors.black87;
              
              if (isSubmitted) {
                if (index == q.correctIndex) {
                  buttonColor = Colors.green.shade100; // 正确答案标绿
                } else if (index == selectedOption && index != q.correctIndex) {
                  buttonColor = Colors.red.shade100; // 选错的标红
                }
              } else if (selectedOption == index) {
                buttonColor = Colors.teal.shade50;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: isSubmitted ? null : () => setState(() => selectedOption = index),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      border: Border.all(color: selectedOption == index ? Colors.teal : Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("${String.fromCharCode(65 + index)}.  ${q.options[index]}", style: TextStyle(fontSize: 18, color: textColor)),
                  ),
                ),
              );
            }),
            Spacer(),
            if (isSubmitted)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("👨‍🏫 核心解析：", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text(q.explanation, style: TextStyle(fontSize: 16, height: 1.5)),
                  ],
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16), backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: selectedOption == null ? null : (isSubmitted ? _nextQuestion : _submitAnswer),
              child: Text(isSubmitted ? (currentQIndex == suvatQuestions.length - 1 ? '查看成绩' : '下一题') : '提交答案', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. 错题本 UI ---
class MistakeBookScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (wrongQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thumb_up, size: 80, color: Colors.green.shade200),
            SizedBox(height: 20),
            Text("太棒了！目前没有错题 🎉", style: TextStyle(fontSize: 24, color: Colors.grey.shade700)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('我的错题本 (${wrongQuestions.length}题)'), backgroundColor: Colors.red.shade50),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: wrongQuestions.length,
        itemBuilder: (context, index) {
          final item = wrongQuestions[index];
          final Question q = item['question'];
          final String userAnswer = item['user_answer'];

          return Card(
            elevation: 3,
            margin: EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(5)),
                        child: Text("错题 ${index + 1}", style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 10),
                      Text("ID: ${q.id}", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(q.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text("❌ 你的答案: $userAnswer", style: TextStyle(color: Colors.red, fontSize: 16)),
                  Text("✅ 正确答案: ${q.options[q.correctIndex]}", style: TextStyle(color: Colors.green, fontSize: 16)),
                  Divider(height: 30, thickness: 1),
                  Text("📝 分步解析:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  SizedBox(height: 8),
                  Text(q.explanation, style: TextStyle(height: 1.5, color: Colors.black87)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}