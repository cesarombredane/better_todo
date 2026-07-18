import 'package:better_todo/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'TODO',
              style: TextStyle(
                color: AppColors.yellow,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
