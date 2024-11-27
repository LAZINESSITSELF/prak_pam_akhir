import 'package:carental/APIconfig/api_conf.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'car.dart';

class CarDetailPage extends StatefulWidget {
  final Car car;

  CarDetailPage({required this.car});

  @override
  _CarDetailPageState createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  int rentalDays = 1;
  double totalCost = 0;

  // Fungsi untuk memilih tanggal menggunakan DatePicker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _calculateRentalDaysAndCost();
      });
    }
  }

  // Fungsi untuk menghitung durasi sewa dan total harga
  void _calculateRentalDaysAndCost() {
    if (_startDate != null && _endDate != null) {
      rentalDays = _endDate!.difference(_startDate!).inDays + 1; // +1 karena termasuk hari mulai
      totalCost = rentalDays * widget.car.pricePerDay;
    }
  }

  // Fungsi untuk melakukan booking mobil
  Future<void> _bookCar(BuildContext context) async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select start and end dates for booking.")),
      );
      return;
    }

    // Tampilkan dialog untuk konfirmasi booking
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Booking ${widget.car.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Car: ${widget.car.name}", style: TextStyle(fontSize: 18)),
              Text("Price per Day: \$${widget.car.pricePerDay}", style: TextStyle(fontSize: 18)),
              Text("Start Date: ${_startDate?.toLocal().toString().split(' ')[0]}", style: TextStyle(fontSize: 18)),
              Text("End Date: ${_endDate?.toLocal().toString().split(' ')[0]}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text("Total Days: $rentalDays", style: TextStyle(fontSize: 18)),
              Text("Total Price: \$${totalCost.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Menutup dialog jika batal
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Ambil user data dari SharedPreferences dan kirim data ke backend
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? userData = prefs.getString('userData');
                if (userData != null) {
                  Map<String, dynamic> user = jsonDecode(userData);
                  String userId = user['id'];

                  // Kirim data booking ke backend
                  final response = await http.post(
                    Uri.parse('${ApiConfig.baseUrl}/bookings'), // Ganti dengan URL API Anda
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      'userId': userId,
                      'carId': widget.car.id,
                      'startDate': _startDate!.toIso8601String(),
                      'endDate': _endDate!.toIso8601String(),
                      'totalPrice': totalCost,
                    }),
                  );

                  if (response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Booking Successful! Total: \$${totalCost.toStringAsFixed(2)}"))
                    );
                    Navigator.pop(context); // Menutup dialog booking
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to book car"))
                    );
                  }
                }
              },
              child: Text("Book Now"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car.name),
      ),
      body: Center(
        child: Column(
          children: [
            Image.network(widget.car.image ?? 'https://via.placeholder.com/400', width: 200, height: 150, fit: BoxFit.cover),
            SizedBox(height: 20),
            Text("Brand: ${widget.car.brand}", style: TextStyle(fontSize: 20)),
            Text("Year: ${widget.car.modelYear}", style: TextStyle(fontSize: 20)),
            Text("Price per Day: \Rp ${widget.car.pricePerDay}", style: TextStyle(fontSize: 20)),
            Text("Status: ${widget.car.status}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text("Description: ${widget.car.description}", style: TextStyle(fontSize: 16)),

            // Pilih tanggal mulai
            ElevatedButton(
              onPressed: () => _selectDate(context, true),
              child: Text(_startDate == null ? "Select Start Date" : "Start Date: ${_startDate?.toLocal().toString().split(' ')[0]}"),
            ),
            SizedBox(height: 10),

            // Pilih tanggal berakhir
            ElevatedButton(
              onPressed: () => _selectDate(context, false),
              child: Text(_endDate == null ? "Select End Date" : "End Date: ${_endDate?.toLocal().toString().split(' ')[0]}"),
            ),
            SizedBox(height: 20),

            // Tombol Booking
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => _bookCar(context),
                child: Text("Book Now"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
