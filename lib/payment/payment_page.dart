import 'package:flutter/material.dart';
import 'payment.dart';  // Model Payment yang telah kita buat

class PaymentPage extends StatelessWidget {
  final Payment payment;

  PaymentPage({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment ID: ${payment.id}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("Booking ID: ${payment.bookingId}"),
            Text("User ID: ${payment.userId}"),
            Text("Amount: \$${payment.amount}"),
            Text("Payment Method: ${payment.paymentMethod}"),
            Text("Status: ${payment.status}"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulasi proses pembayaran
                _processPayment(context);
              },
              child: Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mensimulasikan proses pembayaran
  void _processPayment(BuildContext context) {
    // Proses pembayaran bisa dilakukan di sini.
    // Misalnya, kita ubah status pembayaran setelah pembayaran berhasil.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful!")),
    );
  }
}
