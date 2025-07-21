//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../profile_screens/competetion/1warning.dart';
// import '../profile_screens/competetion/2competition_screen.dart';
// import '../0 theme/theme_provider.dart';
//
// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
//     User? user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       return Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           title: Text('Profile'),
//           backgroundColor: Colors.black,
//         ),
//         body: Center(
//           child: Text(
//             'No user is signed in.\nPlease sign in to view your profile.',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 18, color: Colors.white),
//           ),
//         ),
//       );
//     }
//
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildLoadingScreen();
//         }
//         if (snapshot.hasError) {
//           return _buildErrorScreen();
//         }
//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return _buildNoDataScreen();
//         }
//
//         var userData = snapshot.data!;
//         String fullName = userData['full_name'] ?? 'No Name';
//         bool hasJoinedCompetition = userData['competition'] == true; // Check competition status
//
//         return Scaffold(
//           backgroundColor: isDarkMode ? Colors.black12.withOpacity(0.7) : Colors.black12.withOpacity(0.5),
//           appBar: AppBar(
//             title: Text(
//               'Profile',
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//             backgroundColor: Colors.transparent,
//             actions: [
//               Consumer<ThemeProvider>(
//                 builder: (context, themeProvider, child) {
//                   return Switch(
//                     value: themeProvider.isDarkMode,
//                     onChanged: (value) {
//                       themeProvider.toggleTheme();
//                     },
//                     activeColor: Colors.black12,
//                   );
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.settings, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ],
//           ),
//           body: _buildProfileContainer(user, fullName, context, hasJoinedCompetition),
//         );
//       },
//     );
//   }
//
//   Widget _buildLoadingScreen() {
//     return Scaffold(
//       backgroundColor: Colors.black12.withOpacity(0.7),
//       appBar: AppBar(
//         title: Text('Profile', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//       ),
//       body: Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorScreen() {
//     return Scaffold(
//       backgroundColor: Colors.black12.withOpacity(0.7),
//       appBar: AppBar(
//         title: Text('Profile', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//       ),
//       body: Center(
//         child: Text(
//           'Error fetching data',
//           style: TextStyle(color: Colors.redAccent, fontSize: 16),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNoDataScreen() {
//     return Scaffold(
//       backgroundColor: Colors.black12.withOpacity(0.7),
//       appBar: AppBar(
//         title: Text('Profile', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//       ),
//       body: Center(
//         child: Text(
//           'No profile data found',
//           style: TextStyle(color: Colors.orangeAccent, fontSize: 16),
//         ),
//       ),
//     );
//   }
//
//   // Method to handle competition navigation
//   void _navigateToCompetition(BuildContext context, bool hasJoined) {
//     if (hasJoined) {
//       // Go directly to competition screen
//       Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => CompetitionScreen())
//       );
//     } else {
//       // Show warning screen first
//       Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => WarningScreen())
//       );
//     }
//   }
//
//   Widget _buildProfileContainer(User user, String fullName, BuildContext context, bool hasJoinedCompetition) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: AssetImage('assets/profile1.gif'),
//                 ),
//                 SizedBox(width: 15),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         fullName,
//                         style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'User ID: ${user.uid}',
//                         style: TextStyle(color: Colors.grey, fontSize: 11),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30),
//             _buildCard([
//               _buildMenuItem(
//                 Icons.emoji_events,
//                 'Competition',
//                 hasJoinedCompetition ? 'View your competition' : 'Start a competition',
//                 Colors.orangeAccent.withOpacity(0.9),
//                 onTap: () => _navigateToCompetition(context, hasJoinedCompetition),
//                 // Add a visual indicator for competition status
//                 trailing: hasJoinedCompetition
//                     ? Icon(Icons.check_circle, color: Colors.green, size: 16)
//                     : Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
//               ),
//             ]),
//             SizedBox(height: 15),
//             _buildCard([
//               _buildMenuItem(Icons.settings, 'App settings', '', Colors.deepPurpleAccent.withOpacity(0.5)),
//               _buildMenuItem(Icons.perm_device_info, 'Device permissions', '', Colors.greenAccent.withOpacity(0.5)),
//               _buildMenuItem(Icons.lock, 'App permissions', '', Colors.green.withOpacity(0.6)),
//               _buildMenuItem(Icons.feedback, 'Feedback', '', Colors.orange.withOpacity(0.6)),
//               _buildMenuItem(Icons.info, 'Version', '1.0.0', Colors.deepPurpleAccent.withOpacity(0.5)),
//               _buildMenuItem(Icons.help_outline, 'About this app', '', Colors.greenAccent.withOpacity(0.5)),
//             ]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCard(List<Widget> children) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: children,
//       ),
//     );
//   }
//
//   Widget _buildMenuItem(
//       IconData icon,
//       String title,
//       String subtitle,
//       Color iconColor,
//       {VoidCallback? onTap,
//         Widget? trailing}
//       ) {
//     return ListTile(
//       leading: Icon(icon, color: iconColor),
//       title: Text(title, style: TextStyle(color: Colors.white70, fontSize: 16)),
//       subtitle: subtitle.isNotEmpty
//           ? Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 14))
//           : null,
//       trailing: trailing ?? Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
//       onTap: onTap,
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../0 theme/theme_provider.dart';
import '../profile_screens/1 app setting.dart';
import '../profile_screens/3 app permission.dart';
import '../profile_screens/competetion/1warning.dart';
import '../profile_screens/competetion/2competition_screen.dart';
import '../profile_screens/2hrd device permission.dart';
import '../profile_screens/4 feedback.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Text(
            'No user is signed in.\nPlease sign in to view your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }
        if (snapshot.hasError) {
          return _buildErrorScreen();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildNoDataScreen();
        }

        var userData = snapshot.data!;
        String fullName = userData['name'] ?? 'No Name';
        bool hasJoinedCompetition = userData['competition'] == true;

        return Scaffold(
          backgroundColor: isDarkMode
              ? Colors.black12.withOpacity(0.7)
              : Colors.black12.withOpacity(0.5),
          appBar: AppBar(
            title: Text(
              'Profile',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
          ),
          body: _buildProfileContainer(
              user, fullName, context, hasJoinedCompetition),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black12.withOpacity(0.7),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black12.withOpacity(0.7),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text(
          'Error fetching data',
          style: TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildNoDataScreen() {
    return Scaffold(
      backgroundColor: Colors.black12.withOpacity(0.7),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text(
          'No profile data found',
          style: TextStyle(color: Colors.orangeAccent, fontSize: 16),
        ),
      ),
    );
  }

  void _navigateToCompetition(BuildContext context, bool hasJoined) {
    if (hasJoined) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => CompetitionScreen()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => WarningScreen()));
    }
  }

  Widget _buildProfileContainer(User user, String fullName,
      BuildContext context, bool hasJoinedCompetition) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile1.gif'),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'User ID: ${user.uid}',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            _buildCard([
              _buildMenuItem(
                Icons.emoji_events,
                'Competition',
                hasJoinedCompetition
                    ? 'View your competition'
                    : 'Start a competition',
                Colors.orangeAccent.withOpacity(0.9),
                onTap: () =>
                    _navigateToCompetition(context, hasJoinedCompetition),
                trailing: hasJoinedCompetition
                    ? Icon(Icons.check_circle, color: Colors.green, size: 16)
                    : Icon(Icons.arrow_forward_ios,
                        color: Colors.grey, size: 16),
              ),
            ]),
            SizedBox(height: 15),
            _buildCard([
              _buildMenuItem(
                Icons.settings,
                'App settings',
                '',
                Colors.deepPurpleAccent.withOpacity(0.5),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AppSettingsScreen())),
              ),
              _buildMenuItem(
                Icons.perm_device_info,
                'Hardware Device permissions',
                '',
                Colors.greenAccent.withOpacity(0.5),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => hrd_device())),
              ),
              _buildMenuItem(
                Icons.lock,
                'App permissions',
                '',
                Colors.green.withOpacity(0.6),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AppPermissionScreen())),
              ),
              _buildMenuItem(
                Icons.feedback,
                'Feedback',
                '',
                Colors.orange.withOpacity(0.6),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => FeedbackScreen())),
              ),
              ListTile(
                  leading: Icon(Icons.info,
                      color: Colors.deepPurpleAccent.withOpacity(0.5)),
                  title: Text('Version',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  subtitle: Text('1.0.0',
                      style: TextStyle(color: Colors.grey, fontSize: 14))),
              _buildMenuItem(
                Icons.help_outline,
                'About this app',
                '',
                Colors.greenAccent.withOpacity(0.5),
                //onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AboutAppScreen())),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, String subtitle, Color iconColor,
      {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: Colors.white70, fontSize: 16)),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 14))
          : null,
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }
}
