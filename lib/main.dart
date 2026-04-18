import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'dart:io';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const NagrikAIApp());
}

class NagrikAIApp extends StatelessWidget {
  const NagrikAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ReportScreen(),
    );
  }
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  CameraController? controller;
  XFile? imageFile;
  String status = "Ready to capture";
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.medium);
    controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _submitReport() async {
    if (imageFile == null) return;

    setState(() {
      isUploading = true;
      status = "Fetching Location & Uploading...";
    });

    try {
      // 1. Get Location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // 2. Prepare Data
      FormData formData = FormData.fromMap({
        "lat": position.latitude.toString(),
        "long": position.longitude.toString(),
        "photo": await MultipartFile.fromFile(imageFile!.path, filename: "report.jpg"),
      });

      // 3. Send to Nidhi's Backend
      // Nidhi, yahan apna IPv4 address daalo (e.g., http://192.168.1.5:8000)
      var response = await Dio().post("http://127.0.0.1:8000/submit-complaint", data: formData);

      setState(() {
        status = "AI Analysis: ${response.data['ai_analysis']}";
      });
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("NagrikAI - Report Issue")),
      body: Column(
        children: [
          Expanded(child: CameraPreview(controller!)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (isUploading) const LinearProgressIndicator(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  imageFile = await controller!.takePicture();
                  setState(() { status = "Photo Captured!"; });
                },
                child: const Text("Capture"),
              ),
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text("Submit to AI"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}