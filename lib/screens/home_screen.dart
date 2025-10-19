import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_filex/open_filex.dart';
import '../providers/file_manager_provider.dart';
import '../utils/permission_helper.dart';
import 'file_browser_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPermission = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await PermissionHelper.hasStoragePermission();
    setState(() {
      _hasPermission = hasPermission;
      _isCheckingPermission = false;
    });

    if (hasPermission) {
      if (mounted) {
        await context.read<FileManagerProvider>().initialize();
      }
    }
  }

  Future<void> _requestPermission() async {
    final granted = await PermissionHelper.requestStoragePermission();
    setState(() {
      _hasPermission = granted;
    });

    if (granted && mounted) {
      await context.read<FileManagerProvider>().initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  'Storage Permission Required',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'File Manager Pro needs permission to access your files and folders.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.check),
                  label: const Text('Grant Permission'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('File Manager Pro'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showAboutDialog(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStorageCard(context),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Access',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickAccessGrid(context),
                  const SizedBox(height: 24),
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoriesGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context) {
    final storageInfo = context.watch<FileManagerProvider>().storageInfo;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Internal Storage',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (storageInfo != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: storageInfo.usedPercentage,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Used',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        storageInfo.formattedUsed,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Free',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        storageInfo.formattedFree,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        storageInfo.formattedTotal,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final items = [
      _QuickAccessItem(
        icon: Icons.folder_open,
        label: 'Browse Files',
        color: Colors.green,
        path: '/storage/emulated/0',
      ),
      _QuickAccessItem(
        icon: Icons.download,
        label: 'Downloads',
        color: Colors.blue,
        path: '/storage/emulated/0/Download',
      ),
      _QuickAccessItem(
        icon: Icons.camera_alt,
        label: 'Camera',
        color: Colors.purple,
        path: '/storage/emulated/0/DCIM/Camera',
      ),
      _QuickAccessItem(
        icon: Icons.folder,
        label: 'Documents',
        color: Colors.orange,
        path: '/storage/emulated/0/Documents',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildQuickAccessCard(context, item);
      },
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, _QuickAccessItem item) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () async {
          final provider = context.read<FileManagerProvider>();
          
          // Check if directory exists
          try {
            final dir = Directory(item.path);
            if (await dir.exists()) {
              provider.navigateToDirectory(item.path);
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FileBrowserScreen(),
                  ),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.label} folder not found'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cannot access folder'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 40,
                color: item.color,
              ),
              const SizedBox(height: 12),
              Text(
                item.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final categories = [
      _CategoryItem(
        icon: FontAwesomeIcons.image,
        label: 'Images',
        color: Colors.purple,
        extensions: ['jpg', 'jpeg', 'png', 'gif'],
      ),
      _CategoryItem(
        icon: FontAwesomeIcons.video,
        label: 'Videos',
        color: Colors.red,
        extensions: ['mp4', 'avi', 'mkv'],
      ),
      _CategoryItem(
        icon: FontAwesomeIcons.music,
        label: 'Audio',
        color: Colors.orange,
        extensions: ['mp3', 'wav', 'aac'],
      ),
      _CategoryItem(
        icon: FontAwesomeIcons.fileLines,
        label: 'Documents',
        color: Colors.blue,
        extensions: ['pdf', 'doc', 'txt'],
      ),
      _CategoryItem(
        icon: FontAwesomeIcons.fileZipper,
        label: 'Archives',
        color: Colors.brown,
        extensions: ['zip', 'rar', '7z'],
      ),
      _CategoryItem(
        icon: FontAwesomeIcons.android,
        label: 'Apps',
        color: Colors.green,
        extensions: ['apk'],
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, _CategoryItem category) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {
          _showCategoryFiles(context, category);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              category.icon,
              size: 32,
              color: category.color,
            ),
            const SizedBox(height: 8),
            Text(
              category.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFiles(BuildContext context, _CategoryItem category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return CategoryFilesView(
            category: category,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'File Manager Pro',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.folder, size: 48),
      children: [
        const Text(
          'A powerful and elegant file manager for Android.',
        ),
      ],
    );
  }
}

class _QuickAccessItem {
  final IconData icon;
  final String label;
  final Color color;
  final String path;

  _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.path,
  });
}

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  final List<String> extensions;

  _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.extensions,
  });
}

class CategoryFilesView extends StatefulWidget {
  final _CategoryItem category;
  final ScrollController scrollController;

  const CategoryFilesView({
    super.key,
    required this.category,
    required this.scrollController,
  });

  @override
  State<CategoryFilesView> createState() => _CategoryFilesViewState();
}

class _CategoryFilesViewState extends State<CategoryFilesView> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scanForFiles();
  }

  Future<void> _scanForFiles() async {
    setState(() => _isLoading = true);
    
    final List<FileSystemEntity> foundFiles = [];
    
    try {
      // Scan common directories for files with matching extensions
      final basePath = '/storage/emulated/0';
      final searchDirs = [
        '$basePath/Download',
        '$basePath/DCIM',
        '$basePath/Pictures',
        '$basePath/Documents',
        '$basePath/Music',
        '$basePath/Movies',
        '$basePath/Downloads',
      ];

      for (final dirPath in searchDirs) {
        try {
          final dir = Directory(dirPath);
          if (await dir.exists()) {
            await for (final entity in dir.list(recursive: true)) {
              if (entity is File) {
                final ext = entity.path.split('.').last.toLowerCase();
                if (widget.category.extensions.contains(ext)) {
                  foundFiles.add(entity);
                }
              }
            }
          }
        } catch (e) {
          // Skip directories we can't access
        }
      }
    } catch (e) {
      // Error scanning
    }

    if (mounted) {
      setState(() {
        _files = foundFiles;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                FaIcon(
                  widget.category.icon,
                  color: widget.category.color,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _isLoading
                            ? 'Scanning...'
                            : '${_files.length} file${_files.length != 1 ? 's' : ''} found',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // File list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _files.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${widget.category.label.toLowerCase()} found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: widget.scrollController,
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          final fileName = file.path.split('/').last;
                          final fileStat = file.statSync();
                          
                          return ListTile(
                            leading: Icon(
                              _getFileIcon(fileName),
                              color: widget.category.color,
                              size: 32,
                            ),
                            title: Text(
                              fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _formatSize(fileStat.size),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () async {
                              // Open file
                              try {
                                await OpenFilex.open(file.path);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cannot open file'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      return Icons.image;
    } else if (['mp4', 'avi', 'mkv', 'mov'].contains(ext)) {
      return Icons.video_file;
    } else if (['mp3', 'wav', 'aac'].contains(ext)) {
      return Icons.audio_file;
    } else if (ext == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx', 'txt'].contains(ext)) {
      return Icons.description;
    } else if (['zip', 'rar', '7z'].contains(ext)) {
      return Icons.folder_zip;
    } else if (ext == 'apk') {
      return Icons.android;
    }
    
    return Icons.insert_drive_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
