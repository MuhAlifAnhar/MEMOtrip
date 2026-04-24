import 'package:flutter_test/flutter_test.dart';
import 'package:memotrip/app/app.dart';

void main() {
  testWidgets('MEMOtrip app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoTripApp());
    // Verify the dashboard greeting is present
    expect(find.textContaining('Selamat'), findsOneWidget);
  });
}
