import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_item.dart';
import '../utils/file_utils.dart';

enum ViewMode { grid, list }
enum SortBy { name, date, size, type }

class FileManagerProvider with ChangeNotifier {
  String _currentPath = '';
  List<FileItem> _files = [];
  List<FileItem> _filteredFiles = [];
  bool _isLoading = false;
  ViewMode _viewMode = ViewMode.list;
  SortBy _sortBy = SortBy.name;
  bool _sortAscending = true;
  String _searchQuery = '';
  List<String> _pathHistory = [];
  StorageInfo? _storageInfo;

  String get currentPath => _currentPath;
  List<FileItem> get files => _filteredFiles;
  bool get isLoading => _isLoading;
  ViewMode get viewMode => _viewMode;
  SortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  String get searchQuery => _searchQuery;
  bool get canGoBack => _pathHistory.isNotEmpty;
  StorageInfo? get storageInfo => _storageInfo;

  Future<void> initialize() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Navigate to root of external storage
        final pathParts = directory.path.split('/');
        final storageIndex = pathParts.indexOf('storage');
        if (storageIndex != -1 && storageIndex + 2 < pathParts.length) {
          _currentPath = '/${pathParts.sublist(1, storageIndex + 3).join('/')}';
        } else {
          _currentPath = directory.path;
        }
        await loadFiles();
        await _loadStorageInfo();
      }
    } catch (e) {
      // Error initializing file manager
    }
  }

  Future<void> loadFiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final directory = Directory(_currentPath);
      if (await directory.exists()) {
        final entities = await directory.list().toList();
        _files = entities
            .map((entity) => FileItem.fromFileSystemEntity(entity))
            .toList();
        
        _applyFilters();
      }
    } catch (e) {
      // Error loading files
      _files = [];
      _filteredFiles = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadStorageInfo() async {
    try {
      // Note: Getting actual storage info requires platform-specific code
      // This is a simplified version
      _storageInfo = StorageInfo(
        name: 'Internal Storage',
        path: _currentPath,
        totalSpace: 64 * 1024 * 1024 * 1024, // 64 GB placeholder
        freeSpace: 32 * 1024 * 1024 * 1024,  // 32 GB placeholder
      );
      notifyListeners();
    } catch (e) {
      // Error loading storage info
    }
  }

  void navigateToDirectory(String path) {
    _pathHistory.add(_currentPath);
    _currentPath = path;
    _searchQuery = '';
    loadFiles();
  }

  void navigateBack() {
    if (_pathHistory.isNotEmpty) {
      _currentPath = _pathHistory.removeLast();
      _searchQuery = '';
      loadFiles();
    }
  }

  void navigateUp() {
    if (_currentPath.isNotEmpty && _currentPath != '/') {
      final parentPath = _currentPath.substring(0, _currentPath.lastIndexOf('/'));
      if (parentPath.isNotEmpty) {
        navigateToDirectory(parentPath);
      }
    }
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSortBy(SortBy sort) {
    if (_sortBy == sort) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = sort;
      _sortAscending = true;
    }
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredFiles = List.from(_files);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredFiles = _filteredFiles
          .where((file) => file.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting
    _filteredFiles.sort((a, b) {
      // Always show directories first
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;

      int comparison = 0;
      switch (_sortBy) {
        case SortBy.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.date:
          comparison = a.lastModified.compareTo(b.lastModified);
          break;
        case SortBy.size:
          comparison = a.size.compareTo(b.size);
          break;
        case SortBy.type:
          comparison = a.extension.compareTo(b.extension);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  Future<bool> deleteFile(FileItem file) async {
    final success = await FileUtils.deleteFile(file.path);
    if (success) {
      await loadFiles();
    }
    return success;
  }

  Future<bool> renameFile(FileItem file, String newName) async {
    final success = await FileUtils.renameFile(file.path, newName);
    if (success) {
      await loadFiles();
    }
    return success;
  }

  Future<bool> createFolder(String folderName) async {
    final success = await FileUtils.createFolder(_currentPath, folderName);
    if (success) {
      await loadFiles();
    }
    return success;
  }

  Future<bool> copyFile(FileItem file, String destinationPath) async {
    final fileName = file.path.split('/').last;
    final fullDestPath = '$destinationPath/$fileName';
    final success = await FileUtils.copyFile(file.path, fullDestPath);
    return success;
  }

  Future<bool> moveFile(FileItem file, String destinationPath) async {
    final fileName = file.path.split('/').last;
    final fullDestPath = '$destinationPath/$fileName';
    final success = await FileUtils.moveFile(file.path, fullDestPath);
    if (success) {
      await loadFiles();
    }
    return success;
  }
}

