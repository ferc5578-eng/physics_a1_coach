import 'package:flutter/material.dart';

void main() => runApp(PhysicsApp());

class PhysicsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: MainNavigation(), // 升级为带底部导航栏的主框架
    );
  }
}

// === 导航框架 (负责切换不同的实验) ===
class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  // 存放我们的两个物理实验模块
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

// === 新增模块：动能实验室 ===
class KineticEnergyLab extends StatefulWidget {
  @override
  _KineticEnergyLabState createState() => _KineticEnergyLabState();
}

class _KineticEnergyLabState extends State<KineticEnergyLab> {
  double mass = 5.0; // kg
  double velocity = 5.0; // m/s

  @override
  Widget build(BuildContext context) {
    // 实时计算动能
    double kineticEnergy = 0.5 * mass * velocity * velocity;
    double maxEnergy = 0.5 * 20 * 20 * 20; // 设定滑块最大值时的总能量 4000J

    return Scaffold(
      appBar: AppBar(title: Text('动能实验: Ek = ½mv²'), backgroundColor: Colors.amber.shade100),
      body: Column(
        children: [
          // 1. 动态模拟区 (能量槽)
          Container(
            height: 250,
            padding: EdgeInsets.all(20),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 能量柱
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
                        heightFactor: kineticEnergy / maxEnergy, // 动态高度
                        child: Container(decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Energy Tank', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                // 公式推导展示
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
          
          // 2. 控制区
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
                SizedBox(height: 20),
                Text('💡 学习笔记：拖动速度滑块时，注意观察左侧能量槽的“暴涨”。因为速度是平方关系，它对动能的影响远大于质量！', 
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// === 保留之前的模块：牛顿第二定律 ===
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
    );
  }
}