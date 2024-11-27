import 'dart:convert';
import 'package:carental/cars/add_car.dart';
import 'package:carental/cars/car_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'car.dart';

class CarListScreen extends StatefulWidget {
  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  List<Car> cars = [];

  // Fungsi untuk memeriksa apakah user adalah admin
  Future<bool> _isAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData'); // Ambil data user
    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      String? role = user['role']; // Ambil role dari data user
      return role == 'admin'; // Jika role adalah admin, return true
    }
    return false; // Jika tidak ada userData atau bukan admin, return false
  }

  // Fungsi untuk mengambil daftar mobil dari API
  Future<void> _fetchCars() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.4.110:5000/api/cars/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          cars = data.map((car) => Car.fromJson(car)).toList();
        });
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (e) {
      print('Error fetching cars: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to fetch cars')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCars(); // Ambil daftar mobil saat layar pertama kali dibuka
  }

  // Fungsi untuk melakukan booking mobil
  void _bookCar(Car car) {
    int rentalDays = 1; // Default durasi sewa 1 hari
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Booking ${car.name}"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menampilkan detail mobil
                Text("Car: ${car.name}", style: TextStyle(fontSize: 18)),
                Text("Price per Day: \$${car.pricePerDay}",
                    style: TextStyle(fontSize: 18)),
                Text("Description: ${car.description}",
                    style: TextStyle(fontSize: 16)),

                SizedBox(height: 20),

                // Input untuk durasi sewa (Lama Sewa)
                Text("Rental Days:"),
                Slider(
                  value: rentalDays.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '$rentalDays days',
                  onChanged: (double value) {
                    setState(() {
                      rentalDays = value.toInt();
                    });
                  },
                ),
                Text('$rentalDays days'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Menutup dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Proses booking dilakukan di sini
                double totalCost = rentalDays * car.pricePerDay;
                Navigator.pop(context); // Menutup dialog setelah booking
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Booked ${car.name} for $rentalDays days. Total: \$${totalCost}")));
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
      body: RefreshIndicator(
        // Tambahkan RefreshIndicator di sini
        onRefresh: _fetchCars, // Hubungkan dengan fungsi fetch
        child: ListView.builder(
          itemCount: cars.length,
          itemBuilder: (context, index) {
            Car car = cars[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: Image.network(
                      car.image ??
                          'https://via.placeholder.com/100', // Placeholder jika tidak ada gambar
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    title: Text(car.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Brand: ${car.brand}"),
                        Text("Year: ${car.modelYear}"),
                        Text("Price per Day: \Rp ${car.pricePerDay}"),
                        Text("Status: ${car.status}"),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // Navigasi ke halaman detail mobil
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarDetailPage(car: car),
                        ),
                      );
                    },
                  ),
                  // Tombol Booking
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: () => _bookCar(car),
                      child: Text("Book Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Warna tombol
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: _isAdmin(), // Memeriksa apakah pengguna admin
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(); // Jika masih loading, tidak tampilkan FAB
          } else if (snapshot.hasData && snapshot.data == true) {
            // Tampilkan FAB jika user adalah admin
            return FloatingActionButton(
              onPressed: () {
                // Aksi saat FAB ditekan
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCarScreen()),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            );
          } else {
            // Tidak tampilkan FAB jika user bukan admin
            return SizedBox();
          }
        },
      ),
    );
  }
}
