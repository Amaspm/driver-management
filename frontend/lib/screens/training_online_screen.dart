import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'training_module_screen.dart';

class TrainingOnlineScreen extends StatefulWidget {
  @override
  _TrainingOnlineScreenState createState() => _TrainingOnlineScreenState();
}

class _TrainingOnlineScreenState extends State<TrainingOnlineScreen> {
  late ApiService _apiService;
  List<dynamic> modules = [];
  bool isLoading = true;
  Set<int> completedModules = {};
  bool dataSaved = false;
  bool isAuthenticated = false;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(AuthService());
    _loadTrainingModules();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments from route
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      isAuthenticated = args['isAuthenticated'] ?? false;
      userEmail = args['userEmail'];
      dataSaved = true; // Data already saved in photo upload
    }
  }
  
  Future<void> _saveRegistrationDataImmediately() async {
    if (dataSaved) return;
    
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      print('DEBUG: Args received: $args');
      print('DEBUG: isAuthenticated: $isAuthenticated');
      
      if (args != null && !args.containsKey('isAuthenticated')) {
        print('DEBUG: Attempting to save registration data...');
        final result = await _apiService.submitDriverRegistration(args);
        print('DEBUG: Registration result: $result');
        setState(() {
          dataSaved = true;
        });
        print('Registration data saved immediately on training page load');
      } else {
        print('DEBUG: No registration data to save or user is authenticated');
      }
    } catch (e) {
      print('Error saving registration immediately: $e');
    }
  }

  Future<void> _loadTrainingModules() async {
    try {
      final trainingModules = await _apiService.getTrainingModules();
      setState(() {
        modules = trainingModules;
      });
      
      // Load progress for authenticated users
      if (isAuthenticated) {
        await _loadTrainingProgress();
      }
      
      setState(() {
        isLoading = false;
      });
      
      // Save registration data immediately after modules load for guest users
      if (!isAuthenticated && !dataSaved) {
        _saveRegistrationDataImmediately();
      }
    } catch (e) {
      print('Error loading training modules: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadTrainingProgress() async {
    try {
      final progressList = await _apiService.getTrainingProgress();
      Set<int> completed = {};
      
      for (var progress in progressList) {
        if (progress['is_completed'] == true) {
          completed.add(progress['module']);
        }
      }
      
      setState(() {
        completedModules = completed;
      });
      
      print('Loaded training progress: ${completedModules.length} completed modules');
    } catch (e) {
      print('Error loading training progress: $e');
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'pemula':
        return Color(0xFF28A745);
      case 'lanjutan':
        return Color(0xFF007BFF);
      case 'expert':
        return Color(0xFFDC3545);
      default:
        return Color(0xFF6C757D);
    }
  }

  void _openModule(Map<String, dynamic> module) async {
    // Save registration data first if not authenticated and not saved yet
    if (!isAuthenticated && !dataSaved) {
      await _saveRegistrationData();
    }
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingModuleScreen(
          module: module, 
          isGuestMode: !isAuthenticated,
          userEmail: userEmail,
        ),
      ),
    );
    
    // Refresh progress after returning from module
    if (isAuthenticated) {
      await _loadTrainingProgress();
    } else if (result == true) {
      setState(() {
        completedModules.add(module['id']);
      });
    }
  }
  
  Future<void> _saveRegistrationData() async {
    if (dataSaved) return;
    
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        await _apiService.submitDriverRegistration(args);
        setState(() {
          dataSaved = true;
        });
        print('Registration data saved successfully');
      }
    } catch (e) {
      print('Error saving registration: $e');
    }
  }

  bool _checkAllTrainingCompleted() {
    return completedModules.length >= modules.length;
  }

  void _showTrainingIncompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Training Belum Selesai'),
        content: Text('Anda harus menyelesaikan semua materi pelatihan dengan 100% poin sebelum melanjutkan registrasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService().logout();
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAuthenticated ? 'Training Online' : 'Register',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Help Center', style: TextStyle(color: Colors.grey.shade600)),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              
              // Title
              Text(
                'Training Online Driver',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Materi Pelatihan section
              Text(
                'Materi Pelatihan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 15),
              
              // Module cards
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (modules.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No training modules available',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                ...modules.map((module) => Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: _buildModuleCard(
                    module['title'] ?? 'Training Module',
                    module['description'] ?? 'Training description',
                    module['level'] ?? 'pemula',
                    completedModules.contains(module['id']) ? '✅ Completed' : '',
                    module['instructor'] ?? 'Instructor',
                    _getLevelColor(module['level'] ?? 'pemula'),
                    () => _openModule(module),
                  ),
                )).toList(),
              

              
              SizedBox(height: 40),
              
              // Continue button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: modules.isEmpty ? null : () async {
                    // Check if all training modules are completed
                    bool allCompleted = _checkAllTrainingCompleted();
                    
                    if (!allCompleted) {
                      _showTrainingIncompleteDialog();
                      return;
                    }
                    
                    if (isAuthenticated && userEmail != null) {
                      // Complete training for authenticated user
                      try {
                        await _apiService.completeTraining(userEmail!);
                        // Navigate to account pending (waiting for admin approval)
                        Navigator.pushReplacementNamed(context, '/account_pending');
                      } catch (e) {
                        print('Error completing training: $e');
                      }
                    } else {
                      // This shouldn't happen with new flow
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDC3545),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    completedModules.length >= modules.length ? 'Lanjutkan' : 'Selesaikan Training (${completedModules.length}/${modules.length})',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF495057),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(String title, String description, String level, String subtitle, String instructor, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.school,
                color: color,
                size: 30,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF495057),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6C757D),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF495057),
                      ),
                    ),
                  ],
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          level.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        instructor,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.person, size: 16, color: Color(0xFF6C757D)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF6C757D),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(String title, String quizNumber, String subtitle) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Baru',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C757D),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF495057),
              ),
            ),
          SizedBox(height: 4),
          Text(
            quizNumber,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF6C757D),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF6C757D),
            ),
          ),
        ],
      ),
    );
  }
}