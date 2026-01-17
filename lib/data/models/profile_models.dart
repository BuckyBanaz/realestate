class UserProperty {
  final String title;
  final String location;
  final String tag; // Sale / Rent / Booking
  final String date;
  final bool completed;
  final String image;

  UserProperty(
    this.title,
    this.location,
    this.tag,
    this.date,
    this.completed,
    this.image,
  );
}

class UserPayment {
  final String title;
  final String location;
  final String date;
  final num amount;
  final bool paid;
  UserPayment(this.title, this.location, this.date, this.amount, this.paid);
}
