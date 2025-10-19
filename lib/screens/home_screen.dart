import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FileBrowserScreen(),
            ),
          );
        },
        icon: const Icon(Icons.folder),
        label: const Text('Browse Files'),
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
      _QuickAccessItem(
        icon: Icons.music_note,
        label: 'Music',
        color: Colors.pink,
        path: '/storage/emulated/0/Music',
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
        onTap: () {
          context.read<FileManagerProvider>().navigateToDirectory(item.path);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FileBrowserScreen(),
            ),
          );
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
          // TODO: Implement category filtering
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${category.label} filter coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
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




