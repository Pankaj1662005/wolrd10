import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class SpeechRecognitionScreen extends StatefulWidget {
  @override
  _SpeechRecognitionScreenState createState() =>
      _SpeechRecognitionScreenState();
}

class _SpeechRecognitionScreenState extends State<SpeechRecognitionScreen> {
  String recognizedText = '';
  bool isLoading = false;
  late Directory audioDirectory;
  late Timer folderCheckTimer;

  @override
  void initState() {
    super.initState();
    requestPermissions(); // Request storage permission
    _initializeAudioDirectory();
    _startFolderWatcher();
  }

  // Request permissions for storage access
  Future<void> requestPermissions() async {
    // Check if the app has permission to access storage
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
    // If the app is running on Android 11 (API level 30) or above, request MANAGE_EXTERNAL_STORAGE permission
    if (Platform.isAndroid && await Permission.manageExternalStorage.isDenied) {
      PermissionStatus manageStoragePermission = await Permission.manageExternalStorage.request();
      if (manageStoragePermission.isGranted) {
        print("All files access granted");
      } else {
        print("All files access denied");
      }
    }
  }

  // Initialize the audio directory path (accessing the "Documents" folder)
  Future<void> _initializeAudioDirectory() async {
    final directory = Directory('/storage/emulated/0/Documents'); // Access the Documents directory
    audioDirectory = directory;

    if (!await audioDirectory.exists()) {
      print("Directory does not exist.");
    } else {
      print("Directory exists: ${audioDirectory.path}");
    }
  }

  // Start a periodic timer to check the folder for new audio files
  void _startFolderWatcher() {
    folderCheckTimer = Timer.periodic(Duration(seconds: 50), (timer) {
      _checkForNewFiles();
    });
  }

  // Check for new .wav files in the folder and process them
  Future<void> _checkForNewFiles() async {
    try {
      List<FileSystemEntity> files = audioDirectory.listSync();

      if (files.isEmpty) {
        print('No files found in directory.');
      } else {
        print('Files found in directory:');
        for (var fileEntity in files) {
          if (fileEntity is File && fileEntity.path.endsWith('.wav')) {
            print('Found file: ${fileEntity.path}');
            bool isProcessed = await sendAudioFile(fileEntity);

            // Delete the file only after successful processing
            if (isProcessed) {
              await fileEntity.delete();
              print('File deleted: ${fileEntity.path}');
            }
          }
        }
      }
    } catch (e) {
      print('Error while checking for files: $e');
    }
  }

  // Function to send the audio file to the server
  Future<bool> sendAudioFile(File audioFile) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      var uri = Uri.parse('');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        setState(() {
          recognizedText = jsonResponse['recognized_text'];
          isLoading = false; // Hide loading indicator
        });

        // Get the current user ID from Firebase Auth
        String userId = FirebaseAuth.instance.currentUser!.uid;

        // Store recognized text to Firestore
        await FirebaseFirestore.instance.collection('recognized_texts').add({
          'userId': userId,  // Add userId to the document
          'text': jsonResponse['recognized_text'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        return true; // Indicate that the file was successfully processed
      } else {
        setState(() {
          recognizedText = 'file has music in it or voice is not clear Error: ${response.statusCode}';
          isLoading = false; // Hide loading indicator
        });
        return false; // Indicate that there was an error during processing
      }
    } catch (e) {
      setState(() {
        recognizedText = 'Error: $e';
        isLoading = false; // Hide loading indicator
      });
      return false; // Indicate that there was an error during processing
    }
  }

  // Function to handle the logout confirmation dialog
  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // Log out the user
                Navigator.of(context).pop(); // Close the dialog
                // Optionally, you can navigate to the login screen if needed
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    folderCheckTimer.cancel(); // Stop the timer when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        title: Text('DeepLogix Home'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _showLogoutDialog, // Show the logout dialog when pressed
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? CircularProgressIndicator()
                : Text('Recognized Text: $recognizedText'),
          ],
        ),
      ),
    );
  }
}
