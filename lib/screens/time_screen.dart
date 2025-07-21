import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:world7/screens/time_screen/MindMapScreen.dart';
import 'package:world7/screens/time_screen/SummaryScreen.dart';
import 'package:world7/screens/time_screen/TranscriptionScreen.dart';

class TimeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text('You need to sign in to view recognized texts.'),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: Column(
          children: [
            SizedBox(height: 50.0), // Space for aesthetics
            PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Container(
                child: TabBar(
                  labelColor: Colors.white,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'Transcription'),
                    Tab(text: 'AURA'),
                    Tab(text: 'Mind-map'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TranscriptionScreen(), // Shows recognized texts
                  SummaryScreen(),       // Placeholder for Summary
                  Mindmapscreen(),       // Placeholder for Mind-map

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
