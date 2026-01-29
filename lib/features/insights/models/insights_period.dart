/// Time period for insights analytics
enum InsightsPeriod {
  week,
  month,
  year;

  /// Number of days in the period
  int get days {
    switch (this) {
      case InsightsPeriod.week:
        return 7;
      case InsightsPeriod.month:
        return 30;
      case InsightsPeriod.year:
        return 365;
    }
  }

  /// Display label for the period
  String get label {
    switch (this) {
      case InsightsPeriod.week:
        return 'Week';
      case InsightsPeriod.month:
        return 'Month';
      case InsightsPeriod.year:
        return 'Year';
    }
  }
}
