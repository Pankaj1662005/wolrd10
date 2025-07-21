import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserFullProfile extends StatefulWidget {
  @override
  _UserFullProfileState createState() => _UserFullProfileState();
}

class _UserFullProfileState extends State<UserFullProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> _tags = [
    'Android Development',
    'Web Development',
    'ML or Data Science',
    'Documentation or Content Writing or Research',
    'Other'
  ];

  String? _selectedTag;


  bool _loading = true;

  // Controllers
  late TextEditingController _phoneController;
  late TextEditingController _experienceController;
  late TextEditingController _addressController;
  late TextEditingController _skillsController;
  late TextEditingController _marksController;
  late TextEditingController _collegeNameController;
  late TextEditingController _linkedinController;
  late TextEditingController _instagramController;

  // Basic Information
  String fullName = "";
  String email = "";
  String profileImageUrl = "";
  int maxStreak = 0;
  int streak=0;
  String starType = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchUserProfile();
  }

  void _initializeControllers() {
    _phoneController = TextEditingController();
    _experienceController = TextEditingController();
    _addressController = TextEditingController();
    _skillsController = TextEditingController();
    _marksController = TextEditingController();
    _collegeNameController = TextEditingController();
    _linkedinController = TextEditingController();      // New
    _instagramController = TextEditingController();
  }

  Future<void> _fetchUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          fullName = data['name'] ?? '';
          email = data['email'] ?? '';
          profileImageUrl = data['profileImageUrl'] ?? '';
          maxStreak = data['maxStreak'] ?? 0;
          streak = data['streak'] ?? 0;
          starType = data['starType'] ?? '';

          final resume = data['resume'] ?? {};

          _phoneController.text = resume['phoneNumber'] ?? '';
          _experienceController.text = resume['experience'] ?? '';
          _addressController.text = resume['address'] ?? '';
          _marksController.text = resume['marks'] ?? '';
          _collegeNameController.text = resume['collegeName'] ?? '';
          _linkedinController.text = resume['linkedinId'] ?? '';
          _instagramController.text = resume['instagram'] ?? '';
          _selectedTag = resume['tag'] ?? null;

          final skillsList = resume['skills'] ?? [];
          if (skillsList is List) {
            _skillsController.text = skillsList.join(', ');
          }
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    if (_linkedinController.text.isEmpty || _marksController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('LinkedIn ID and Marks are required.')),
      );
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'resume': {
          'phoneNumber': _phoneController.text.trim(),
          'experience': _experienceController.text.trim(),
          'address': _addressController.text.trim(),
          'marks': _marksController.text.trim(),
          'collegeName': _collegeNameController.text.trim(),
          'linkedinId': _linkedinController.text.trim(),
          'instagram': _instagramController.text.trim(),
          'skills': _skillsController.text.split(',').map((e) => e.trim()).toList(),
          'tag': _selectedTag ?? '',
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      print('Error updating profile: $e');
    }
  }


  @override
  void dispose() {
    _phoneController.dispose();
    _experienceController.dispose();
    _addressController.dispose();
    _skillsController.dispose();
    _marksController.dispose();
    _collegeNameController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture section (optional)
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://images.ctfassets.net/ihx0a8chifpc/gPyHKDGI0md4NkRDjs4k8/36be1e73008a0181c1980f727f29d002/avatar-placeholder-generator-500x500.jpg'),
            ),
            SizedBox(height: 16),

            Text(
              "Basic Information",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text('Full Name: $fullName',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
            SizedBox(height: 4),
            Text('Email: $email'),
            Text('🔥Max Streak: $maxStreak            current Streak: $streak'),
            SizedBox(height: 4),
            if (maxStreak>=150)
              Row(
                children: [
                  Text('$starType'),
                  SizedBox(width: 8),
                  Icon(Icons.emoji_events, color: Colors.amber),
                ],
              ),


            Text(
              "Resume Information",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            _buildTextField(_linkedinController, 'LinkedIn ID *'), // Required
            _buildTextField(_instagramController, 'Instagram Profile (Optional)'),
            _buildTextField(_phoneController, 'Phone Number'),
            _buildTextField(_experienceController, 'Experience'),
            _buildTextField(_addressController, 'Address'),
            _buildTextField(_skillsController, 'Skills (comma-separated)'),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Your Interest Tag',
                border: OutlineInputBorder(),
              ),
              value: _selectedTag,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTag = newValue!;
                });
              },
              items: _tags.map((String tag) {
                return DropdownMenuItem<String>(
                  value: tag,
                  child: Text(tag),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            _buildTextField(_marksController, 'CGPA *'), // Required
            _buildTextField(_collegeNameController, 'College Name'),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
