import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'booking.dart'; // Pastikan model Booking sudah sesuai
import '../APIconfig/api_conf.dart'; // File konfigurasi API Anda

class BookingListScreen extends StatefulWidget {
  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<Booking> bookings = [];
  bool isLoading = true; // Indikator loading

  @override
  void initState() {
    super.initState();
    _fetchUserBookings();
  }

  Future<void> _fetchUserBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please login to view your bookings")),
      );
      setState(() => isLoading = false);
      return;
    }

    Map<String, dynamic> user = jsonDecode(userData);
    String? userId = user['id'];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User ID not found. Please login again.")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bookings/$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          bookings = data.map((booking) => Booking.fromJson(booking)).toList();
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load bookings")),
        );
        setState(() => isLoading = false);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
      setState(() => isLoading = false);
    }
  }

  String formattedDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking List"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : bookings.isEmpty
              ? Center(child: Text("No bookings found"))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    Booking booking = bookings[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        title: Text("Car: ${booking.car ?? 'Unknown Car'}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("User: ${booking.user ?? 'Unknown User'}"),
                            Text("Start Date: ${formattedDate(booking.startDate)}"),
                            Text("End Date: ${formattedDate(booking.endDate)}"),
                            Text("Total Price: Rp ${booking.totalPrice.toString()}"),
                            Text("Status: ${booking.status}"),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          // Tambahkan aksi jika diperlukan
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
