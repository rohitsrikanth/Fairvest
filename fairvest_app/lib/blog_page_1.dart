import 'package:fairvest_app/blog_page_2.dart';
import 'package:flutter/material.dart';

void main() => runApp(BlogApp());

class BlogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlogPage(),
    );
  }
}

class BlogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Add navigation logic
          },
        ),
        title: Row(
          children: [
            const Icon(Icons.web, size: 40, color: Colors.black),
            const SizedBox(width: 10),
            const Text(
              "BLOG",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search in here",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),

          // Featured articles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlogDetailPage()));

                  },
                  child: Expanded(
                    child: _buildFeatureCard(
                      "Vidokezo vya masoko ya mazao ya mahindi",
                      "assets/corn_field.jpg", // Replace with your image
                      "By: Mason Eduard",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    // Navigate to the second blog details
                  },
                  child: Expanded(
                    child: _buildFeatureCard(
                      "Usafirishaji wa mboga unavyofanywa",
                      "assets/green_pepper.jpg", // Replace with your image
                      "By: Ayumi White",
                    ),
                  ),
                ),
              ],
            )
          ),

              // List of blog posts
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildBlogListItem(
                  "Sheria ina uhusiano gani na kilimo?",
                  "assets/banana.jpg", // Replace with your image
                  "Jan 4, 2022",
                  "3344 views",
                ),
                _buildBlogListItem(
                  "Kwanini wakulima wabunifu ndio wanahitajika",
                  "assets/mango.jpg", // Replace with your image
                  "Jan 1, 2022",
                  "9823 views",
                ),
                _buildBlogListItem(
                  "Mkulima kijana aliyekuza pesa kwa miche ya miti",
                  "assets/young_farmer.jpg", // Replace with your image
                  "Jan 4, 2022",
                  "3344 views",
                ),
                _buildBlogListItem(
                  "Kuingia katika ujuzi wa biashara ya maziwa",
                  "assets/cow.jpg", // Replace with your image
                  "Jan 1, 2022",
                  "9823 views",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String imagePath, String author) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          author,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBlogListItem(String title, String imagePath, String date, String views) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$date • $views",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
