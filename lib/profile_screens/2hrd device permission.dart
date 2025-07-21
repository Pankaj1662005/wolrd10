import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../0 theme/theme_provider.dart';
import '3 app permission.dart';


class hrd_device extends StatefulWidget {
  @override
  _hrd_deviceState createState() => _hrd_deviceState();
}

class _hrd_deviceState extends State<hrd_device> {
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
          'Hardware Device Permissions',
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
                    Icon(Icons.info_outline, color: Colors.red, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can only change the permissions from the harware. Some features may not work properly if permissions are denied from device. Currently you seeing the permissions which Deeplogix hardware needs.',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),


              // System Settings Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title: Text(
                    'Open System Settings',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Manage permissions in device settings',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  onTap: () {
                    _showSystemSettingsDialog();
                  },
                ),
              ),

              SizedBox(height: 24),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.bluetooth_audio, color: Colors.white),
                  title: Text(
                    'Bluetooth',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Manage permissions in Deeplogix device settings',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                  },
                ),
              ),

              SizedBox(height: 24,),

              InkWell(
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:  Column(
                    children: [
                      SizedBox(height: 20,),
                      Icon(Icons.signal_wifi_connected_no_internet_4, size: 50,),
                      SizedBox(height: 24,),
                      Text(
                        'Click to Troubleshoot',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),

                    ],
                  ),
                ),
                onTap: (){ _connectingdeviceDialog(context);}
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _connectingdeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          backgroundColor: Colors.grey[900],
          title: Text('Connecting to Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/Bluetooth.json',
                width: 300,
                height: 300,
                repeat: true,
              ),
              SizedBox(height: 20),
              Text('Please wait while we connect...'),
            ],
          ),
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