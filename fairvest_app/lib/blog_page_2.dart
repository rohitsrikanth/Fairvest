import 'package:flutter/material.dart';

void main() => runApp(BlogApp());

class BlogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlogDetailPage(),
    );
  }
}

class BlogDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Add navigation logic here
          },
        ),
        title: Row(
          children: [
            const Icon(Icons.web, size: 36, color: Colors.white),
            const SizedBox(width: 10),
            const Text(
              "BLOG",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search in here",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Blog Post Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/corn_field.jpg", // Replace with your image asset
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),

              // Post Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Jan 1, 2021 • 3344 views",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(Icons.bookmark_border, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),

              // Post Title
              const Text(
                "Vidokezo vya Masoko ya mazao ya Mahindi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Author
              Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: AssetImage("assets/author.jpg"), // Replace with your image
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      text: "By: ",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Mason Eduard",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Blog Content
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                    "Maecenas id sit eu tellus sed cursus eleifend id porta. "
                    "Lorem adipiscing mus vestibulum consequat porta eu ultrices feugiat. "
                    "Et, faucibus ut amet turpis. "
                    "Facilisis faucibus semper cras purus.\n\n"
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                    "Maecenas id sit eu tellus sed cursus eleifend id porta.\n\n"
                    "Fermentum et eget libero lectus. Amet, tellus aliquam, dignissim enim "
                    "placerat purus nunc, ac ipsum. Ac pretium.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
