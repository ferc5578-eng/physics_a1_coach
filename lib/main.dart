import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 引入剪贴板服务

void main() => runApp(PhysicsApp());

class PhysicsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _labs = [NewtonsLawLab(), KineticEnergyLab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _labs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.indigo,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'F = ma (力学)'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Ek = ½mv² (动能)'),
        ],
      ),
    );
  }
}

// === 牛顿第二定律模块 ===
class NewtonsLawLab extends StatefulWidget {
  @override
  _NewtonsLawLabState createState() => _NewtonsLawLabState();
}

class _NewtonsLawLabState extends State<NewtonsLawLab> with SingleTickerProviderStateMixin {
  double mass = 5.0; 
  double acceleration = 2.0; 
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 核心功能：生成 Markdown 并复制
  void _exportNotes(BuildContext context, double force) {
    String markdownNote = """
### 📗 IGCSE 物理实验：牛顿第二定律

- **核心公式**：\$F = ma\$
- **当前参数**：质量 \$m = ${mass.toStringAsFixed(1)}\\text{ kg}\$，加速度 \$a = ${acceleration.toStringAsFixed(1)}\\text{ m/s}^2\$
- **实验结论**：合外力 \$F = ${force.toStringAsFixed(1)}\\text{ N}\$

> **💡 考点提醒**：当质量一定时，物体的加速度与所受合外力成正比。
""";

    Clipboard.setData(ClipboardData(text: markdownNote)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 笔记已复制，可直接粘贴至 Obsidian 等 Markdown 软件中！'),
          behavior: SnackBarBehavior.floating,
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double force = mass * acceleration;
    _controller.duration = Duration(milliseconds: (2000 / (acceleration.abs() + 0.1)).toInt());

    return Scaffold(
      appBar: AppBar(title: Text('力学实验: F = ma'), backgroundColor: Colors.indigo.shade100),
      body: Column(
        children: [
          Container(
            height: 200, color: Colors.grey.shade100,
            child: Stack(
              children: [
                Center(child: Text("F = ${force.toStringAsFixed(1)} N", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo))),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Positioned(
                      left: (MediaQuery.of(context).size.width * _controller.value) - 50,
                      bottom: 50,
                      child: Icon(Icons.directions_car, size: 60, color: Colors.indigo),
                    );
                  },
                ),
                Positioned(bottom: 45, child: Container(height: 2, width: MediaQuery.of(context).size.width, color: Colors.black)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Mass (质量): ${mass.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 18)),
                        Slider(value: mass, min: 1, max: 20, onChanged: (v) => setState(() => mass = v)),
                        SizedBox(height: 20),
                        Text('Acceleration (加速度): ${acceleration.toStringAsFixed(1)} m/s²', style: TextStyle(fontSize: 18)),
                        Slider(value: acceleration, min: 0, max: 10, onChanged: (v) => setState(() => acceleration = v)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // 新增：悬浮导出按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _exportNotes(context, force),
        icon: Icon(Icons.content_copy),
        label: Text('导出笔记'),
        backgroundColor: Colors.indigo.shade200,
      ),
    );
  }
}

// === 动能模块 ===
class KineticEnergyLab extends StatefulWidget {
  @override
  _KineticEnergyLabState createState() => _KineticEnergyLabState();
}

class _KineticEnergyLabState extends State<KineticEnergyLab> {
  double mass = 5.0;
  double velocity = 5.0;

  void _exportNotes(BuildContext context, double ke) {
    String markdownNote = """
### 📙 IGCSE 物理实验：动能定理

- **核心公式**：\$E_k = \\frac{1}{2}mv^2\$
- **当前参数**：质量 \$m = ${mass.toStringAsFixed(1)}\\text{ kg}\$，速度 \$v = ${velocity.toStringAsFixed(1)}\\text{ m/s}\$
- **实验结论**：系统总动能 \$E_k = ${ke.toStringAsFixed(1)}\\text{ Joules}\$

> **💡 考点提醒**：动能与速度的平方成正比。速度翻倍，动能会变成原来的 4 倍！在答题时千万不要漏掉平方符号。
""";

    Clipboard.setData(ClipboardData(text: markdownNote)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 笔记已复制为 Markdown 格式！'),
          behavior: SnackBarBehavior.floating,
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double kineticEnergy = 0.5 * mass * velocity * velocity;
    double maxEnergy = 0.5 * 20 * 20 * 20;

    return Scaffold(
      appBar: AppBar(title: Text('动能实验: Ek = ½mv²'), backgroundColor: Colors.amber.shade100),
      body: Column(
        children: [
          Container(
            height: 250, padding: EdgeInsets.all(20), color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${kineticEnergy.toInt()} J', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                    SizedBox(height: 10),
                    Container(
                      width: 60, height: 150,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: kineticEnergy / maxEnergy,
                        child: Container(decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Energy Tank', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('E_k = ½ m v²', style: TextStyle(fontSize: 28, fontStyle: FontStyle.italic)),
                    SizedBox(height: 20),
                    Text('½ × ${mass.toStringAsFixed(1)} × (${velocity.toStringAsFixed(1)})² \n= ${kineticEnergy.toStringAsFixed(1)} Joules', 
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Mass (质量 m): ${mass.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 18)),
                        Slider(value: mass, min: 1, max: 20, onChanged: (v) => setState(() => mass = v), activeColor: Colors.amber),
                        SizedBox(height: 20),
                        Text('Velocity (速度 v): ${velocity.toStringAsFixed(1)} m/s', style: TextStyle(fontSize: 18)),
                        Slider(value: velocity, min: 0, max: 20, onChanged: (v) => setState(() => velocity = v), activeColor: Colors.amber),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _exportNotes(context, kineticEnergy),
        icon: Icon(Icons.content_copy),
        label: Text('导出笔记'),
        backgroundColor: Colors.amber.shade300,
      ),
    );
  }
}