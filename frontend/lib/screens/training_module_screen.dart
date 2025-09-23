import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TrainingModuleScreen extends StatefulWidget {
  final Map<String, dynamic> module;
  final bool isGuestMode;
  final String? userEmail;

  const TrainingModuleScreen({Key? key, required this.module, this.isGuestMode = false, this.userEmail}) : super(key: key);

  @override
  _TrainingModuleScreenState createState() => _TrainingModuleScreenState();
}

class _TrainingModuleScreenState extends State<TrainingModuleScreen> {
  late ApiService _apiService;
  List<dynamic> contents = [];
  List<dynamic> quizzes = [];
  bool isLoading = true;
  int currentContentIndex = 0;
  bool showQuiz = false;
  Map<String, String> quizAnswers = {};
  int currentPoints = 0;
  int totalPoints = 0;
  int progressPercentage = 0;
  bool canContinue = false;
  List<int> completedContents = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(AuthService());
    _loadModuleData();
  }

  Future<void> _loadModuleData() async {
    try {
      print('DEBUG: Loading module data for module ${widget.module['id']}');
      print('DEBUG: Guest mode: ${widget.isGuestMode}');
      
      final startResult = await _apiService.startTrainingModule(widget.module['id'], isGuest: widget.isGuestMode);
      print('DEBUG: Start result: $startResult');
      
      final moduleContents = await _apiService.getTrainingContents(widget.module['id']);
      print('DEBUG: Contents loaded: ${moduleContents.length}');
      
      final moduleQuizzes = await _apiService.getTrainingQuizzes(widget.module['id']);
      print('DEBUG: Quizzes loaded: ${moduleQuizzes.length}');
      
      // Load existing progress for authenticated users
      List<int> existingCompleted = [];
      Map<String, String> existingAnswers = {};
      int nextContentIndex = 0;
      bool shouldShowQuiz = false;
      
      if (!widget.isGuestMode) {
        try {
          final progressList = await _apiService.getTrainingProgress();
          final moduleProgress = progressList.firstWhere(
            (p) => p['module'] == widget.module['id'],
            orElse: () => null,
          );
          
          if (moduleProgress != null) {
            existingCompleted = List<int>.from(moduleProgress['completed_contents'] ?? []);
            existingAnswers = Map<String, String>.from(moduleProgress['quiz_answers'] ?? {});
            
            // Calculate next content index based on completed contents
            nextContentIndex = existingCompleted.length;
            if (nextContentIndex >= moduleContents.length && moduleQuizzes.isNotEmpty && existingAnswers.isEmpty) {
              shouldShowQuiz = true;
            }
          }
        } catch (e) {
          print('Error loading existing progress: $e');
        }
      }
      
      setState(() {
        contents = moduleContents;
        quizzes = moduleQuizzes;
        currentContentIndex = nextContentIndex < moduleContents.length ? nextContentIndex : moduleContents.length - 1;
        showQuiz = shouldShowQuiz;
        currentPoints = (startResult['current_points'] ?? 0).toInt();
        totalPoints = (startResult['total_points'] ?? 0).toInt();
        progressPercentage = (startResult['progress_percentage'] ?? 0).toInt();
        completedContents = existingCompleted;
        quizAnswers = existingAnswers;
        isLoading = false;
      });
      
      print('DEBUG: Loaded progress - Content index: $nextContentIndex, Completed: ${existingCompleted.length}, Show quiz: $shouldShowQuiz');
    } catch (e) {
      print('Error loading module data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _completeContent(int contentId) async {
    try {
      final result = await _apiService.completeTrainingContent(
        widget.module['id'], 
        contentId,
        isGuest: widget.isGuestMode,
        completedContents: widget.isGuestMode ? completedContents : null,
      );
      
      setState(() {
        currentPoints = (result['current_points'] ?? currentPoints).toInt();
        totalPoints = (result['total_points'] ?? totalPoints).toInt();
        progressPercentage = (result['progress_percentage'] ?? progressPercentage).toInt();
        
        if (widget.isGuestMode) {
          completedContents = List<int>.from(result['completed_contents'] ?? []);
        }
      });
    } catch (e) {
      print('Error completing content: $e');
    }
  }

  Future<void> _submitQuiz() async {
    try {
      final result = await _apiService.submitTrainingQuiz(
        widget.module['id'], 
        quizAnswers,
        isGuest: widget.isGuestMode,
        completedContents: widget.isGuestMode ? completedContents : null,
      );
      
      setState(() {
        currentPoints = (result['current_points'] ?? currentPoints).toInt();
        totalPoints = (result['total_points'] ?? totalPoints).toInt();
        progressPercentage = (result['progress_percentage'] ?? progressPercentage).toInt();
        canContinue = result['can_continue'] ?? false;
      });
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Quiz Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Points Earned: ${result['quiz_points']}'),
              Text('Correct: ${result['correct_answers']}/${result['total_questions']}'),
              Text('Total Progress: $progressPercentage%'),
              SizedBox(height: 10),
              Text(
                canContinue ? 'Training Completed! 🎉' : 'Need 100% to continue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: canContinue ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (canContinue) {
                  Navigator.of(context).pop(canContinue); // Return completion status
                }
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error submitting quiz: $e');
    }
  }

  Widget _buildContent(Map<String, dynamic> content) {
    switch (content['content_type']) {
      case 'narration':
        return _buildNarrationContent(content);
      case 'image':
        return _buildImageContent(content);
      case 'video':
        return _buildVideoContent(content);
      case 'infographic':
        return _buildInfographicContent(content);
      default:
        return _buildNarrationContent(content);
    }
  }

  Widget _buildNarrationContent(Map<String, dynamic> content) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content['title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (content['media_content'] != null && content['media_content'].isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                ),
              ),
            Text(
              content['text_content'] ?? '',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(Map<String, dynamic> content) {
    String? imageUrl = content['media_url'];
    
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content['title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('data:image/placeholder')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 50, color: Colors.grey[600]),
                                SizedBox(height: 8),
                                Text('Image placeholder', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: Colors.grey[600]),
                          SizedBox(height: 8),
                          Text('Image placeholder', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 16),
            if (content['text_content'] != null)
              Text(
                content['text_content'],
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent(Map<String, dynamic> content) {
    String? videoUrl = content['youtube_embed_url'] ?? content['media_url'];
    String? thumbnailUrl = content['youtube_thumbnail'];
    
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content['title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _playVideo(videoUrl),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    if (thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          thumbnailUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.black,
                              child: Center(
                                child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        color: Colors.black,
                        child: Center(
                          child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
                        ),
                      ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow, size: 40, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (videoUrl != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () => _openUrl(videoUrl),
                  child: Text(
                    'Video URL: ${videoUrl.length > 50 ? videoUrl.substring(0, 50) + '...' : videoUrl}',
                    style: TextStyle(fontSize: 12, color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            SizedBox(height: 16),
            if (content['text_content'] != null)
              Text(
                content['text_content'],
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _playVideo(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video URL not available')),
      );
      return;
    }

    // Open video in external app/browser
    _openUrl(videoUrl);
  }

  Future<void> _openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open URL: $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening URL: $e')),
      );
    }
  }

  Widget _buildInfographicContent(Map<String, dynamic> content) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content['title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 50, color: Colors.blue[600]),
                    SizedBox(height: 8),
                    Text('Infographic', style: TextStyle(color: Colors.blue[600])),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (content['text_content'] != null)
              Text(
                content['text_content'],
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Quiz - ${widget.module['title']}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(height: 8),
                      Text(
                        quiz['question'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 16),
                      ...['A', 'B', 'C', 'D'].map((option) {
                        final optionText = quiz['option_${option.toLowerCase()}'];
                        return RadioListTile<String>(
                          title: Text('$option. $optionText'),
                          value: option,
                          groupValue: quizAnswers[quiz['id'].toString()],
                          onChanged: (value) {
                            setState(() {
                              quizAnswers[quiz['id'].toString()] = value!;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: quizAnswers.length == quizzes.length ? _submitQuiz : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFDC3545),
              padding: EdgeInsets.symmetric(vertical: 16),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Submit Quiz',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
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
          widget.module['title'],
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : showQuiz
              ? _buildQuizSection()
              : Column(
                  children: [
                    // Progress indicator
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Points: $currentPoints/$totalPoints'),
                              Spacer(),
                              Text('$progressPercentage%'),
                            ],
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progressPercentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC3545)),
                          ),
                          if (contents.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('Content: ${currentContentIndex + 1}/${contents.length}'),
                            ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Expanded(
                      child: contents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.school, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('No content available', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                ],
                              ),
                            )
                          : _buildContent(contents[currentContentIndex]),
                    ),
                    
                    // Navigation buttons
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (currentContentIndex > 0)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    currentContentIndex--;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[600],
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text('Previous', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          if (currentContentIndex > 0) SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: contents.isEmpty ? null : () async {
                                if (currentContentIndex < contents.length - 1) {
                                  await _completeContent(contents[currentContentIndex]['id']);
                                  setState(() {
                                    currentContentIndex++;
                                  });
                                } else {
                                  // Last content, show quiz
                                  await _completeContent(contents[currentContentIndex]['id']);
                                  if (quizzes.isNotEmpty) {
                                    setState(() {
                                      showQuiz = true;
                                    });
                                  } else {
                                    // No quiz, mark as completed
                                    Navigator.of(context).pop(true);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFDC3545),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                contents.isEmpty 
                                    ? 'No Content' 
                                    : currentContentIndex < contents.length - 1 
                                        ? 'Next' 
                                        : quizzes.isNotEmpty 
                                            ? 'Take Quiz' 
                                            : 'Complete',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}