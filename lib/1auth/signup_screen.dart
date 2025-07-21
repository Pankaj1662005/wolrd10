import 'package:flutter/material.dart';
import 'package:world7/0%20theme/main_theme.dart';
import 'package:world7/1auth/verification%20screen.dart';
import 'auth service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  final UserAuthService _authService = UserAuthService();
  String? _selectedProfession = 'Student';
  bool _isPasswordVisible = false;


  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final res = await _authService.signUpUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _fullNameController.text.trim(),
      profession: _selectedProfession!,
    );


    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));

    if (res.startsWith("A verification email")) {
      // Navigate to verification screen here if needed
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
            name: _fullNameController.text, // We don't have the full name here
            email: _emailController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Icon
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  SizedBox(height: 20),

                  // Full Name Text Field
                  TextFormField(
                    controller: _fullNameController,
                    style: TextStyle(color: Colors.white),
                    validator: (value) => value!.isEmpty ? 'Enter full name' : null,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // Email Text Field
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                    value == null || !value.contains('@') ? 'Enter valid email' : null,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // Password Text Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: Colors.white),
                    validator: (value) =>
                    value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // Profession Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedProfession,
                    dropdownColor: Colors.grey[900],
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProfession = newValue;
                      });
                    },
                    items: ['Student', 'Teacher', 'White-collar']
                        .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.white)),
                    ))
                        .toList(),
                  ),
                  SizedBox(height: 20),

                  // Signup Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    ),
                    onPressed: _signup,
                    child: Text('SIGN UP', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 10),

                  // Navigate to Login Screen
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Already have an account? LOGIN",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
