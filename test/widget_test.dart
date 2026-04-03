import 'package:flutter_test/flutter_test.dart';

import 'package:burn_rate/burn_rate_app.dart';

void main() {
  testWidgets('renders meeting cost controls', (WidgetTester tester) async {
    await tester.pumpWidget(const BurnRateApp());

    expect(find.text('Burn Rate'), findsOneWidget);
    expect(find.text('Number of attendees'), findsOneWidget);
    expect(find.text('Average annual salary (USD)'), findsOneWidget);
    expect(find.text('Push Ahead'), findsOneWidget);
  });
}
