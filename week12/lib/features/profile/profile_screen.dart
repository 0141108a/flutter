import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}${Platform.pathSeparator}avatar.jpg');
    await File(picked.path).copy(dest.path);
    await FileImage(dest).evict();
    if (!mounted) return;
    await context.read<SettingsModel>().setAvatar(dest.path);
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The camera is needed to take a photo. '
              'You can still choose one from the gallery.',
            ),
          ),
        );
      case PermissionStatus.restricted:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The camera is restricted on this device.'),
          ),
        );
      case PermissionStatus.permanentlyDenied:
        await _showSettingsDialog();
    }
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera access is off'),
        content: const Text(
          'The system will not ask again. Open the app settings and allow '
          'the camera, or choose a photo from the gallery instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open == true) await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final path = context.select<SettingsModel, String?>((s) => s.avatarPath);
    ImageProvider? image;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) image = FileImage(file);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: image,
              child: image == null
                  ? const Text('ME', style: TextStyle(fontSize: 32))
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
