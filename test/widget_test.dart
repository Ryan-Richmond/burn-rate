import 'package:flutter_test/flutter_test.dart';

import 'package:meeting_cost_clock/meeting_cost_clock_app.dart';

void main() {
  testWidgets('renders meeting cost controls', (WidgetTester tester) async {
    await tester.pumpWidget(const MeetingCostClockApp());

    expect(find.text('Meeting Cost Clock'), findsOneWidget);
    expect(find.text('Number of attendees'), findsOneWidget);
    expect(find.text('Average annual salary (USD)'), findsOneWidget);
    expect(find.text('Push Ahead'), findsOneWidget);
  });
}
