import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dcc_module/presentation/base/dcc_base_view.dart';
import 'package:dcc_module/presentation/widgets/dcc_custom_app_bar.dart';
import 'package:dcc_module/presentation/widgets/empty_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dcc_module/core/loading_status.dart';
import 'package:dcc_module/presentation/provider/dcc_provider.dart';
import 'package:dcc_module/presentation/provider/dcc_project_provider.dart';
import 'package:dcc_module/presentation/view/document_control_center/widgets/dcc_breadcrumb.dart';
import 'package:dcc_module/presentation/view/document_control_center/widgets/dcc_file_tile.dart';
import 'package:dcc_module/presentation/view/document_control_center/widgets/dcc_folder_tile.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_file_model.dart';
import 'package:dcc_module/presentation/utility/dcc_snackbar.dart';
import 'package:dcc_module/presentation/widgets/dcc_pdf_viewer.dart';
import 'package:dcc_module/presentation/widgets/dcc_image_viewer.dart';
import 'package:dcc_module/presentation/widgets/dcc_google_docs_viewer.dart';
import 'package:dcc_module/presentation/base/dcc_base_need_resume.dart';
import 'package:dcc_module/presentation/utility/dcc_viewer_launcher.dart';
import 'package:go_router/go_router.dart';
// ── Global DCC provider (Main Menu) ──────────────────────
final dccProvider = ChangeNotifierProvider((ref) => DccProvider());

// ── Project DCC provider (Project Menu) ──────────────────
final dccProjectProvider = ChangeNotifierProvider((ref) => DccProjectProvider());

class DccScreen extends ConsumerStatefulWidget {
  /// If [projectId] and [rootFolderId] are provided, the screen operates
  /// in Project Mode using [DccProjectProvider].
  /// Otherwise, it uses the global [DccProvider].
  final int? projectId;
  final int? rootFolderId;
  final bool isFromHome;

  const DccScreen({super.key, this.projectId, this.rootFolderId,this.isFromHome = false});

  @override
  DccResumableState<DccScreen> createState() => _DccScreenState();
}

class _DccScreenState extends DccResumableState<DccScreen> with RouteAware {


  bool get _isProjectMode => widget.projectId != null && widget.rootFolderId != null;


  @override
  void onResume() {

    if(_isProjectMode){
      final provider = ref.read(dccProjectProvider);
      provider.updateFolderStats();
      provider.updateCurrentView();
    }else{
      final provider = ref.read(dccProvider);
      provider.updateFolderStats();
      provider.updateCurrentView();
    }

    super.onResume();
  }

  @override
  Widget build(BuildContext context) {
    if (_isProjectMode) {
      return _DccScreenBody<DccProjectProvider>(
        provider: dccProjectProvider,
        isFromHome: widget.isFromHome,
        initProvider: (provider) {
          provider.initDccForProject(
            projectId: widget.projectId!,
            rootFolderId: widget.rootFolderId!,
          );
        },
      );
    } else {
      return _DccScreenBody<DccProvider>(
        isFromHome: widget.isFromHome,
        provider: dccProvider,
        initProvider: (provider) {
          final state = GoRouterState.of(context);
          final extra = state.extra as Map<String, dynamic>?;
          log("extra____ $extra");
          ///transid is the fileid and transtableid is the folderid
          if(extra != null && extra["transtableid"] != null && extra["transid"] != null){
            if(extra["notificationid"] != null){
              provider.setNotificationId(extra["notificationid"]);
            }else if(extra["notificationId"] != null){
              provider.setNotificationId(extra["notificationId"]);
            }
            provider.navigateToFolderAndFile(int.parse(extra["transtableid"].toString()), int.parse(extra["transid"].toString()));
          }
          provider.silentSync();
          provider.initDcc();
        },
      );
    }
  }
}

