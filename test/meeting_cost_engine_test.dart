import 'package:flutter_test/flutter_test.dart';

import 'package:burn_rate/meeting_cost_engine.dart';

void main() {
  test('converts annual salary to an hourly burn rate', () {
    final rate = calculateHourlyRate(attendeeCount: 4, averageSalary: 156000);

    expect(rate, 300);
  });

  test('calculates the live meeting cost from elapsed time', () {
    final cost = calculateMeetingCost(
      elapsed: const Duration(minutes: 10),
      attendeeCount: 4,
      averageSalary: 156000,
    );

    expect(cost, closeTo(50, 0.0001));
  });

  test('formats currency as a gas-pump style dollars-and-cents value', () {
    expect(formatCurrency(12345.678), '\$12,345.67');
  });
}
