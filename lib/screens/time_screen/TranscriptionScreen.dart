import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TranscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text('You need to sign in to view recognized texts.'),
      );
    }

    return _buildRecognizedTexts(user);
  }

  Widget _buildRecognizedTexts(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recognized_texts')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong! Please try again.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No recognized texts available.'));
        }

        final documents = snapshot.data!.docs;
        Map<String, List<QueryDocumentSnapshot>> groupedByDate = _groupByDate(documents);

        return _buildGroupedList(groupedByDate);
      },
    );
  }

  Map<String, List<QueryDocumentSnapshot>> _groupByDate(List<QueryDocumentSnapshot> documents) {
    Map<String, List<QueryDocumentSnapshot>> groupedByDate = {};

    for (var doc in documents) {
      final timestamp = (doc['timestamp'] as Timestamp).toDate();
      final dateKey = DateFormat('dd MMMM yyyy').format(timestamp);

      groupedByDate.putIfAbsent(dateKey, () => []).add(doc);
    }

    return groupedByDate;
  }

  Widget _buildGroupedList(Map<String, List<QueryDocumentSnapshot>> groupedByDate) {
    return ListView.builder(
      itemCount: groupedByDate.keys.length,
      itemBuilder: (context, index) {
        final dateKey = groupedByDate.keys.elementAt(index);
        final group = groupedByDate[dateKey]!;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.white70,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  dateKey,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 8),
              _buildTextItems(group),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextItems(List<QueryDocumentSnapshot> group) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: group.length,
      itemBuilder: (context, subIndex) {
        final data = group[subIndex];
        final recognizedText = data['text'];
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final formattedTimestamp = DateFormat('HH:mm').format(timestamp);

        return _buildTextItem(recognizedText, formattedTimestamp);
      },
    );
  }

  Widget _buildTextItem(String recognizedText, String formattedTimestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 60,
            color: Colors.grey.shade300,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedTimestamp,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  recognizedText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
