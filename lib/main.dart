import 'package:carental/login_screen.dart';
import 'package:carental/cars/add_car.dart';
import 'package:carental/register_screen.dart';
import 'package:carental/scanner/scanner.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cars/car_list_screen.dart';
import 'todolist/booking_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  bool isLoggedIn = await _checkLoginStatus(); // Cek status login
  runApp(MyApp(isLoggedIn));
}

Future<bool> _checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userData = prefs.getString('userData'); // Cek apakah userId ada
  return userData != null; // Jika ada userId, berarti sudah login
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp(this.isLoggedIn);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Rental App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/carlist': (context) => CarListScreen(),
        '/bookinglist': (context) => BookingListScreen(),
        '/register': (context) => RegisterScreen(),
        '/addcar': (context) => AddCarScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  // Fungsi logout
  Future<void> _logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData'); // Hapus data user dari SharedPreferences
    Navigator.pushReplacementNamed(context, '/login'); // Navigasi ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Jumlah tab
      child: Scaffold(
        appBar: AppBar(
          title: Text('Car Rental App'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _logoutUser(context), // Panggil fungsi logout
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Cars'),
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scanner'),
              Tab(icon: Icon(Icons.book), text: 'Bookings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CarListScreen(),       // Tab pertama: Daftar Mobil
            Scanner(),         // Tab kedua: Scanner (akan diganti nanti)
            BookingListScreen(),   // Tab ketiga: Daftar Booking
          ],
        ),
      ),
    );
  }
}
