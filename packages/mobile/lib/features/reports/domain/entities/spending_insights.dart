class SpendingInsights {
  final DateTime? highestDayDate;
  final double highestDayAmount;
  final double avgDailySpending;
  final int totalTransactionCount;
  final double totalSpent;

  const SpendingInsights({
    this.highestDayDate,
    required this.highestDayAmount,
    required this.avgDailySpending,
    required this.totalTransactionCount,
    required this.totalSpent,
  });
}
