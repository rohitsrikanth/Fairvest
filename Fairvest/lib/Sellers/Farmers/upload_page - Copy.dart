import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:http/http.dart' as http;
import 'package:fairvest1/constants.dart';

void main() => runApp(const UploadProductApp());

class UploadProductApp extends StatelessWidget {
  const UploadProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadProductPage(),
    );
  }
}

Future<void> uploadProduct(
    String description, String units, String date, String imagePath) async {
  final uri = Uri.parse('$baseUrl/upload-product'); // Backend API endpoint
  final request = http.MultipartRequest('POST', uri);

  // Add form fields
  request.fields['description'] = description;
  request.fields['units'] = units;
  request.fields['date'] = date;

  // Attach the image file
  request.files.add(await http.MultipartFile.fromPath('image', imagePath));

  final response = await request.send();
  final responseBody = await http.Response.fromStream(response);

  if (response.statusCode == 200) {
    print("Product uploaded successfully!");
  } else {
    print("Failed to upload product. Status code: ${response.statusCode}");
    print("Response: ${responseBody.body}");
  }
}

class UploadProductPage extends StatefulWidget {
  const UploadProductPage({super.key});

  @override
  _UploadProductPageState createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  DateTime? _selectedDate;
  final List<String> _categories = [
    'Fresh Vegetables',
    'Fruits and Berries',
    'Oil Seeds',
    'Oils',
    'Grains',
    'Pulses'
  ];
  String _selectedCategory = "";

  /// Function to pick an image
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!Foundation.kIsWeb) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        showFeedback("Image uploads are not supported on web.");
      }
    } else {
      showFeedback("No image selected.");
    }
  }

  /// Function to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Function to show feedback as a SnackBar
  void showFeedback(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Function to handle submission
  void _handleSubmit() async {
    final description = _descriptionController.text.trim();
    final units = _unitsController.text.trim();
    final date = _selectedDate;
    final image = _selectedImage;

    if (description.isEmpty || units.isEmpty || date == null || image == null) {
      showFeedback("Please fill all fields.");
      return;
    }

    try {
      // Format the date as YYYY-MM-DD
      final formattedDate = "${date.year}-${date.month}-${date.day}";

      // Call the uploadProduct function
      await uploadProduct(description, units, formattedDate, image.path);

      showFeedback("Product submitted successfully!");
    } catch (error) {
      print("Error uploading product: $error");
      showFeedback("Failed to submit product. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Upload Your Product",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildOptionCard(
                icon: Icons.scale,
                label: "Product Name",
                child: TextField(
                  controller: _unitsController,
                  keyboardType: TextInputType.text, // Changed to text
                  decoration: InputDecoration(
                    hintText: "Enter product name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                icon: Icons.image,
                label: "Upload Image",
                child: Column(
                  children: [
                    if (_selectedImage != null)
                      Image.file(
                        _selectedImage!,
                        height: 100,
                      ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text("Select Image"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                icon: Icons.scale,
                label: "Enter number of units (in Kg):",
                child: TextField(
                  controller: _unitsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter quantity in Kg",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                icon: Icons.description,
                label: "Enter product price",
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter product price per unit",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                icon: Icons.category,
                label: "Select Category",
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items:
                      _categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                icon: Icons.description,
                label: "Enter product description:",
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Describe your product (max 200 words)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                icon: Icons.calendar_today,
                label: "Select Date",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                          : "No date selected",
                      style: const TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickDate(context),
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      {required IconData icon, required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 30, color: Colors.black),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
