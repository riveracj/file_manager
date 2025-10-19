import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Check Android version
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        // Android 13+
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        final audio = await Permission.audio.request();
        
        return photos.isGranted && videos.isGranted && audio.isGranted;
      } else if (androidInfo >= 30) {
        // Android 11-12
        final manageStorage = await Permission.manageExternalStorage.request();
        return manageStorage.isGranted;
      } else {
        // Android 10 and below
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    }
    return true;
  }

  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        return await Permission.photos.isGranted &&
               await Permission.videos.isGranted &&
               await Permission.audio.isGranted;
      } else if (androidInfo >= 30) {
        return await Permission.manageExternalStorage.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return true;
  }

  static Future<int> _getAndroidVersion() async {
    // This is a simplified version. In production, you'd use device_info_plus
    return 33; // Assume Android 13+ for now
  }
}




