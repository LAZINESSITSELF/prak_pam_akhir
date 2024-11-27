class Booking {
  final String id;
  final String user;
  final String car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    required this.user,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      user: json['userId'] is Map ? json['userId']['name'] : json['userId'],
      car: json['carId'] is Map ? json['carId']['name'] : json['carId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
    );
  }
}
