import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import '../../0 theme/theme_provider.dart';



class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  TextEditingController _promptController = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String _selectedDate = '';
  final String huggingFaceAPIKey = '';

  Future<void> _summarizeData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final inputText = _promptController.text.trim();
    if (inputText.isEmpty) return;

    // Add user message to chat
    setState(() {
      _messages.add({"text": inputText, "sender": "User"});
      _isLoading = true;
      _promptController.clear();
    });

    String fullPrompt = '';
    String modelUrl = '';

    if (_selectedDate.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('recognized_texts')
          .where('userId', isEqualTo: user.uid)
          .get();

      final filtered = snapshot.docs.where((doc) {
        final ts = (doc['timestamp'] as Timestamp).toDate();
        final formatted = DateFormat('dd MMMM yyyy').format(ts);
        return formatted == _selectedDate;
      }).toList();

      if (filtered.isEmpty) {
        setState(() {
          _messages.add({"text": "No data found for $_selectedDate", "sender": "AI"});
          _isLoading = false;
        });
        return;
      }

      final combinedText = filtered.map((e) => e['text']).join('\n');
      fullPrompt = "$inputText\n\n$combinedText";
      modelUrl = 'https://api-inference.huggingface.co/models/Falconsai/text_summarization';
    } else {
      fullPrompt = inputText;
      modelUrl = 'https://api-inference.huggingface.co/models/google/flan-t5-large';
    }

    final response = await http.post(
      Uri.parse(modelUrl),
      headers: {
        'Authorization': 'Bearer $huggingFaceAPIKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': fullPrompt}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final reply = decoded[0]['generated_text'] ??
          decoded[0]['summary_text'] ??
          'AI responded but no readable text found.';

      setState(() {
        final formattedReply = _selectedDate.isNotEmpty
            ? "Summary of $_selectedDate:\n$reply"
            : reply;

        _messages.add({"text": formattedReply, "sender": "AI"});
      });
    } else {
      setState(() {
        _messages.add({
          "text": "API Error: ${response.statusCode}\n${response.body}",
          "sender": "AI"
        });
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _pickDate(BuildContext context) async {

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SizedBox(width: 10),
          ClipOval(
            child: Transform.scale(
              scale: 1.2,
              child: Image.asset(
                'assets/alexa.gif',
                width: 20,
                height: 20,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              "Typing...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.transparent,

      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? Center(
              child: Text(
                "What can I help with?",
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              reverse: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final message = _messages[index];
                final isUser = message["sender"] == "User";
                return _buildMessageBubble(message["text"]!, isUser);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask Anything ...",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _summarizeData(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_promptController.text.isNotEmpty) {
                      _summarizeData();
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (_selectedDate.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.link, color: Colors.white70, size: 18),
                            SizedBox(width: 4),
                            Text(
                              _selectedDate,
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = '';
                                });
                              },
                              child: Icon(Icons.close, color: Colors.white70, size: 18),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _pickDate(context),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}