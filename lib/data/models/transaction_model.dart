class TransactionResponse {
  final bool status;
  final String message;
  final List<TransactionModel> data;

  TransactionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      data: (json['data'] as List?)
              ?.map((e) => TransactionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TransactionModel {
  final String propertyName;
  final String date;
  final String amount;
  final dynamic amountValue;
  final int emiNumber;
  final String paymentType;
  final String status;
  final String statusColor;
  final String icon;

  TransactionModel({
    required this.propertyName,
    required this.date,
    required this.amount,
    required this.amountValue,
    required this.emiNumber,
    required this.paymentType,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final amountStr = json['amount'] ?? "";
    double parsedAmountValue = 0.0;
    if (json['amount_value'] != null) {
      parsedAmountValue = double.tryParse(json['amount_value'].toString()) ?? 0.0;
    } else if (amountStr.isNotEmpty) {
      // Remove currency symbols, commas, and whitespace, e.g. "₹1,433,337.30" -> "1433337.30"
      final cleanAmount = amountStr.toString().replaceAll(RegExp(r'[^\d.]'), '');
      parsedAmountValue = double.tryParse(cleanAmount) ?? 0.0;
    }

    return TransactionModel(
      propertyName: json['property_name'] ?? "",
      date: json['date'] ?? "",
      amount: amountStr,
      amountValue: parsedAmountValue,
      emiNumber: json['emi_number'] ?? 0,
      paymentType: json['payment_type'] ?? "",
      status: json['status'] ?? "",
      statusColor: json['status_color'] ?? "grey",
      icon: json['icon'] ?? "info",
    );
  }
}
