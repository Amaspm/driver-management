import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final String title;

  const CameraScreen({
    Key? key,
    required this.camera,
    required this.title,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _convertImageToBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _toggleFlash() async {
    try {
      await _initializeControllerFuture;
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await _controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await _initializeControllerFuture;
                            final image = await _controller.takePicture();
                            final base64Image = await _convertImageToBase64(image.path);
                            Navigator.pop(context, base64Image);
                          } catch (e) {
                            print('Error taking picture: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFDC3545),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(30),
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                      ),
                      ElevatedButton(
                        onPressed: _toggleFlash,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFlashOn ? Colors.yellow : Colors.grey,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                        child: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: _isFlashOn ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}