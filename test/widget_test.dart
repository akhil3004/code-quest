import 'package:flutter_test/flutter_test.dart';

import 'package:code_quest/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const CodeQuestApp());

    expect(find.textContaining('CODE QUEST', findRichText: true), findsWidgets);
  });
}
