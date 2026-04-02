const double workingHoursPerYear = 2080;
const Duration displayRefreshInterval = Duration(milliseconds: 50);

int? parseAttendeeCount(String rawValue) {
  final cleaned = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) {
    return null;
  }
  return int.tryParse(cleaned);
}

double? parseSalary(String rawValue) {
  final cleaned = rawValue.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) {
    return null;
  }
  return double.tryParse(cleaned);
}

double calculateHourlyRate({
  required int attendeeCount,
  required double averageSalary,
}) {
  return attendeeCount * averageSalary / workingHoursPerYear;
}

double calculatePerMinuteRate({
  required int attendeeCount,
  required double averageSalary,
}) {
  return calculateHourlyRate(
        attendeeCount: attendeeCount,
        averageSalary: averageSalary,
      ) /
      60;
}

double calculatePerSecondRate({
  required int attendeeCount,
  required double averageSalary,
}) {
  return calculateHourlyRate(
        attendeeCount: attendeeCount,
        averageSalary: averageSalary,
      ) /
      3600;
}

double calculateMeetingCost({
  required Duration elapsed,
  required int attendeeCount,
  required double averageSalary,
}) {
  return calculatePerSecondRate(
        attendeeCount: attendeeCount,
        averageSalary: averageSalary,
      ) *
      (elapsed.inMilliseconds / 1000);
}

String formatCurrency(double value) {
  final normalized = value.isFinite && value > 0 ? value : 0.0;
  final cents = (normalized * 100).floor();
  final dollars = cents ~/ 100;
  final fractional = (cents % 100).toString().padLeft(2, '0');

  final groupedDollars = dollars.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  return '\$$groupedDollars.$fractional';
}

String formatElapsed(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
