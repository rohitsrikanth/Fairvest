import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Function to send message to backend and handle response
  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    // Add the user's message to the chat UI
    setState(() {
      _messages.add(ChatMessage(
          message: message, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });

    try {
      // Sending message to the backend via HTTP POST
      var response = await http.post(
        Uri.parse(
            '$baseUrl/ask'), // Replace with your backend URL
        headers: {"Content-Type": "application/json"},
        body: json.encode({"question": message}),
      );

      // Handle the backend response
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String chatbotResponse = '';

        if (data != null && data is Map && data.containsKey('response')) {
          var responseList = data['response'];
          if (responseList is List && responseList.isNotEmpty) {
            chatbotResponse = responseList[0];
          } else {
            chatbotResponse = 'No response from bot.';
          }
        } else {
          chatbotResponse = 'Unexpected response format.';
        }

        // Add the bot's response to the chat UI
        setState(() {
          _messages.add(ChatMessage(
            message: chatbotResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      } else {
        // Handle error if the status code is not 200
        setState(() {
          _messages.add(ChatMessage(
            message: 'Error: Could not get response from bot.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle network or other errors
      setState(() {
        _messages.add(ChatMessage(
          message: 'Error: Could not connect to server.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Farmer's Chat Bot"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 36),
                              decoration: BoxDecoration(
                                color: Colors.brown[200],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'typing',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    child: LoadingDots(),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.account_circle,
                                    color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                ChatMessage message = _messages[index];
                bool isUserMessage = message.isUser;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: !isUserMessage ? 36 : 0,
                              right: isUserMessage ? 36 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: isUserMessage
                                  ? Colors.green
                                  : Colors.brown[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: isUserMessage
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.message,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message.timestamp != null
                                      ? "${message.timestamp!.hour.toString().padLeft(2, '0')}:${message.timestamp!.minute.toString().padLeft(2, '0')}"
                                      : '',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (!isUserMessage)
                            Positioned(
                              left: 0,
                              top: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.account_circle,
                                    color: Colors.green),
                              ),
                            ),
                          if (isUserMessage)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person, color: Colors.green),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                    onSubmitted: (message) {
                      _sendMessage(message);
                      _controller.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingDots extends StatefulWidget {
  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..addListener(() {
        if (_controller.value >= 1) {
          _controller.reset();
          setState(() {
            _currentIndex = (_currentIndex + 1) % 4;
          });
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '...'.substring(0, _currentIndex);
    return Text(
      dots,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime? timestamp;

  ChatMessage({required this.message, required this.isUser, this.timestamp});
}

void main() {
  runApp(MaterialApp(
    home: ChatBotPage(),
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
  ));
}
