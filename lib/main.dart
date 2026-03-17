import 'package:flutter/material.dart';

void main() => runApp(PhysicsApp());

class PhysicsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: ForceCalculator(),
    );
  }
}

class ForceCalculator extends StatefulWidget {
  @override
  _ForceCalculatorState createState() => _ForceCalculatorState();
}

class _ForceCalculatorState extends State<ForceCalculator> {
  double mass = 0;
  double acceleration = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('A1 物理实验台: F = ma')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 质量输入
            TextField(
              decoration: InputDecoration(labelText: '质量 Mass (kg)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => mass = double.tryParse(value) ?? 0),
            ),
            SizedBox(height: 20),
            // 加速度输入
            TextField(
              decoration: InputDecoration(labelText: '加速度 Acceleration (m/s²)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => acceleration = double.tryParse(value) ?? 0),
            ),
            Divider(height: 50),
            // 结果显示
            Text('计算得出的合外力 (Force):', style: TextStyle(fontSize: 18)),
            Text(
              '${(mass * acceleration).toStringAsFixed(2)} N',
              style: TextStyle(fontSize: 48, fontWeight: .bold, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}