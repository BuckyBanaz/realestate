import 'package:get/get.dart';
import 'package:realestate/data/models/profile_models.dart';

class ProfileController extends GetxController {
  var selectedTab = 0.obs; // 0=Transaction, 1=my_property, 2=payments

  // Purchased / owned properties
  final List<TransactionModel> transactions = [
    TransactionModel(
      id: 'TXN001',
      property: 'Plot No. 21 Shree Shyam Kunj Phase 5',
      location: 'Raipur Road, Hisar',
      date: DateTime(2025, 11, 24),
      amount: 230000,
      type: 'Received',
      status: 'Completed',
      reference: 'REF-20251124-001',
      image:
          'https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg',
    ),
    TransactionModel(
      id: 'TXN002',
      property: 'Plot No. 78 Galaxy Residency',
      location: 'Sector 12, Hisar',
      date: DateTime(2025, 11, 18),
      amount: 520000,
      type: 'Received',
      status: 'Completed',
      reference: 'REF-20251118-002',
      image:
          'https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg',
    ),
    TransactionModel(
      id: 'TXN003',
      property: 'Block A - Park View Apartment',
      location: 'MG Road, Hisar',
      date: DateTime(2025, 10, 29),
      amount: 310000,
      type: 'Paid',
      status: 'Pending',
      reference: 'REF-20251029-003',
      image:
          'https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg',
    ),
    // more dummy transactions for the View All screen
    TransactionModel(
      id: 'TXN004',
      property: 'Plot No. 9 Sunny Acres',
      location: 'Ring Road, Hisar',
      date: DateTime(2025, 9, 5),
      amount: 125000,
      type: 'Received',
      status: 'Completed',
      reference: 'REF-20250905-004',
      image:
          'https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg',
    ),
    TransactionModel(
      id: 'TXN005',
      property: 'Shop No. 12 Market Plaza',
      location: 'Old Bazar, Hisar',
      date: DateTime(2025, 8, 23),
      amount: 45000,
      type: 'Paid',
      status: 'Completed',
      reference: 'REF-20250823-005',
      image:
          'https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg',
    ),
  ];
  // Upcoming payments (scheduled / due)
  final List<Payment> upcomingPayments = [
    Payment(
      "Plot No. 21 Shree Shyam Kunj Phase 5",
      "Raipur Road, Hisar",
      "Dec 05, 2025",
      230000,
      false,
    ),
    Payment(
      "hree Shyam Kunj Phase 5 Plot",
      "Raipur Road, Hisar",
      "Dec 20, 2025",
      520000,
      false,
    ),
  ];

  // Past payments
  final List<Payment> pastPayments = [
    Payment(
      "Plot No. 21 Shree Shyam Kunj Phase 5",
      "Raipur Road, Hisar",
      "Nov 01, 2025",
      89000,
      true,
    ),
    Payment(
      "Security Deposit - Shree Shyam Kunj Plot",
      "Raipur Road, Hisar",
      "Oct 10, 2025",
      3290,
      true,
    ),
  ];

  // Transactions (sale/rent actions) with location & date & image
  final List<Property> my_property = [
    Property(
      "Plot No. 21 Shree Shyam Kunj Phase 5",
      "Raipur Road, Hisar",
      "Sale",
      "January 10, 2025",
      true,
      "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    ),
    Property(
      "Plot No. 21 Shree Shyam Kunj Phase 5",
      "Raipur Road, Hisar",
      "Rent",
      "January 05, 2025",
      true,
      "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    ),
    Property(
      "Plot No. 21 Shree Shyam Kunj Phase 5",
      "Raipur Road, Hisar",
      "Booking",
      "September 15, 2025",
      true,
      "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    ),
  ];
}
