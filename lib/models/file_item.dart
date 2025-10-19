import 'dart:io';
import 'package:intl/intl.dart';

class FileItem {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime lastModified;
  final FileSystemEntityType type;

  FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.lastModified,
    required this.type,
  });

  factory FileItem.fromFileSystemEntity(FileSystemEntity entity) {
    final stat = entity.statSync();
    return FileItem(
      name: entity.path.split('/').last,
      path: entity.path,
      isDirectory: entity is Directory,
      size: stat.size,
      lastModified: stat.modified,
      type: stat.type,
    );
  }

  String get formattedSize {
    if (isDirectory) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy HH:mm').format(lastModified);
  }

  String get extension {
    if (isDirectory) return '';
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  String get fileType {
    if (isDirectory) return 'Folder';
    
    final ext = extension;
    if (ext.isEmpty) return 'File';
    
    // Image formats
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'].contains(ext)) {
      return 'Image';
    }
    // Video formats
    if (['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm'].contains(ext)) {
      return 'Video';
    }
    // Audio formats
    if (['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma'].contains(ext)) {
      return 'Audio';
    }
    // Document formats
    if (['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'].contains(ext)) {
      return 'Document';
    }
    // Archive formats
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      return 'Archive';
    }
    // Code formats
    if (['dart', 'java', 'kt', 'swift', 'py', 'js', 'html', 'css', 'json', 'xml'].contains(ext)) {
      return 'Code';
    }
    // APK
    if (ext == 'apk') return 'App';
    
    return ext.toUpperCase();
  }
}

class StorageInfo {
  final String name;
  final String path;
  final int totalSpace;
  final int freeSpace;

  StorageInfo({
    required this.name,
    required this.path,
    required this.totalSpace,
    required this.freeSpace,
  });

  int get usedSpace => totalSpace - freeSpace;
  
  double get usedPercentage => totalSpace > 0 ? (usedSpace / totalSpace) : 0.0;

  String get formattedTotal {
    return _formatBytes(totalSpace);
  }

  String get formattedUsed {
    return _formatBytes(usedSpace);
  }

  String get formattedFree {
    return _formatBytes(freeSpace);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}




