import 'package:better_todo/features/home/domain/home_content.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.content, super.key});

  final HomeContent content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Better Todo')),
      body: Center(
        child: Text(
          content.message,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
