import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FileUtils {
  static IconData getFileIcon(String extension, bool isDirectory) {
    if (isDirectory) return Icons.folder;
    
    switch (extension.toLowerCase()) {
      // Images
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'svg':
        return Icons.image;
      
      // Videos
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'webm':
        return Icons.video_file;
      
      // Audio
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
      case 'ogg':
      case 'm4a':
      case 'wma':
        return Icons.audio_file;
      
      // Documents
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.fileExcel;
      case 'ppt':
      case 'pptx':
        return FontAwesomeIcons.filePowerpoint;
      case 'txt':
        return Icons.description;
      
      // Archives
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return FontAwesomeIcons.fileZipper;
      
      // Code
      case 'dart':
      case 'java':
      case 'kt':
      case 'swift':
      case 'py':
      case 'js':
      case 'html':
      case 'css':
      case 'json':
      case 'xml':
        return FontAwesomeIcons.fileCode;
      
      // APK
      case 'apk':
        return FontAwesomeIcons.android;
      
      default:
        return Icons.insert_drive_file;
    }
  }

  static Color getFileColor(String extension, bool isDirectory) {
    if (isDirectory) return Colors.amber;
    
    switch (extension.toLowerCase()) {
      // Images
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'svg':
        return Colors.purple;
      
      // Videos
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'webm':
        return Colors.red;
      
      // Audio
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
      case 'ogg':
      case 'm4a':
      case 'wma':
        return Colors.orange;
      
      // Documents
      case 'pdf':
        return Colors.red.shade700;
      case 'doc':
      case 'docx':
        return Colors.blue.shade700;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade700;
      case 'ppt':
      case 'pptx':
        return Colors.deepOrange;
      case 'txt':
        return Colors.grey;
      
      // Archives
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Colors.brown;
      
      // Code
      case 'dart':
        return Colors.blue;
      case 'java':
        return Colors.red.shade700;
      case 'kt':
        return Colors.purple.shade700;
      case 'py':
        return Colors.yellow.shade700;
      case 'js':
        return Colors.yellow.shade800;
      
      // APK
      case 'apk':
        return Colors.green;
      
      default:
        return Colors.blueGrey;
    }
  }

  static Future<bool> deleteFile(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path) == FileSystemEntityType.directory
          ? Directory(path)
          : File(path);
      
      await entity.delete(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> renameFile(String oldPath, String newName) async {
    try {
      final entity = FileSystemEntity.typeSync(oldPath) == FileSystemEntityType.directory
          ? Directory(oldPath)
          : File(oldPath);
      
      final parentPath = oldPath.substring(0, oldPath.lastIndexOf('/'));
      final newPath = '$parentPath/$newName';
      
      await entity.rename(newPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> copyFile(String sourcePath, String destinationPath) async {
    try {
      if (FileSystemEntity.typeSync(sourcePath) == FileSystemEntityType.directory) {
        final sourceDir = Directory(sourcePath);
        final destDir = Directory(destinationPath);
        
        if (!await destDir.exists()) {
          await destDir.create(recursive: true);
        }
        
        await for (final entity in sourceDir.list(recursive: false)) {
          final newPath = '$destinationPath/${entity.path.split('/').last}';
          if (entity is File) {
            await entity.copy(newPath);
          } else if (entity is Directory) {
            await copyFile(entity.path, newPath);
          }
        }
      } else {
        final file = File(sourcePath);
        await file.copy(destinationPath);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> moveFile(String sourcePath, String destinationPath) async {
    try {
      final success = await copyFile(sourcePath, destinationPath);
      if (success) {
        await deleteFile(sourcePath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> createFolder(String path, String folderName) async {
    try {
      final newFolder = Directory('$path/$folderName');
      await newFolder.create(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }
}