/// Generalized DCC screen body that works with any [U extends DccProvider].
class _DccScreenBody<U extends DccProvider> extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<U> provider;
  final void Function(U provider) initProvider;
  final bool isFromHome;

  const _DccScreenBody({
    super.key,
    required this.provider,
    required this.initProvider,
    this.isFromHome = false,
  });

  @override
  ConsumerState<_DccScreenBody<U>> createState() => _DccScreenBodyState<U>();
}

class _DccScreenBodyState<U extends DccProvider> extends ConsumerState<_DccScreenBody<U>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DccBaseView<U>(
      provider: widget.provider,
      initState: (context, provider, ref) {
        widget.initProvider(provider);
      },
      onWillPop: (context) async {
        final provider = ref.read(widget.provider);
        if (_isSearchMode) {
          setState(() => _isSearchMode = false);
          _searchController.clear();
          provider.clearSearch();
          return false;
        }
        if (!provider.isAtRoot) {
          provider.navigateBack();
          return false;
        }
        if (widget.isFromHome) {
           return false;
        }

        return true;
      },
      appBar: DccCustomAppBar(
        useLeading: widget.isFromHome ? false : true,
        onBack: (context) async {
          final provider = ref.read(widget.provider);
          if (_isSearchMode) {
            setState(() => _isSearchMode = false);
            _searchController.clear();
            provider.clearSearch();
            return false;
          }
          if (!provider.isAtRoot) {
            provider.navigateBack();
            return false;
          }
          if (widget.isFromHome) {
            return false;
          }

          return true;
        },
        title: _isSearchMode
            ? _buildSearchField(ref.read(widget.provider))
            : Consumer(
                builder: (context, ref, child) {
                  final provider = ref.watch(widget.provider);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.currentLocationTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!provider.isAtRoot)
                        Text(
                          '${provider.visibleFolders.length} folder${provider.visibleFolders.length != 1 ? 's' : ''}'
                          ' · ${provider.visibleFiles.length} file${provider.visibleFiles.length != 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.titleLarge?.color,
                            fontSize: 11.5,
                          ),
                        ),
                    ],
                  );
                },
              ),
        action: [
          if (!_isSearchMode)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchMode = true;
                  _searchFocusNode.requestFocus();
                });
              },
              icon: Icon(
                Icons.search_rounded,
                color: theme.iconTheme.color?.withOpacity(0.6),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      builder: (context, provider, ref) {
        return Column(
          children: [
            if (provider.breadcrumb.isNotEmpty)
              DccBreadcrumb(
                breadcrumb: provider.breadcrumb,
                onTapBreadcrumb: (index) => provider.navigateToBreadcrumb(index),
                onTapRoot: () => provider.navigateToRoot(),
              ),
            if (provider.isSyncing) _buildSyncBar(theme),
            if (provider.isOffline) _buildOfflineBanner(theme),
            Expanded(
              child: _buildContent(context, provider, theme, isDark),
            ),
            if(widget.isFromHome)
              SizedBox(height: MediaQuery.of(context).size.height*0.1,)
          ],
        );
      },
    );
  }

  Widget _buildSyncButton(DccProvider provider, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: provider.isSyncing ? const Color(0xFF4A6580).withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: provider.isSyncing ? null : () => provider.syncNow(),
        icon: provider.isSyncing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.iconTheme.color?.withOpacity(0.5) ?? Colors.grey,
                  ),
                ),
              )
            : Icon(Icons.sync_rounded, color: theme.iconTheme.color?.withOpacity(0.6), size: 22),
        splashRadius: 20,
      ),
    );
  }

  Widget _buildSyncBar(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF4A6580).withOpacity(0.06),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A6580)),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Syncing documents...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4A6580),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFFF9800).withOpacity(0.08),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 14, color: Color(0xFFFF9800)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are offline. Showing cached documents.',
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFFFF9800),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(DccProvider provider) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: 'Search files...',
        border: InputBorder.none,
        hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            setState(() => _isSearchMode = false);
            _searchController.clear();
            provider.clearSearch();
          },
        ),
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: (value) {
        int rootId = 0;
        if (provider is DccProjectProvider) {
          rootId = provider.rootFolderId ?? 0;
        }
        provider.searchFile(
          searchRootFolderId: rootId,
          searchQuery: value,
        );
      },
    );
  }
  Widget _buildContent(BuildContext context, DccProvider provider, ThemeData theme, bool isDark) {
    final content = _buildMainContent(context, provider, theme, isDark);

    if (!provider.isAtRoot) return content;

    return RefreshIndicator(
      onRefresh: provider.refreshCurrentFolder,
      color: theme.primaryColor,
      child: content,
    );
  }

  Widget _buildMainContent(BuildContext context, DccProvider provider, ThemeData theme, bool isDark) {
    if (provider.loadingStatus.loader == DccLoader.error && provider.allFolders.isEmpty) {
      return EmptyListView(emptyText: 'The document is not yet synchronized. The document list is currently empty.');
    }
    if (provider.isCurrentEmpty && 
        provider.loadingStatus.loader != DccLoader.loading && 
        !provider.isSyncing && 
        !provider.isSilentSyncing) {
      return _buildEmptyState(theme, provider);
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 24),
        children: [
          if (provider.isSearching) ...[
            if (provider.loadingStatus.loader == DccLoader.loading)
              const Center(child: Padding(padding: EdgeInsets.all(20),child: CircularProgressIndicator(),))
            else if (provider.visibleSearchFiles.isEmpty && provider.searchFoldersResult.isEmpty)
              _buildSearchEmptyState(theme)
            else ...[
              if (provider.searchFoldersResult.isNotEmpty) ...[
                _buildSectionHeader(theme, 'Folders', provider.searchFoldersResult.length),
                const SizedBox(height: 8),
                ...provider.searchFoldersResult.map((folder) {
                  final subCount = provider.allFolders.where((f) => f.parentId == folder.id).length;
                  final fileCount = provider.folderFileCounts[folder.id] ?? 0;
                  final location = provider.getLocationPathForFolder(folder.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: DccFolderTile(
                      folder: folder,
                      subfolderCount: subCount,
                      fileCount: fileCount,
                      locationPath: location.isNotEmpty ? location : null,
                      onTap: () {
                        setState(() => _isSearchMode = false);
                        _searchController.clear();
                        provider.commitSearchAndNavigate(folder);
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
              if (provider.visibleSearchFiles.isNotEmpty) ...[
                _buildSectionHeader(theme, 'Documents', provider.visibleSearchFiles.length),
                const SizedBox(height: 8),
                ...provider.visibleSearchFiles.map((file) {
                  final location = provider.getLocationPathForFile(file.folderid);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DccFileTile(
                      file: file,
                      isDownloading: provider.downloadingFileId == file.id,
                      downloadProgress: provider.downloadProgress,
                      locationPath: location.isNotEmpty ? location : null,
                      onTap: () => _onFileTapped(context, provider, file),
                    ),
                  );
                }),
              ],
            ],
          ] else ...[
            if (provider.visibleFolders.isNotEmpty) ...[
              _buildSectionHeader(theme, 'Folders', provider.visibleFolders.length),
              const SizedBox(height: 8),
              ...provider.visibleFolders.map((folder) {
                final subCount = provider.allFolders.where((f) => f.parentId == folder.id).length;
                final fileCount = provider.folderFileCounts[folder.id] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: DccFolderTile(
                    folder: folder,
                    subfolderCount: subCount,
                    fileCount: fileCount,
                    onTap: () => provider.navigateToFolder(folder),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
            if (provider.visibleFiles.isNotEmpty) ...[
              _buildSectionHeader(theme, 'Documents', provider.visibleFiles.length),
              const SizedBox(height: 8),
              ...provider.visibleFiles.map((file) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DccFileTile(
                      file: file,
                      isDownloading: provider.downloadingFileId == file.id,
                      downloadProgress: provider.downloadProgress,
                      onTap: () => _onFileTapped(context, provider, file),
                    ),
                  )),
            ],
          ],
        ],
      );

  }

  Widget _buildSearchEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              'No files matching your search',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor),
            ),
          ],
        ),
      ),
    );
  }

  void _onFileTapped(BuildContext context, DccProvider provider, DccFileModel file) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.chrome_reader_mode_outlined, color: theme.primaryColor, size: 28),
                title: const Text('Open with In-App Viewer'),
                subtitle: const Text('Fast viewing inside the app'),
                titleTextStyle: theme.textTheme.titleLarge,
                subtitleTextStyle: theme.textTheme.titleSmall?.copyWith(
                   fontWeight: FontWeight.w400
                ),
                onTap: () {
                  Navigator.pop(context);
                  _openInAppViewer(provider, context, file);
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.security_rounded, color: theme.primaryColor, size: 28),
              //   title: const Text('Open with Secure Viewer (In-App)'),
              //   subtitle: const Text('High-stability alternative viewer'),
              //   titleTextStyle: theme.textTheme.titleLarge,
              //   subtitleTextStyle: theme.textTheme.titleSmall?.copyWith(
              //       fontWeight: FontWeight.w400
              //   ),
              //   onTap: () {
              //     Navigator.pop(context);
              //     _openSecureViewer(provider, file);
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.open_in_new_rounded, color: theme.primaryColor, size: 28),
                title: const Text('Open with Other Apps'),
                subtitle: const Text('Use specialized system applications'),
                titleTextStyle: theme.textTheme.titleLarge,
                subtitleTextStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w400
                ),
                onTap: () {
                  Navigator.pop(context);
                  provider.openFile(file);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _openInAppViewer(DccProvider provider, BuildContext context, DccFileModel file) {
    final pathOrUrl = file.isDownloaded && file.localPath != null ? file.localPath! : file.physicalFileUrl;
    final name = file.filename;

    switch (file.fileType) {
      case DccFileType.image:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DccImageViewer(urlOrPath: pathOrUrl, fileName: name),
          ),
        );
        break;
      case DccFileType.pdf:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DccPdfViewer(urlOrPath: pathOrUrl, fileName: name),
          ),
        );
      case DccFileType.autocad:
        if (file.physicalFileUrl.isNotEmpty && !provider.isOffline) {
          final cadUrl = DccViewerLauncher.getCadViewerUrl(file.physicalFileUrl);
          DccViewerLauncher.launchInAppViewer(cadUrl);
        } else {
          DccSnackBar().show(context: context, message: 'In-app viewer not available for this file type.');
        }
        break;
      default:
        if (file.physicalFileUrl.isNotEmpty && !provider.isOffline) {
          final officeUrl = DccViewerLauncher.getOfficeViewerUrl(file.physicalFileUrl);
          DccViewerLauncher.launchInAppViewer(officeUrl);
        } else {
          DccSnackBar().show(context: context, message: 'In-app viewer not available for this file type.');
        }
    }
  }

  void _openSecureViewer(DccProvider provider, DccFileModel file) {
    if (file.physicalFileUrl.isEmpty || provider.isOffline) {
      DccSnackBar().show(context: context, message: 'Viewer not available offline.');
      return;
    }

    final officeUrl = DccViewerLauncher.getOfficeViewerUrl(file.physicalFileUrl);
    DccViewerLauncher.launchInAppViewer(officeUrl);
  }

  Widget _buildSectionHeader(ThemeData theme, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, DccProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A6580).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      provider.isAtRoot ? Icons.folder_open_rounded : Icons.insert_drive_file_outlined,
                      size: 36,
                      color: const Color(0xFF4A6580).withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    provider.isAtRoot ? 'No folders found' : 'This folder is empty',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleSmall?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildErrorState(ThemeData theme, DccProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: Colors.amberAccent,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              'The document is not yet synchronized. The document list is currently empty.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
