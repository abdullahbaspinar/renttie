class HomeSummary {
  const HomeSummary({
    required this.monthLabel,
    required this.totalExpected,
    required this.received,
    required this.overdue,
  });

  final String monthLabel;
  final int totalExpected;
  final int received;
  final int overdue;

  double get receivedRatio =>
      totalExpected == 0 ? 0 : received / totalExpected;

  double get overdueRatio =>
      totalExpected == 0 ? 0 : overdue / totalExpected;
}
