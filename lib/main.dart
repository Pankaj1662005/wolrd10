import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_moving_background/flutter_moving_background.dart';
import 'package:provider/provider.dart';
import 'package:world7/0%20theme/main_theme.dart';
import 'package:world7/screens/home_screen.dart';
import 'package:world7/screens/profile_screen.dart';
import 'package:world7/screens/time_screen.dart';

import '0 theme/theme_provider.dart';
import '1auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DeepLogix',
          themeMode: themeProvider.themeMode, // 👈 Use ThemeProvider
          theme:LightMode,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: AuthGate(),
        );
      },
    );
  }
}


class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return BottomNavigationScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class BottomNavigationScreen extends StatefulWidget {
  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    SpeechRecognitionScreen(),
    TimeScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return MovingBackground(
      duration: Duration(seconds: 5),
      backgroundColor: isDarkMode ? Colors.black12 : Colors.grey[100]!, // 👈 Background changes based on theme
      circles: const [
        MovingCircle(color: Colors.deepPurpleAccent),
        MovingCircle(color: Colors.deepOrangeAccent),
        MovingCircle(color: Colors.lightBlueAccent),
        MovingCircle(color: Colors.grey),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let MovingBackground show
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: isDarkMode ? Colors.black : Colors.black.withOpacity(0.7), // 👈 Dark/light bottom nav
          selectedItemColor: isDarkMode ? Colors.white : Colors.black,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Time'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

}

