import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumeDetails extends StatelessWidget {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ResumeDetails({super.key, required this.userId});

  Future<Map<String, dynamic>?> _getUserResumeDetails() async {
    try {
      final userSnap = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      return userSnap.exists ? userSnap.data() as Map<String, dynamic> : null;
    } catch (e) {
      debugPrint('Error fetching user resume details → $e');
      return null;
    }
  }

  Future<void> _launchExternal(BuildContext ctx, String raw) async {
    if (raw.trim().isEmpty) return;

    String url = _normalizeUrl(raw);
    final uri = Uri.tryParse(url);

    if (uri != null && await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Failed to open the link: $e')),
          );
        }
      }
    } else {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Couldn’t open the link')),
        );
      }
    }
  }

  String _normalizeUrl(String input) {
    final trimmed = input.trim();

    if (trimmed.startsWith(RegExp(r'https?://'))) return trimmed;

    if (trimmed.contains('linkedin')) {
      return 'https://$trimmed';
    }
    if (!trimmed.contains('.') && !trimmed.contains('/')) {
      if (trimmed.contains(RegExp(r'[A-Za-z0-9_]+'))) {
        return 'https://instagram.com/$trimmed';
      }
    }
    return 'https://$trimmed';
  }

  /* ------------------------------------------------------------
   * 🏗️ 3.  UI
   * ---------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Resume Details', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserResumeDetails(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (!snap.hasData || snap.data == null) {
            return const Center(child: Text('No resume details found.'));
          }

          final user = snap.data!;
          final resume = user['resume'] ?? {};

          final fullName    = user['name']          ?? 'N/A';
          final email       = user['email']             ?? 'N/A';
          final uid         = user['uid']             ?? 'N/A';
          final phoneNumber = resume['phoneNumber']     ?? 'N/A';
          final skills      = List<String>.from(resume['skills'] ?? []);
          final experience  = resume['experience']      ?? 'N/A';
          final address     = resume['address']         ?? 'N/A';
          final marks       = resume['marks']           ?? 'N/A';
          final collegeName = resume['collegeName']     ?? 'N/A';
          final linkedinId  = resume['linkedinId']      ?? '';
          final instaId     = resume['instagram']       ?? '';
          final tag         = resume['tag']                ?? '';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                /* -------------------------------------------------- PROFILE CARD */
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                    minRadius: 50,
                          child: Text(
                            fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Text(uid),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (linkedinId.trim().isNotEmpty)
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.linkedin, color: Color(0xFF0A66C2)),
                                onPressed: () => _launchExternal(context, linkedinId),
                                tooltip: 'LinkedIn',
                              ),
                            if (instaId.trim().isNotEmpty)
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFC13584)),
                                onPressed: () => _launchExternal(context, instaId),
                                tooltip: 'Instagram',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                /* -------------------------------------------------- DETAILS */
                const SizedBox(height: 20),
                _sectionTitle('Contact Information'),
                //_infoTile('Phone Number', phoneNumber),
                _infoTile('Address', address),

                const SizedBox(height: 20),
                _sectionTitle('Academic Details'),
                _infoTile('College Name', collegeName),
                _infoTile('CGPA', marks),

                const SizedBox(height: 20),
                _infoTile('Experience', experience),

                const SizedBox(height: 20),
                _sectionTitle('Skills'),
                skills.isNotEmpty
                    ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((s) => Chip(label: Text(s), backgroundColor: Colors.blue[100]))
                      .toList(),
                )
                    : const Text('No skills listed.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                _infoTile('Tag', tag),
              ],
            ),
          );
        },
      ),
    );
  }

  /* ------------------------------------------------------------
   * 🔤  Helpers for building tiles / titles
   * ---------------------------------------------------------- */
  Widget _sectionTitle(String txt) => Text(
    txt,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
  );

  Widget _infoTile(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    ),
  );
}
