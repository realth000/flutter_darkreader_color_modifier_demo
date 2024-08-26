import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

extension ColorExt on Color {
  Color _inverted() {
    final r = 255 - red;
    final g = 255 - green;
    final b = 255 - blue;

    return Color.fromARGB((opacity * 255).round(), r, g, b);
  }
}

class ColorBlock extends StatelessWidget {
  const ColorBlock(this.color, {super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      color: color,
      child: Text(
        color.toString(),
        style: TextStyle(
          color: color._inverted(),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color color1 = const Color.fromRGBO(237, 244, 140, 1);

  late TextEditingController rc;
  late TextEditingController gc;
  late TextEditingController bc;
  @override
  void initState() {
    super.initState();

    rc = TextEditingController();
    gc = TextEditingController();
    bc = TextEditingController();
  }

  @override
  void dispose() {
    rc.dispose();
    gc.dispose();
    bc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color2 = adaptColor(color1);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorBlock(color1),
                ColorBlock(color2),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: rc,
                      decoration: const InputDecoration(label: Text('Red')),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: gc,
                      decoration: const InputDecoration(label: Text('Green')),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: bc,
                      decoration: const InputDecoration(label: Text('Blue')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    child: const Text('Calculate'),
                    onPressed: () {
                      setState(() {
                        color1 = Color.fromRGBO(
                          int.parse(rc.text),
                          int.parse(gc.text),
                          int.parse(bc.text),
                          1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef Matrix5 = List<List<num>>;

const identifiedMatrix = [
  [1, 0, 0, 0, 0],
  [0, 1, 0, 0, 0],
  [0, 0, 1, 0, 0],
  [0, 0, 0, 1, 0],
  [0, 0, 0, 0, 1],
];

const invertNHueMatrix = [
  [0.333, -0.667, -0.667, 0, 1],
  [-0.667, 0.333, -0.667, 0, 1],
  [-0.667, -0.667, 0.333, 0, 1],
  [0, 0, 0, 1, 0],
  [0, 0, 0, 0, 1],
];

Color adaptColor(Color color) {
  final matrix = multiplyMatrix(identifiedMatrix, invertNHueMatrix);
  final c1 = applyColorMatrix(color, matrix);

  return Color.fromRGBO(c1[0] as int, c1[1] as int, c1[2] as int, 100);
}

Matrix5 multiplyMatrix(Matrix5 m1, Matrix5 m2) {
  Matrix5 result = List.generate(
    m1.length,
    (_) => List.generate(
      m2.length,
      (_) => 0,
    ),
  );
  for (var i = 0, len = m1.length; i < len; i++) {
    result[i] = List.generate(len, (_) => 0);
    for (var j = 0, len2 = m2[0].length; j < len2; j++) {
      num sum = 0;
      // 3. m1[0].length是列数
      for (var k = 0, len3 = m1[0].length; k < len3; k++) {
        sum += m1[i][k] * m2[k][j];
      }
      result[i][j] = sum;
    }
  }
  return result;
}

List<num> applyColorMatrix(Color color, Matrix5 m) {
  final m5x1 = [
    [color.red / 255],
    [color.green / 255],
    [color.blue / 255],
    [1],
    [1],
  ];

  final result = multiplyMatrix(m, m5x1);

  return [0, 1, 2]
      .map((e) => clamp((result[e][0] * 255).round(), 0, 255))
      .toList();
}

num clamp(num x, num min, num max) {
  return math.min(max, math.max(min, x));
}
