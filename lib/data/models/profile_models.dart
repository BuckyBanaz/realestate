class TransactionModel {
  final String id;
  final String property;
  final String location;
  final DateTime date;
  final num amount;
  final String type; // "Received" / "Paid"
  final String status; // "Completed" / "Pending"
  final String reference;
  final String image;

  TransactionModel({
    required this.id,
    required this.property,
    required this.location,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
    required this.reference,
    required this.image,
  });
}

class Property {
  final String title;
  final String location;
  final String tag; // Sale / Rent / Booking
  final String date;
  final bool completed;
  final String image; // new

  Property(
    this.title,
    this.location,
    this.tag,
    this.date,
    this.completed,
    this.image,
  );
}

class Payment {
  final String title;
  final String location;
  final String date;
  final num amount;
  final bool paid;
  Payment(this.title, this.location, this.date, this.amount, this.paid);
}
