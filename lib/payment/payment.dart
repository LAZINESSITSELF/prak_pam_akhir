class Payment {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Method untuk membuat objek Payment dari map (biasanya digunakan ketika data diambil dari API)
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['_id'],
      bookingId: map['bookingId'],
      userId: map['userId'],
      amount: map['amount'].toDouble(),
      paymentMethod: map['paymentMethod'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
