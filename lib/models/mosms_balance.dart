class MoSmsBalance {
  const MoSmsBalance({
    required this.smsBalance,
    required this.whatsappBalance,
    this.whatsappPrice,
  });

  factory MoSmsBalance.fromJson(Map<String, dynamic> json) {
    return MoSmsBalance(
      smsBalance: (json['smsBalance'] as num?)?.toInt() ?? 0,
      whatsappBalance: (json['whatsappBalance'] as num?)?.toInt() ?? 0,
      whatsappPrice: json['whatsappPrice'] != null
          ? double.tryParse(json['whatsappPrice'].toString())
          : null,
    );
  }

  final int smsBalance;
  final int whatsappBalance;
  final double? whatsappPrice;
}
