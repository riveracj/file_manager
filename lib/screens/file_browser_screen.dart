import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../models/file_item.dart';
import '../providers/file_manager_provider.dart';
import '../utils/file_utils.dart';

class FileBrowserScreen extends StatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FileManagerProvider>();

    return PopScope(
      canPop: !provider.canGoBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && provider.canGoBack) {
          provider.navigateBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search files...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    provider.search(value);
                  },
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Files', style: TextStyle(fontSize: 20)),
                    Text(
                      _getCurrentFolderName(provider.currentPath),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
          actions: [
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    provider.search('');
                  });
                },
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              PopupMenuButton<ViewMode>(
                icon: Icon(
                  provider.viewMode == ViewMode.list
                      ? Icons.grid_view
                      : Icons.list,
                ),
                onSelected: (mode) {
                  provider.setViewMode(mode);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ViewMode.list,
                    child: Row(
                      children: [
                        Icon(Icons.list),
                        SizedBox(width: 8),
                        Text('List View'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: ViewMode.grid,
                    child: Row(
                      children: [
                        Icon(Icons.grid_view),
                        SizedBox(width: 8),
                        Text('Grid View'),
                      ],
                    ),
                  ),
                ],
              ),
              PopupMenuButton<SortBy>(
                icon: const Icon(Icons.sort),
                onSelected: (sortBy) {
                  provider.setSortBy(sortBy);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: SortBy.name,
                    child: Row(
                      children: [
                        const Icon(Icons.sort_by_alpha),
                        const SizedBox(width: 8),
                        const Text('Name'),
                        if (provider.sortBy == SortBy.name)
                          Icon(
                            provider.sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortBy.date,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8),
                        const Text('Date'),
                        if (provider.sortBy == SortBy.date)
                          Icon(
                            provider.sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortBy.size,
                    child: Row(
                      children: [
                        const Icon(Icons.data_usage),
                        const SizedBox(width: 8),
                        const Text('Size'),
                        if (provider.sortBy == SortBy.size)
                          Icon(
                            provider.sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortBy.type,
                    child: Row(
                      children: [
                        const Icon(Icons.category),
                        const SizedBox(width: 8),
                        const Text('Type'),
                        if (provider.sortBy == SortBy.type)
                          Icon(
                            provider.sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.create_new_folder),
                onPressed: () => _showCreateFolderDialog(context, provider),
                tooltip: 'Create Folder',
              ),
            ],
          ],
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.files.isEmpty
                ? _buildEmptyState(context)
                : provider.viewMode == ViewMode.list
                    ? _buildListView(provider)
                    : _buildGridView(provider),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No files found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(FileManagerProvider provider) {
    return ListView.builder(
      itemCount: provider.files.length,
      itemBuilder: (context, index) {
        final file = provider.files[index];
        return _buildListItem(file, provider);
      },
    );
  }

  Widget _buildGridView(FileManagerProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: provider.files.length,
      itemBuilder: (context, index) {
        final file = provider.files[index];
        return _buildGridItem(file, provider);
      },
    );
  }

  Widget _buildListItem(FileItem file, FileManagerProvider provider) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: FileUtils.getFileColor(file.extension, file.isDirectory)
            .withOpacity(0.2),
        child: Icon(
          FileUtils.getFileIcon(file.extension, file.isDirectory),
          color: FileUtils.getFileColor(file.extension, file.isDirectory),
          size: 24,
        ),
      ),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        file.isDirectory
            ? 'Folder • ${file.formattedDate}'
            : '${file.formattedSize} • ${file.formattedDate}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showFileOptions(context, file, provider),
      ),
      onTap: () => _handleFileTap(file, provider),
    );
  }

  Widget _buildGridItem(FileItem file, FileManagerProvider provider) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () => _handleFileTap(file, provider),
        onLongPress: () => _showFileOptions(context, file, provider),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FileUtils.getFileIcon(file.extension, file.isDirectory),
              size: 48,
              color: FileUtils.getFileColor(file.extension, file.isDirectory),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (!file.isDirectory)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  file.formattedSize,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleFileTap(FileItem file, FileManagerProvider provider) {
    if (file.isDirectory) {
      provider.navigateToDirectory(file.path);
    } else {
      _openFile(file);
    }
  }

  Future<void> _openFile(FileItem file) async {
    try {
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open file: ${result.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showFileOptions(BuildContext context, FileItem file, FileManagerProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FileOptionsBottomSheet(
        file: file,
        provider: provider,
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, FileManagerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(provider: provider),
    );
  }

  String _getCurrentFolderName(String path) {
    if (path.isEmpty) return '/';
    final parts = path.split('/');
    return parts.last.isEmpty ? '/' : parts.last;
  }
}

class FileOptionsBottomSheet extends StatelessWidget {
  final FileItem file;
  final FileManagerProvider provider;

  const FileOptionsBottomSheet({
    super.key,
    required this.file,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: FileUtils.getFileColor(file.extension, file.isDirectory)
                  .withOpacity(0.2),
              child: Icon(
                FileUtils.getFileIcon(file.extension, file.isDirectory),
                color: FileUtils.getFileColor(file.extension, file.isDirectory),
              ),
            ),
            title: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(file.fileType),
          ),
          const Divider(),
          if (!file.isDirectory)
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Open'),
              onTap: () async {
                Navigator.pop(context);
                await OpenFilex.open(file.path);
              },
            ),
          if (!file.isDirectory)
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () async {
                Navigator.pop(context);
                await Share.shareXFiles([XFile(file.path)]);
              },
            ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(context);
              _showRenameDialog(context, file, provider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Details'),
            onTap: () {
              Navigator.pop(context);
              _showFileDetails(context, file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, file, provider);
            },
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, FileItem file, FileManagerProvider provider) {
    final controller = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != file.name) {
                final success = await provider.renameFile(file, newName);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Renamed successfully' : 'Failed to rename'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FileItem file, FileManagerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await provider.deleteFile(file);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Deleted successfully' : 'Failed to delete'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFileDetails(BuildContext context, FileItem file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name:', file.name),
            _buildDetailRow('Type:', file.fileType),
            if (!file.isDirectory) _buildDetailRow('Size:', file.formattedSize),
            _buildDetailRow('Modified:', file.formattedDate),
            _buildDetailRow('Path:', file.path, isPath: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPath = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: isPath ? 11 : 14),
            maxLines: isPath ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class CreateFolderDialog extends StatelessWidget {
  final FileManagerProvider provider;
  final TextEditingController _controller = TextEditingController();

  CreateFolderDialog({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Folder'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Folder name',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.folder),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final folderName = _controller.text.trim();
            if (folderName.isNotEmpty) {
              final success = await provider.createFolder(folderName);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Folder created successfully' : 'Failed to create folder',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

