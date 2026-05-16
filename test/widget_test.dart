import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreamlog/main.dart';

void main() {
  testWidgets('DreamLog starts on the splash screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DreamLogApp(),
      ),
    );

    expect(find.text('DreamLog'), findsOneWidget);
  });
}
