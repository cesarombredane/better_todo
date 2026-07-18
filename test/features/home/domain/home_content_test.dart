import 'package:better_todo/features/home/domain/home_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeContent', () {
    test('provides the initial home message', () {
      expect(const HomeContent.initial().message, 'TEST');
    });

    test('accepts custom content', () {
      const content = HomeContent(message: 'Custom');

      expect(content.message, 'Custom');
    });
  });
}
