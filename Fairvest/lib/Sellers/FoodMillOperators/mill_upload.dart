import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

void main() {
  runApp(MaterialApp(home: MillUploadPage()));
}

class MillUploadPage extends StatefulWidget {
  @override
  _MillUploadPageState createState() => _MillUploadPageState();
}

class _MillUploadPageState extends State<MillUploadPage> {
  final _formKey = GlobalKey<FormState>();
  String? _millName;
  String? _operatorName;
  String? _location;
  String? _pricing;
  List<File> _images = [];
  List<String> _services = [];
  TextEditingController _servicesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> _chooseImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      var uri = Uri.parse('http://localhost:5000/upload_mill'); // Replace with your Flask server URL
      var request = http.MultipartRequest('POST', uri);

      request.fields['mill_name'] = _millName!;
      request.fields['operator_name'] = _operatorName!;
      request.fields['location'] = _location!;
      request.fields['pricing'] = _pricing!;
      request.fields['services'] = _services.join(',');

      for (var image in _images) {
        var stream = http.ByteStream(DelegatingStream.typed(image.openRead()));
        var length = await image.length();
        var multipartFile = http.MultipartFile('images', stream, length,
            filename: path.basename(image.path));
        request.files.add(multipartFile);
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mill details uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload mill details.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Mill Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Mill Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the mill name';
                    }
                    return null;
                  },
                  onSaved: (value) => _millName = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Operator Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the operator name';
                    }
                    return null;
                  },
                  onSaved: (value) => _operatorName = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                  onSaved: (value) => _location = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Pricing'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the pricing';
                    }
                    return null;
                  },
                  onSaved: (value) => _pricing = value,
                ),
                TextField(
                  controller: _servicesController,
                  decoration: InputDecoration(
                    labelText: 'Services (comma separated)',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (_servicesController.text.isNotEmpty) {
                            _services.add(_servicesController.text);
                            _servicesController.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  children: _services
                      .map((service) => Chip(
                            label: Text(service),
                            onDeleted: () {
                              setState(() {
                                _services.remove(service);
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _chooseImages,
                  child: Text('Choose Images'),
                ),
                SizedBox(height: 10),
                _images.isNotEmpty
                    ? Wrap(
                        spacing: 8.0,
                        children: _images
                            .map((image) => Image.file(
                                  image,
                                  width: 100,
                                  height: 100,
                                ))
                            .toList(),
                      )
                    : Text('No images selected'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
