/// The signed-in member's current-year "Annual Subscription" contribution
/// status — mirrors the website's app/[locale]/member/page.tsx dashboard
/// card. `null` (never constructed) when no "annual subscription"
/// contribution type exists on the backend yet.
class AnnualSubscription {
  const AnnualSubscription({
    required this.year,
    required this.amount,
    required this.isPaid,
  });

  factory AnnualSubscription.fromJson(Map<String, dynamic> json) {
    return AnnualSubscription(
      year: json['year'] as int,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      isPaid: json['isPaid'] as bool? ?? false,
    );
  }

  final int year;
  final double amount;
  final bool isPaid;
}
