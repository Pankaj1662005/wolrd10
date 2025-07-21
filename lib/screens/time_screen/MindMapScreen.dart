// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'dart:async';
// //
// // class SambaNovaChatScreen extends StatefulWidget {
// //   @override
// //   _SambaNovaChatScreenState createState() => _SambaNovaChatScreenState();
// // }
// //
// // class _SambaNovaChatScreenState extends State<SambaNovaChatScreen> with SingleTickerProviderStateMixin {
// //   TextEditingController _controller = TextEditingController();
// //   List<Map<String, dynamic>> _messages = [];
// //   bool _isTyping = false;
// //   String? _userId;
// //   String chatId = "recognized_texts"; // your collection name
// //
// //   final String apiUrl = "https://api.sambanova.ai/v1/chat/completions";
// //   final String apiKey = "5d772753-1ac2-4531-a712-9d233de18b87";
// //
// //   late AnimationController _typingAnimationController;
// //   late Animation<double> _fadeAnimation;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _typingAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 1))..repeat(reverse: true);
// //     _fadeAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(_typingAnimationController);
// //     _initUserAndLoadMessages();
// //   }
// //
// //   Future<void> _initUserAndLoadMessages() async {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user != null) {
// //       _userId = user.uid;
// //       await _loadPreviousMessages();
// //     }
// //   }
// //
// //   Future<void> _loadPreviousMessages() async {
// //     final snapshot = await FirebaseFirestore.instance
// //         .collection(chatId)
// //         .where("userId", isEqualTo: _userId)
// //         .orderBy("timestamp", descending: false)
// //         .get();
// //
// //     final loadedMessages = snapshot.docs.map((doc) => {
// //       "text": doc["text"],
// //       "sender": doc["sender"] ?? "User", // fallback if not present
// //       "timestamp": doc["timestamp"]
// //     }).toList();
// //
// //     setState(() {
// //       _messages = loadedMessages;
// //     });
// //   }
// //
// //   Future<void> sendMessage(String userInput) async {
// //     if (_userId == null || userInput.trim().isEmpty) return;
// //
// //     final timestamp = Timestamp.now();
// //
// //     final userMessage = {
// //       "text": userInput,
// //       "sender": "User",
// //       "userId": _userId,
// //       "timestamp": timestamp
// //     };
// //
// //     setState(() {
// //       _messages.add(userMessage);
// //       _isTyping = true;
// //     });
// //
// //     await FirebaseFirestore.instance.collection(chatId).add(userMessage);
// //
// //     // SambaNova request
// //     final headers = {
// //       "Content-Type": "application/json",
// //       "Authorization": "Bearer $apiKey",
// //     };
// //
// //     final body = jsonEncode({
// //       "model": "DeepSeek-R1",
// //       "messages": [
// //         {"role": "system", "content": "You are a helpful assistant"},
// //         {"role": "user", "content": userInput}
// //       ],
// //       "temperature": 0.1,
// //       "top_p": 0.1
// //     });
// //
// //     try {
// //       final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
// //
// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         final reply = data["choices"][0]["message"]["content"];
// //
// //         final aiMessage = {
// //           "text": reply,
// //           "sender": "AI",
// //           "userId": _userId,
// //           "timestamp": Timestamp.now()
// //         };
// //
// //         setState(() {
// //           _messages.add(aiMessage);
// //         });
// //
// //         await FirebaseFirestore.instance.collection(chatId).add(aiMessage);
// //       } else {
// //         _addErrorMessage("API Error: ${response.statusCode}");
// //       }
// //     } catch (e) {
// //       _addErrorMessage("Network error: $e");
// //     } finally {
// //       setState(() {
// //         _isTyping = false;
// //       });
// //     }
// //   }
// //
// //   void _addErrorMessage(String message) {
// //     final errorMsg = {
// //       "text": message,
// //       "sender": "AI",
// //       "userId": _userId,
// //       "timestamp": Timestamp.now()
// //     };
// //     setState(() {
// //       _messages.add(errorMsg);
// //     });
// //   }
// //
// //   Widget _buildTypingIndicator() {
// //     return Row(
// //       children: [
// //         SizedBox(width: 10),
// //         ClipOval(
// //           child: Image.asset('assets/alexa.gif', width: 20, height: 20, fit: BoxFit.cover),
// //         ),
// //         FadeTransition(
// //           opacity: _fadeAnimation,
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 10),
// //             child: Text("Typing...", style: TextStyle(color: Colors.white)),
// //           ),
// //         )
// //       ],
// //     );
// //   }
// //
// //   Widget _buildMessageBubble(String text, bool isUser) {
// //     return Align(
// //       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
// //       child: Container(
// //         padding: EdgeInsets.all(12),
// //         margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
// //         decoration: BoxDecoration(
// //           color: isUser ? Colors.blue : Colors.grey[800],
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         child: Text(text, style: TextStyle(color: Colors.white)),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _typingAnimationController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final allMessages = [..._messages];
// //     if (_isTyping) {
// //       allMessages.add({"text": "Typing...", "sender": "AI"});
// //     }
// //
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: ListView.builder(
// //               reverse: true,
// //               itemCount: allMessages.length,
// //               itemBuilder: (context, index) {
// //                 final reversedIndex = allMessages.length - 1 - index;
// //                 final message = allMessages[reversedIndex];
// //                 if (message["text"] == "Typing..." && message["sender"] == "AI") {
// //                   return _buildTypingIndicator();
// //                 }
// //                 return _buildMessageBubble(message["text"], message["sender"] == "User");
// //               },
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(10.0),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: TextField(
// //                     controller: _controller,
// //                     style: TextStyle(color: Colors.white),
// //                     decoration: InputDecoration(
// //                       hintText: "Type your message...",
// //                       hintStyle: TextStyle(color: Colors.white54),
// //                       filled: true,
// //                       fillColor: Colors.grey[900],
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(20),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(width: 8),
// //                 IconButton(
// //                   icon: Icon(Icons.send, color: Colors.blue),
// //                   onPressed: () {
// //                     final text = _controller.text.trim();
// //                     if (text.isNotEmpty) {
// //                       sendMessage(text);
// //                       _controller.clear();
// //                     }
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:async';
//
// class SambaNovaChatScreen extends StatefulWidget {
//   @override
//   _SambaNovaChatScreenState createState() => _SambaNovaChatScreenState();
// }
//
// class _SambaNovaChatScreenState extends State<SambaNovaChatScreen> with SingleTickerProviderStateMixin {
//   TextEditingController _controller = TextEditingController();
//   List<Map<String, dynamic>> _messages = [];
//   bool _isTyping = false;
//   String? _userId;
//   String chatId = "recognized_texts";
//
//   final String apiUrl = "https://api-inference.huggingface.co/models/gpt2";
//   final String apiKey = "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";
//
//   late AnimationController _typingAnimationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _typingAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 1))..repeat(reverse: true);
//     _fadeAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(_typingAnimationController);
//     _initUserAndLoadMessages();
//   }
//
//   Future<void> _initUserAndLoadMessages() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _userId = user.uid;
//       await _loadPreviousMessages();
//     }
//   }
//
//   Future<void> _loadPreviousMessages() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection(chatId)
//         .where("userId", isEqualTo: _userId)
//         .orderBy("timestamp", descending: false)
//         .get();
//
//     final loadedMessages = snapshot.docs.map((doc) => {
//       "text": doc["text"],
//       "sender": doc["sender"] ?? "User",
//       "timestamp": doc["timestamp"]
//     }).toList();
//
//     setState(() {
//       _messages = loadedMessages;
//     });
//   }
//
//   Future<void> sendMessage(String userInput) async {
//     if (_userId == null || userInput.trim().isEmpty) return;
//
//     final timestamp = Timestamp.now();
//
//     final userMessage = {
//       "text": userInput,
//       "sender": "User",
//       "userId": _userId,
//       "timestamp": timestamp
//     };
//
//     setState(() {
//       _messages.add(userMessage);
//       _isTyping = true;
//     });
//
//     await FirebaseFirestore.instance.collection(chatId).add(userMessage);
//
//     final headers = {
//       "Content-Type": "application/json",
//       "Authorization": "Bearer $apiKey",
//     };
//
//     // ✅ Just pass the user's message
//     final body = jsonEncode({
//       "inputs": userInput,
//     });
//
//     try {
//       final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         // ✅ gpt2 returns a list of {generated_text: "..."}
//         final reply = data[0]["generated_text"];
//
//         final aiMessage = {
//           "text": reply.trim(),
//           "sender": "AI",
//           "userId": _userId,
//           "timestamp": Timestamp.now()
//         };
//
//         setState(() {
//           _messages.add(aiMessage);
//         });
//
//         await FirebaseFirestore.instance.collection(chatId).add(aiMessage);
//       } else {
//         _addErrorMessage("API Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       _addErrorMessage("Network error: $e");
//     } finally {
//       setState(() {
//         _isTyping = false;
//       });
//     }
//   }
//
//
//
//   void _addErrorMessage(String message) {
//     final errorMsg = {
//       "text": message,
//       "sender": "AI",
//       "userId": _userId,
//       "timestamp": Timestamp.now()
//     };
//     setState(() {
//       _messages.add(errorMsg);
//     });
//   }
//
//   Widget _buildTypingIndicator() {
//     return Row(
//       children: [
//         SizedBox(width: 10),
//         ClipOval(
//           child: Image.asset('assets/alexa.gif', width: 20, height: 20, fit: BoxFit.cover),
//         ),
//         FadeTransition(
//           opacity: _fadeAnimation,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Text("Typing...", style: TextStyle(color: Colors.white)),
//           ),
//         )
//       ],
//     );
//   }
//
//   Widget _buildMessageBubble(String text, bool isUser) {
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: EdgeInsets.all(12),
//         margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
//         decoration: BoxDecoration(
//           color: isUser ? Colors.blue : Colors.grey[800],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(text, style: TextStyle(color: Colors.white)),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _typingAnimationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final allMessages = [..._messages];
//     if (_isTyping) {
//       allMessages.add({"text": "Typing...", "sender": "AI"});
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               itemCount: allMessages.length,
//               itemBuilder: (context, index) {
//                 final reversedIndex = allMessages.length - 1 - index;
//                 final message = allMessages[reversedIndex];
//                 if (message["text"] == "Typing..." && message["sender"] == "AI") {
//                   return _buildTypingIndicator();
//                 }
//                 return _buildMessageBubble(message["text"], message["sender"] == "User");
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     style: TextStyle(color: Colors.white),
//                     decoration: InputDecoration(
//                       hintText: "Type your message...",
//                       hintStyle: TextStyle(color: Colors.white54),
//                       filled: true,
//                       fillColor: Colors.grey[900],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 IconButton(
//                   icon: Icon(Icons.send, color: Colors.blue),
//                   onPressed: () {
//                     final text = _controller.text.trim();
//                     if (text.isNotEmpty) {
//                       sendMessage(text);
//                       _controller.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



//--------------------------------------------------------------------


//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
//
// class MindmapScreen extends StatefulWidget {
//   @override
//   _MindmapScreenState createState() => _MindmapScreenState();
// }
//
// class _MindmapScreenState extends State<MindmapScreen> {
//   String _summary = "";
//   bool _loading = false;
//   final _dateController = TextEditingController();
//   final String hfApiKey = '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'; // 🔐 Replace with your key
//   final String hfModel = 'Falconsai/text_summarization'; // Better lightweight model
//
//   Future<void> _summarizeDataForDate(String selectedDate) async {
//     setState(() {
//       _loading = true;
//       _summary = "";
//     });
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     final DateTime parsedDate = DateFormat('dd MMMM yyyy').parse(selectedDate);
//     final DateTime startOfDay = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
//     final DateTime endOfDay = startOfDay.add(Duration(days: 1));
//
//     final snapshot = await FirebaseFirestore.instance
//         .collection('recognized_texts')
//         .where('userId', isEqualTo: user.uid)
//         .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//         .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
//         .orderBy('timestamp')
//         .get();
//
//     if (snapshot.docs.isEmpty) {
//       setState(() {
//         _loading = false;
//         _summary = "No data found for $selectedDate.";
//       });
//       return;
//     }
//
//     String inputText = snapshot.docs
//         .map((doc) => doc['text'].toString())
//         .join(". ");
//
//     String prompt = "Summarize the following notes from $selectedDate:\n$inputText";
//
//     try {
//       final response = await http.post(
//         Uri.parse('https://api-inference.huggingface.co/models/$hfModel'),
//         headers: {
//           'Authorization': 'Bearer $hfApiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'inputs': prompt}),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _summary = data[0]["summary_text"] ?? "No summary available.";
//         });
//       } else {
//         setState(() {
//           _summary = "Failed with status ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _summary = "Error: $e";
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _dateController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Mind Map (Summarizer)')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _dateController,
//               readOnly: true,
//               onTap: () async {
//                 DateTime? picked = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2023),
//                   lastDate: DateTime(2030),
//                 );
//                 if (picked != null) {
//                   _dateController.text = DateFormat('dd MMMM yyyy').format(picked);
//                 }
//               },
//               decoration: InputDecoration(
//                 labelText: "Select Date",
//                 suffixIcon: Icon(Icons.calendar_today),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () {
//                 if (_dateController.text.isNotEmpty) {
//                   _summarizeDataForDate(_dateController.text);
//                 }
//               },
//               icon: Icon(Icons.summarize),
//               label: Text("Summarize"),
//             ),
//             SizedBox(height: 24),
//             if (_loading) CircularProgressIndicator(),
//             if (!_loading)
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Text(
//                     _summary,
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Mindmapscreen extends StatefulWidget {
  const Mindmapscreen({super.key});

  @override
  State<Mindmapscreen> createState() => _MindmapscreenState();
}

class _MindmapscreenState extends State<Mindmapscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text("Comming Soon!",                style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,),
      ),
    );
  }
}
