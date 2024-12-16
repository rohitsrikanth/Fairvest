import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenUrlPage extends StatelessWidget {
  final Uri url = Uri.parse("http://www.google.com");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Open URL Page"),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          ElevatedButton(
            onPressed: () async {
              if (await canLaunchUrl(url)) {
                launchUrl(url, mode: LaunchMode.inAppWebView);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Could not launch URL")),
                );
              }
            },
            child: Text("Open Google"),
          ),
        ],
      ),
    );
  }
}
