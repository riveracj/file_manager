import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../providers/file_manager_provider.dart';

class FileOperationsDialog extends StatelessWidget {
  final FileItem file;
  final FileManagerProvider provider;

  const FileOperationsDialog({
    super.key,
    required this.file,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(); // Placeholder for future operations
  }
}




