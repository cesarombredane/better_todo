import 'package:better_todo/app/theme/app_theme.dart';
import 'package:better_todo/features/home/domain/home_content.dart';
import 'package:better_todo/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';

class BetterTodoApp extends StatelessWidget {
  const BetterTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Todo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(content: HomeContent.initial()),
    );
  }
}
