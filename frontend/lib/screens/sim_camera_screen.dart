import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class SimCameraScreen extends StatefulWidget {
  @override
  _SimCameraScreenState createState() => _SimCameraScreenState();
}

class _SimCameraScreenState extends State<SimCameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    // Timeout fallback
    Future.delayed(Duration(seconds: 10), () {
      if (!_isInitialized && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamera tidak dapat dimuat. Coba lagi.')),
        );
        Navigator.pop(context);
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      if (!Platform.isAndroid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aplikasi hanya mendukung Android')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
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
        'sim_${DateTime.now().millisecondsSinceEpoch}.jpg',
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
          'Foto SIM',
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
                
                // Overlay guide
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.width * 0.55,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                      'Posisikan SIM di dalam kotak putih\nPastikan nomor SIM dan nama dapat terbaca dengan jelas',
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