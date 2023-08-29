import 'package:flutter_test/flutter_test.dart';
import 'package:my_tuner/app/app.dart';
import 'package:my_tuner/counter/counter.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
