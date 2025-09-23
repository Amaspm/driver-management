import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'ktp_upload_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alamatController = TextEditingController();
  
  String? _selectedCity;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _phoneError;
  String? _alamatError;
  
  final List<String> _cities = [
    'Surabaya', 'Jakarta', 'Bandung', 'Medan', 'Semarang', 
    'Makassar', 'Palembang', 'Tangerang', 'Depok', 'Bekasi'
  ];

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Alamat email tidak valid';
      } else {
        _emailError = null;
      }
    });
  }
  
  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = null;
      } else if (value.length < 6) {
        _passwordError = 'Password minimal 6 karakter';
      } else {
        _passwordError = null;
      }
    });
  }
  
  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = null;
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Password tidak cocok';
      } else {
        _confirmPasswordError = null;
      }
    });
  }
  
  void _validatePhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = null;
      } else if (value.length < 10) {
        _phoneError = 'Nomor Telephone tidak valid';
      } else {
        _phoneError = null;
      }
    });
  }
  
  void _validateAlamat(String value) {
    setState(() {
      if (value.isEmpty) {
        _alamatError = null;
      } else if (value.length < 10) {
        _alamatError = 'Alamat terlalu pendek';
      } else {
        _alamatError = null;
      }
    });
  }

  Future<void> _register() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda harus menyetujui syarat dan ketentuan')),
      );
      return;
    }
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty || _phoneController.text.isEmpty || 
        _selectedCity == null || _alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi semua field yang diperlukan')),
      );
      return;
    }
    
    if (_emailError != null || _passwordError != null || _confirmPasswordError != null || 
        _phoneError != null || _alamatError != null) {
      return;
    }

    setState(() => _isLoading = true);

    // Simulate registration
    await Future.delayed(Duration(seconds: 2));
    
    // Save registration data to SharedPreferences
    final registrationData = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'no_hp': _phoneController.text.trim(),
      'kota': _selectedCity,
      'alamat': _alamatController.text.trim(),
    };
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registration_data', json.encode(registrationData));
    
    print('DEBUG: Saved registration data: ${json.encode(registrationData)}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registrasi berhasil!')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => KtpUploadScreen()),
    );
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Register',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
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
                'Register',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Lengkapi formulir di bawah ini dengan benar\nuntuk mendaftar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7), 
                  fontSize: 14
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'E-Mail',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: _validateEmail,
                    decoration: InputDecoration(
                      hintText: 'exp: kevindebruyne@gmail.com',
                      errorText: _emailError,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    onChanged: _validatePassword,
                    decoration: InputDecoration(
                      hintText: 'Masukkan password',
                      errorText: _passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Confirm Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konfirmasi Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    onChanged: _validateConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Konfirmasi password',
                      errorText: _confirmPasswordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Phone Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomor Telephone',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: _validatePhone,
                    decoration: InputDecoration(
                      hintText: 'exp: 813-3501-7174',
                      errorText: _phoneError,
                      prefixIcon: Container(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Center(
                                child: Text(
                                  '🇮🇩',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '+62',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // City Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kota Tempat Anda Berkendara',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    hint: Text(
                      'exp: Surabaya',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    ),
                    decoration: InputDecoration(),
                    items: _cities.map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Address Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alamat Lengkap',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _alamatController,
                    maxLines: 3,
                    onChanged: _validateAlamat,
                    decoration: InputDecoration(
                      hintText: 'Masukkan alamat lengkap Anda',
                      errorText: _alamatError,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 40),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                          'Registrasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Terms and Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: 'Saya menyetujui '),
                          TextSpan(
                            text: 'Syarat & Ketentuan',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' dan '),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' Platform'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30),
              
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah memiliki akun? ', 
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7))
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Login', 
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary, 
                        fontWeight: FontWeight.w600
                      )
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Help Center
              Column(
                children: [
                  Text(
                    'Butuh bantuan? Kunjungi halaman',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Help Center',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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