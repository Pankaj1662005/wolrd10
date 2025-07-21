import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world7/profile_screens/update%20profile.dart';

import '../0 theme/theme_provider.dart';

class AppSettingsScreen extends StatefulWidget {
  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = false;
  bool _autoBackupEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black12.withOpacity(0.7) : Colors.black12.withOpacity(0.5),
      appBar: AppBar(
        title: Text(
          'App Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Section
              _buildSectionCard(
                title: 'Appearance',
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: Text('Dark Mode', style: TextStyle(color: Colors.white70)),
                        subtitle: Text('Enable dark 0 theme', style: TextStyle(color: Colors.grey)),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        activeColor: Colors.orange,
                        secondary: Icon(Icons.dark_mode, color: Colors.orange),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.blue),
                    title: Text('Language', style: TextStyle(color: Colors.white70)),
                    subtitle: Text(_selectedLanguage, style: TextStyle(color: Colors.grey)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                    onTap: () => _showLanguageDialog(),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Notifications Section
              _buildSectionCard(
                title: 'Notifications',
                children: [
                  SwitchListTile(
                    title: Text('Push Notifications', style: TextStyle(color: Colors.white70)),
                    subtitle: Text('Receive app notifications', style: TextStyle(color: Colors.grey)),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: Colors.green,
                    secondary: Icon(Icons.notifications, color: Colors.green),
                  ),
                  SwitchListTile(
                    title: Text('Sound', style: TextStyle(color: Colors.white70)),
                    subtitle: Text('Play notification sounds', style: TextStyle(color: Colors.grey)),
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                    },
                    activeColor: Colors.blue,
                    secondary: Icon(Icons.volume_up, color: Colors.blue),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Data Section
              _buildSectionCard(
                title: 'Data & Storage',
                children: [
                  SwitchListTile(
                    title: Text('Auto Backup', style: TextStyle(color: Colors.white70)),
                    subtitle: Text('Backup data automatically', style: TextStyle(color: Colors.grey)),
                    value: _autoBackupEnabled,
                    onChanged: (value) {
                      setState(() {

                      });
                    },
                    activeColor: Colors.purple,
                    secondary: Icon(Icons.backup, color: Colors.purple),
                  ),
                  ListTile(
                    leading: Icon(Icons.storage, color: Colors.red),
                    title: Text('Clear Cache', style: TextStyle(color: Colors.white70)),
                    subtitle: Text('Free up storage space', style: TextStyle(color: Colors.grey)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                    onTap: () => _showClearCacheDialog(),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Account Section
              _buildSectionCard(
                title: 'Account',
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.teal),
                    title: Text('Edit Profile', style: TextStyle(color: Colors.white70)),
                    subtitle: Text('Update your profile information', style: TextStyle(color: Colors.grey)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),

                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserFullProfile())),
                  ),
                  ListTile(
                    leading: Icon(Icons.security, color: Colors.amber),
                    title: Text('Privacy Settings', style: TextStyle(color: Colors.white70)),
                    subtitle: Text('Manage your privacy preferences', style: TextStyle(color: Colors.grey)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                    onTap: () {
                      // Navigate to privacy settings
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Select Language', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English'),

            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language, style: TextStyle(color: Colors.white70)),
      trailing: _selectedLanguage == language ? Icon(Icons.check, color: Colors.orange) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Clear Cache', style: TextStyle(color: Colors.white)),
          content: Text(
            'This will clear all cached data. Are you sure you want to continue?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Clear', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                // Implement cache clearing logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cache cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}