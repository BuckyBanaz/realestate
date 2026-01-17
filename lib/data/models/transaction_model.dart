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
    return TransactionModel(
      propertyName: json['property_name'] ?? "",
      date: json['date'] ?? "",
      amount: json['amount'] ?? "",
      amountValue: json['amount_value'] ?? 0,
      emiNumber: json['emi_number'] ?? 0,
      paymentType: json['payment_type'] ?? "",
      status: json['status'] ?? "",
      statusColor: json['status_color'] ?? "grey",
      icon: json['icon'] ?? "info",
    );
  }
}
