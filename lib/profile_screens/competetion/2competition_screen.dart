import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '3 view profile.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  String? joinedClubId;
  bool isLive = true;

  Widget _onlineIndicator() => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Competition'),
      ),
      body: Column(
        children: [
          Divider(thickness: 1),
          if (isLive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Live Members in Competition:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('competition', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No users are currently in competition.",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                final liveUsers = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: liveUsers.length,
                  itemBuilder: (context, index) {
                    final userData = liveUsers[index];
                    final fullName = userData['name'] ?? 'No Name';
                    final email = userData['email'] ?? '';
                    final uid = userData['uid'];
                    final joinedAt = userData['competition_joined_at'] as Timestamp?;

                    // Optional: Don't show current user in the list
                    if (user?.uid == uid) {
                      return SizedBox.shrink();
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              child: Text(
                                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: _onlineIndicator(),
                            ),
                          ],
                        ),
                        title: Text(
                          fullName,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(email),
                            if (joinedAt != null)
                              Text(
                                'Joined: ${_formatTime(joinedAt.toDate())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResumeDetails(userId: uid),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}