import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  Future<void> _login() async {
    print('=== LOGIN ATTEMPT START ===');
    print('Email: ${_emailController.text}');
    print('Password length: ${_passwordController.text.length}');
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      print('ERROR: Empty email or password');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email dan password harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Format email tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Try to login with driver credentials
      print('Attempting login with: ${_emailController.text.trim()}');
      final user = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      final success = user != null;
      print('Login success: $success');

      if (success) {
        // Get login response data from user object
        final status = 'active'; // Default for now
        final hasVehicle = true; // Default for now
        print('Driver status from login: $status');
        print('Has vehicle: $hasVehicle');
        
        setState(() => _isLoading = false);
        
        // Navigate based on driver status
        print('=== NAVIGATION DECISION ===');
        print('Status for navigation: "$status"');
        
        // Navigate to main screen for now
        print('NAVIGATING TO: Main Screen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
        print('=== NAVIGATION COMPLETE ===');
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email atau password salah. Silakan coba lagi.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 50),
              Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: XPainter(Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Masukkan email driver dan password untuk masuk',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7), 
                  fontSize: 14
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email', 
                    style: TextStyle(
                      fontWeight: FontWeight.w500, 
                      color: Theme.of(context).colorScheme.onBackground
                    )
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'driver@example.com',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password', 
                    style: TextStyle(
                      fontWeight: FontWeight.w500, 
                      color: Theme.of(context).colorScheme.onBackground
                    )
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lupa password?', 
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7), 
                      fontSize: 14
                    )
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Login', style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white
                        )),
                ),
              ),
              
              SizedBox(height: 30),
              SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum memiliki akun? ', 
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7))
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    ),
                    child: Text(
                      'Registrasi', 
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary, 
                        fontWeight: FontWeight.w600
                      )
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Driver Accounts:', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 12, 
                        color: Theme.of(context).colorScheme.onSurface
                      )
                    ),
                    Text(
                      'Email: driver1@example.com', 
                      style: TextStyle(
                        fontSize: 12, 
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                      )
                    ),
                    Text(
                      'Password: driver123', 
                      style: TextStyle(
                        fontSize: 12, 
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                      )
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Email: driver2@example.com', 
                      style: TextStyle(
                        fontSize: 12, 
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                      )
                    ),
                    Text(
                      'Password: driver123', 
                      style: TextStyle(
                        fontSize: 12, 
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                      )
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Email: assddd@ffff.bv (Arty)', 
                      style: TextStyle(
                        fontSize: 12, 
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                      )
                    ),
                    Text(
                      'Password: arty123', 
                      style: TextStyle(
                        fontSize: 12, 
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class XPainter extends CustomPainter {
  final Color color;
  
  XPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}