import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../0 theme/theme_provider.dart';


class AppPermissionScreen extends StatefulWidget {
  @override
  _AppPermissionScreenState createState() => _AppPermissionScreenState();
}

class _AppPermissionScreenState extends State<AppPermissionScreen> {

  Map<String, bool> _permissions = {
    'camera': false,
    'microphone': false,
    'location': true,
    'storage': true,
    'contacts': false,
    'notifications': true,
    'phone': false,
    'calendar': false,
  };


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black12.withOpacity(0.7) : Colors.black12.withOpacity(0.5),
      appBar: AppBar(
        title: Text(
          'App Permissions',
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
              // Info Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Some features may not work properly if permissions are denied from app.',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Media Permissions
              _buildPermissionSection(
                title: 'Media',
                permissions: [

                  _buildPermissionItem(
                    'Microphone',
                    'Record audio',
                    Icons.mic,
                    Colors.red,
                    'microphone',
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Location Permissions
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.camera, color: Colors.white),
                  title: Text(
                    'Camera ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Manage permissions in app settings',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  onTap: Permission.camera.request,
                ),
              ),

              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.storage, color: Colors.white),
                  title: Text(
                    'System Storage',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Manage permissions in app settings',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  onTap: Permission.storage.request,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.android_sharp, color: Colors.green),
                  title: Text(
                    'Run in background',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Manage permissions in app settings',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  onTap: Permission.ignoreBatteryOptimizations.request,
                ),
              ),


              SizedBox(height: 20),

              // Other Permissions
              _buildPermissionSection(
                title: 'Other',
                permissions: [
                  _buildPermissionItem(
                    'Notifications',
                    'Show notifications',
                    Icons.notifications,
                    Colors.amber,
                    'notifications',
                  ),
                  _buildPermissionItem(
                    'Calendar',
                    'Access your calendar events',
                    Icons.calendar_today,
                    Colors.indigo,
                    'calendar',
                  ),
                  _buildPermissionItem(
                    'Data Tracking',
                    'Limit targeted  Data based on your device ID once turned on we track your data ,deplogix never share data with 3 party',
                    Icons.adb,
                    Colors.green,
                    'camera',
                  ),
                ],
              ),

              SizedBox(height: 24),

              // System Settings But
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionSection({required String title, required List<Widget> permissions}) {
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
          child: Column(children: permissions),
        ),
      ],
    );
  }

  Widget _buildPermissionItem(String title, String description, IconData icon, Color iconColor, String permissionKey) {
    return SwitchListTile(
      secondary: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: Colors.white70, fontSize: 16)),
      subtitle: Text(description, style: TextStyle(color: Colors.grey, fontSize: 14)),
      value: _permissions[permissionKey] ?? false,
      onChanged: (value) {
        setState(() {
          _permissions[permissionKey] = value;
        });
        _showPermissionDialog(title, value);
      },
      activeColor: iconColor,
    );
  }

  void _showPermissionDialog(String permissionName, bool granted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            '${permissionName} Permission',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            granted
                ? 'The app can now access your $permissionName. You can revoke this permission at any time.'
                : 'The app will no longer have access to your $permissionName. Some features may not work properly.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.orange)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showSystemSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'System Settings',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'This will open your device\'s system settings where you can manage app permissions at the system level.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Open Settings', style: TextStyle(color: Colors.orange)),
              onPressed: () {
                Navigator.pop(context);
                // Here you would implement the actual system settings navigation
                // For example: openAppSettings() from permission_handler package
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening system settings...'),
                    backgroundColor: Colors.blue,
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


// Future<void> requestBluetoothPermissions() async {
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.locationWhenInUse,
//     Permission.location,
//     Permission.locationAlways,
//     Permission.bluetoothAdvertise,
//   ].request();
// }