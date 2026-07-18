import 'package:better_todo/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home page displays the app title and initial content', (
    tester,
  ) async {
    await tester.pumpWidget(const BetterTodoApp());

    expect(find.text('Better Todo'), findsOneWidget);
    expect(find.text('TEST'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
