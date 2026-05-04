import 'dart:async';
import 'dart:isolate';

/// ╔═══════════════════════════════════════════════════════════════════╗
/// ║            DCC ISOLATE-BASED SYNC — BLUEPRINT                    ║
/// ║                                                                   ║
/// ║  This is a reference implementation for Dart Isolate-based sync.  ║
/// ╚═══════════════════════════════════════════════════════════════════╝

class DccSyncRequest {
  final List<Map<String, dynamic>> serverFoldersRaw;
  final List<Map<String, dynamic>> serverFilesRaw;
  final List<Map<String, dynamic>> localFoldersRaw;
  final List<Map<String, dynamic>> localFilesRaw;

  DccSyncRequest({
    required this.serverFoldersRaw,
    required this.serverFilesRaw,
    required this.localFoldersRaw,
    required this.localFilesRaw,
  });
}

class DccSyncDiffResult {
  final List<Map<String, dynamic>> newFiles;
  final List<Map<String, dynamic>> updatedFiles;
  final List<int> deletedFileIds;
  final List<Map<String, dynamic>> newFolders;
  final List<int> deletedFolderIds;

  DccSyncDiffResult({
    required this.newFiles,
    required this.updatedFiles,
    required this.deletedFileIds,
    required this.newFolders,
    required this.deletedFolderIds,
  });

  bool get hasChanges =>
      newFiles.isNotEmpty ||
      updatedFiles.isNotEmpty ||
      deletedFileIds.isNotEmpty ||
      newFolders.isNotEmpty ||
      deletedFolderIds.isNotEmpty;
}

void _dccSyncIsolateEntryPoint(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is DccSyncRequest) {
      final result = _performDccDiff(message);
      mainSendPort.send(result);
    }
  });
}

DccSyncDiffResult _performDccDiff(DccSyncRequest request) {
  final serverFileMap = {for (var file in request.serverFilesRaw) file['id'] as int: file};
  final localFileMap = {for (var file in request.localFilesRaw) file['id'] as int: file};

  final newFiles = request.serverFilesRaw.where((f) => !localFileMap.containsKey(f['id'])).toList();
  final updatedFiles = request.serverFilesRaw.where((f) {
    if (!localFileMap.containsKey(f['id'])) return false;
    return f['currentversionno'] != localFileMap[f['id']]!['currentversionno'];
  }).toList();
  final deletedFileIds = localFileMap.keys.where((id) => !serverFileMap.containsKey(id)).toList();

  final serverFolderIds = request.serverFoldersRaw.map((f) => f['id'] as int).toSet();
  final localFolderIds = request.localFoldersRaw.map((f) => f['id'] as int).toSet();

  final newFolders = request.serverFoldersRaw.where((f) => !localFolderIds.contains(f['id'])).toList();
  final deletedFolderIds = localFolderIds.difference(serverFolderIds).toList();

  return DccSyncDiffResult(
    newFiles: newFiles,
    updatedFiles: updatedFiles,
    deletedFileIds: deletedFileIds,
    newFolders: newFolders,
    deletedFolderIds: deletedFolderIds,
  );
}

class DccIsolateSyncDispatcher {
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  final _resultCompleter = <Completer<DccSyncDiffResult>>[];

  Future<void> init() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_dccSyncIsolateEntryPoint, receivePort.sendPort);

    final completer = Completer<SendPort>();
    receivePort.listen((message) {
      if (message is SendPort) {
        completer.complete(message);
      } else if (message is DccSyncDiffResult) {
        if (_resultCompleter.isNotEmpty) {
          _resultCompleter.removeAt(0).complete(message);
        }
      }
    });

    _isolateSendPort = await completer.future;
  }

  Future<DccSyncDiffResult> computeDiff(DccSyncRequest request) {
    assert(_isolateSendPort != null, 'Call init() first');
    final completer = Completer<DccSyncDiffResult>();
    _resultCompleter.add(completer);
    _isolateSendPort!.send(request);
    return completer.future;
  }

  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isolateSendPort = null;
  }
}
