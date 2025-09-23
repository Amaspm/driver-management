import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CertificateCameraScreen extends StatefulWidget {
  @override
  _CertificateCameraScreenState createState() => _CertificateCameraScreenState();
}

class _CertificateCameraScreenState extends State<CertificateCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0],
          ResolutionPreset.high,
        );
        await _controller!.initialize();
        try {
          await _controller!.setFlashMode(_flashMode);
        } catch (e) {
          print('Flash not supported: $e');
        }
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    try {
      setState(() {
        _flashMode = _flashMode == FlashMode.off ? FlashMode.always : FlashMode.off;
      });
      await _controller!.setFlashMode(_flashMode);
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'certificate_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(appDir.path, fileName);

      final XFile picture = await _controller!.takePicture();
      final File imageFile = File(picture.path);
      final File savedImage = await imageFile.copy(filePath);

      Navigator.pop(context, savedImage);
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Foto Sertifikat',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
              color: Colors.white,
            ),
            onPressed: _isInitialized ? _toggleFlash : null,
          ),
        ],
      ),
      body: _isInitialized
          ? Stack(
              children: [
                // Camera preview
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),
                
                // Overlay with guide frame
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.5,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Corner indicators
                            Positioned(
                              top: -1,
                              left: -1,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFFDC3545), width: 4),
                                    left: BorderSide(color: Color(0xFFDC3545), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -1,
                              right: -1,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFFDC3545), width: 4),
                                    right: BorderSide(color: Color(0xFFDC3545), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -1,
                              left: -1,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFFDC3545), width: 4),
                                    left: BorderSide(color: Color(0xFFDC3545), width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -1,
                              right: -1,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFFDC3545), width: 4),
                                    right: BorderSide(color: Color(0xFFDC3545), width: 4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Instructions
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Posisikan sertifikat di dalam frame dan pastikan semua teks dapat terbaca dengan jelas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                
                // Capture button
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Color(0xFFDC3545), width: 4),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Color(0xFFDC3545),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC3545)),
              ),
            ),
    );
  }
}