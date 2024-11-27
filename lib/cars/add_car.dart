import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:permission_handler/permission_handler.dart';

class AddCarScreen extends StatefulWidget {
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelYearController = TextEditingController();
  final TextEditingController _pricePerDayController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Fungsi untuk memilih gambar dari galeri atau kamera
  Future<void> _pickImage(ImageSource source) async {
    var status = await Permission.camera.request();
    if (source == ImageSource.camera && status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission denied')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk menampilkan dialog pilihan gambar
  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk upload gambar ke Cloudinary (sama dengan kode Anda)
  Future<String?> _uploadImageToCloudinary(String imagePath) async {
    final timestamp = DateTime.now();
    final publicId = 'car_image_$timestamp';

    try {
      final cloudinary = Cloudinary.fromStringUrl(
        'cloudinary://439356878571156:nBhXkUhWlXLBxV8X7Kd8_YFbTSs@dd06nj0cz',
      );

      final result = await cloudinary.uploader().upload(
            File(imagePath),
            params: UploadParams(
              publicId: publicId,
              uniqueFilename: true,
              overwrite: true,
            ),
          );

      if (result?.data?.publicId != null) {
        return result?.data?.secureUrl;
      } else {
        print('Error uploading image: ${result?.error?.message}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Fungsi untuk menyimpan data mobil ke backend (sama dengan kode Anda)
  Future<void> _saveCar() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? imageUrl = await _uploadImageToCloudinary(_image!.path);

      String name = _nameController.text;
      String brand = _brandController.text;
      int? modelYear = int.tryParse(_modelYearController.text);
      double? pricePerDay = double.tryParse(_pricePerDayController.text);
      String description = _descriptionController.text;

      var response = await http.post(
        Uri.parse('http://192.168.4.110:5000/api/cars/'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'brand': brand,
          'modelYear': modelYear,
          'pricePerDay': pricePerDay,
          'description': description,
          'image': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        print('Car added successfully');
        Navigator.pop(context);
      } else {
        throw Exception('Failed to add car');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add car: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: _showImageSourceActionSheet,
                child: Text('Pick an Image'),
              ),
              SizedBox(height: 20),
              _image != null
                  ? Image.file(_image!,
                      width: double.infinity, height: 200, fit: BoxFit.cover)
                  : Text('No image selected'),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Car Name'),
              ),
              TextField(
                controller: _brandController,
                decoration: InputDecoration(labelText: 'Car Brand'),
              ),
              TextField(
                controller: _modelYearController,
                decoration: InputDecoration(labelText: 'Model Year'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _pricePerDayController,
                decoration: InputDecoration(labelText: 'Price per Day'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveCar,
                      child: Text('Save Car'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
