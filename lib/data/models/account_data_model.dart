class AccountDataResponse {
  final bool status;
  final String message;
  final AccountData? data;

  AccountDataResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AccountDataResponse.fromJson(Map<String, dynamic> json) {
    return AccountDataResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      data: json['data'] != null ? AccountData.fromJson(json['data']) : null,
    );
  }
}

class AccountData {
  final Customer customer;
  final List<OwnedProperty> properties;

  AccountData({
    required this.customer,
    required this.properties,
  });

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      customer: Customer.fromJson(json['customer'] ?? {}),
      properties: (json['properties'] as List?)
              ?.map((e) => OwnedProperty.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
    );
  }
}

class OwnedProperty {
  final PropertyInfo property;
  final List<PropertyFinance> finance;

  OwnedProperty({
    required this.property,
    required this.finance,
  });

  factory OwnedProperty.fromJson(Map<String, dynamic> json) {
    return OwnedProperty(
      property: PropertyInfo.fromJson(json['property'] ?? {}),
      finance: (json['finance'] as List?)
              ?.map((e) => PropertyFinance.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PropertyInfo {
  final int id;
  final String title;
  final String address;
  final String image;
  final String saleDate;

  PropertyInfo({
    required this.id,
    required this.title,
    required this.address,
    required this.image,
    required this.saleDate,
  });

  factory PropertyInfo.fromJson(Map<String, dynamic> json) {
    return PropertyInfo(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      address: json['address'] ?? "",
      image: json['image'] ?? "",
      saleDate: json['sale_date'] ?? "",
    );
  }
}

class PropertyFinance {
  final int financeId;
  final String totalAmount;
  final String paidAmount;
  final String? balance;
  final List<PaymentItem> payments;

  PropertyFinance({
    required this.financeId,
    required this.totalAmount,
    required this.paidAmount,
    this.balance,
    required this.payments,
  });

  factory PropertyFinance.fromJson(Map<String, dynamic> json) {
    return PropertyFinance(
      financeId: json['finance_id'] ?? 0,
      totalAmount: json['total_amount'] ?? "0",
      paidAmount: json['paid_amount'] ?? "0",
      balance: json['balance'],
      payments: (json['payments'] as List?)
              ?.map((e) => PaymentItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PaymentItem {
  final int id;
  final int financeId;
  final int propertyId;
  final String paymentType;
  final int emiNumber;
  final String amount;
  final String paidDate;
  final String? paymentMode;
  final String? transactionId;
  final String status;
  final String createdAt;
  final String updatedAt;

  PaymentItem({
    required this.id,
    required this.financeId,
    required this.propertyId,
    required this.paymentType,
    required this.emiNumber,
    required this.amount,
    required this.paidDate,
    this.paymentMode,
    this.transactionId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'] ?? 0,
      financeId: json['finance_id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      paymentType: json['payment_type'] ?? "",
      emiNumber: json['emi_number'] ?? 0,
      amount: json['amount'] ?? "0",
      paidDate: json['paid_date'] ?? "",
      paymentMode: json['payment_mode'],
      transactionId: json['transaction_id'],
      status: json['status'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }
}
