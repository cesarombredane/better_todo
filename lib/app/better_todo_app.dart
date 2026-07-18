import 'package:better_todo/features/home/home_page.dart';
import 'package:better_todo/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BetterTodoApp extends StatelessWidget {
  const BetterTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Todo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomePage(),
    );
  }
}
