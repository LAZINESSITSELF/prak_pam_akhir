class Car {
  final String id;
  final String name;
  final String brand;
  final int modelYear;
  final double pricePerDay;
  final String status;
  final String description;
  final String? image;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.modelYear,
    required this.pricePerDay,
    required this.status,
    required this.description,
    this.image,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    // Pastikan untuk menangani null dengan memberikan nilai default
    return Car(
      id: json['_id'] ?? 'unknown', // Default jika _id null
      name: json['name'] ?? 'Unknown', // Default jika name null
      brand: json['brand'] ?? 'Unknown', // Default jika brand null
      modelYear: json['modelYear'] != null ? json['modelYear'] : 0, // Pastikan modelYear tidak null
      pricePerDay: json['pricePerDay'] != null ? json['pricePerDay'].toDouble() : 0.0, // Pastikan pricePerDay tidak null
      status: json['status'] ?? 'Unknown', // Default jika status null
      description: json['description'] ?? 'No description available', // Default jika description null
      image: json['image'], // Gambar bisa null
    );
  }
}
