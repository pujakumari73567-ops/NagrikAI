import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

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
      theme: ThemeData(
        primaryColor: Colors.green[700],
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
      ),
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
    if (imageFile == null) {
      setState(() => status = "Please capture a photo first!");
      return;
    }

    setState(() {
      isUploading = true;
      status = "Fetching Location & Uploading...";
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => status = "Location permission denied");
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      FormData formData = FormData.fromMap({
        "lat": position.latitude.toString(),
        "long": position.longitude.toString(),
        "photo": await MultipartFile.fromFile(imageFile!.path, filename: "report.jpg"),
      });

      String backendUrl = "192.168.1.2/submit"; 
      var response = await Dio().post(backendUrl, data: formData);

      setState(() => status = "Success! Data sent to Dashboard.");
    } catch (e) {
      setState(() => status = "Error: $e");
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("NagrikAI - Snap & Report"),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          Expanded(child: CameraPreview(controller!)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          if (isUploading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Capture"),
                  onPressed: () async {
                    imageFile = await controller!.takePicture();
                    setState(() => status = "Photo Captured! Ready to submit.");
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text("Submit to AI"),
                  onPressed: _submitReport,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}