import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PhotoCameraScreen extends StatefulWidget {
  @override
  _PhotoCameraScreenState createState() => _PhotoCameraScreenState();
}

class _PhotoCameraScreenState extends State<PhotoCameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Use front camera for selfie if available
        CameraDescription selectedCamera = cameras[0];
        for (var camera in cameras) {
          if (camera.lensDirection == CameraLensDirection.front) {
            selectedCamera = camera;
            break;
          }
        }
        
        _controller = CameraController(
          selectedCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        try {
          await _controller!.setFlashMode(_flashMode);
        } catch (e) {
          print('Flash not supported: $e');
          // Flash not supported, continue without it
        }
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kamera tidak tersedia')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengakses kamera')),
        );
        Navigator.pop(context);
      }
    }
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
    if (!_controller!.value.isInitialized || _isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final directory = await getTemporaryDirectory();
      final imagePath = path.join(
        directory.path,
        'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile picture = await _controller!.takePicture();
      await picture.saveTo(imagePath);

      Navigator.pop(context, File(imagePath));
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto')),
      );
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
          'Foto Diri',
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
                
                // Overlay guide for face
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(20),
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
                      'Posisikan wajah di dalam kotak putih\\nPastikan wajah terlihat jelas dan tidak kabur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCapturing ? Colors.grey : Colors.white,
                          border: Border.all(color: Colors.grey.shade300, width: 4),
                        ),
                        child: _isCapturing
                            ? Center(child: CircularProgressIndicator())
                            : Icon(Icons.camera_alt, size: 40, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Memuat kamera...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}