import 'package:carental/APIconfig/api_conf.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Untuk mengubah data menjadi JSON

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // URL endpoint backend untuk register
  final String apiUrl =
      '${ApiConfig.baseUrl}/users/'; // Ganti dengan URL backend Anda

  // Fungsi untuk melakukan register
  Future<void> _registerUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String phoneNumber = _phoneNumberController.text;

      // Data yang akan dikirim ke backend
      Map<String, String> data = {
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
      };

      // Mengirim data ke backend dengan HTTP POST
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}'); // Debugging response body

        if (response.statusCode == 201) {
          // Jika pendaftaran berhasil
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Registration Successful!'),
          ));
          // Navigasi ke halaman login atau halaman utama
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // Jika terjadi kesalahan
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Registration failed. Please try again.'),
          ));
        }
      } catch (e) {
        // Menangani error jaringan atau lainnya
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An error occurred. Please try again.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Already have an Account?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
