import 'package:flutter/material.dart';

void main() {
  runApp(const BetterTodoApp());
}

class BetterTodoApp extends StatelessWidget {
  const BetterTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Better Todo')),
        body: const Center(
          child: Text('TEST', style: TextStyle(fontSize: 48)),
        ),
      ),
    );
  }
}
