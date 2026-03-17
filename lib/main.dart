import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(PhysicsApp());

class PhysicsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
      ),
      home: PhysicsLabPage(),
    );
  }
}

class PhysicsLabPage extends StatefulWidget {
  @override
  _PhysicsLabPageState createState() => _PhysicsLabPageState();
}

class _PhysicsLabPageState extends State<PhysicsLabPage> with SingleTickerProviderStateMixin {
  double mass = 5.0; // kg
  double acceleration = 2.0; // m/s²
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
    // 根据加速度改变小车动画速度
    _controller.duration = Duration(milliseconds: (2000 / (acceleration.abs() + 0.1)).toInt());

    return Scaffold(
      appBar: AppBar(
        title: Text('IGCSE Physics Lab: Newton\'s Second Law'),
        backgroundColor: Colors.indigo.shade100,
      ),
      body: Column(
        children: [
          // 1. 动态模拟区
          Container(
            height: 200,
            color: Colors.grey.shade100,
            child: Stack(
              children: [
                Center(child: Text("F = $force N", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo))),
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
                        Text('Mass (质量): ${mass.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 18)),
                        Slider(
                          value: mass, min: 1, max: 20,
                          onChanged: (v) => setState(() => mass = v),
                        ),
                        SizedBox(height: 20),
                        Text('Acceleration (加速度): ${acceleration.toStringAsFixed(1)} m/s²', style: TextStyle(fontSize: 18)),
                        Slider(
                          value: acceleration, min: 0, max: 10,
                          onChanged: (v) => setState(() => acceleration = v),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '💡 学习笔记：当质量 $mass kg 不变时，合外力与加速度成正比。',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}