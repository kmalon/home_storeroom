import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _inner = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request..headers.addAll(_headers));
  }
}

class DriveService {
  static const _folderName = 'home_storeroom';
  static const _fileName = 'storeroom.xlsx';
  static const _folderMime = 'application/vnd.google-apps.folder';
  static const _xlsxMime =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  Future<drive.DriveApi> _getApi() async {
    final account = googleSignIn.currentUser;
    if (account == null) throw Exception('Not authenticated');
    final auth = await account.authentication;
    final headers = {'Authorization': 'Bearer ${auth.accessToken}'};
    return drive.DriveApi(_GoogleAuthClient(headers));
  }

  Future<String> _findOrCreateFolder(drive.DriveApi api) async {
    final result = await api.files.list(
      q: "name='$_folderName' and mimeType='$_folderMime' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id)',
    );
    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }
    final folder = await api.files.create(
      drive.File()
        ..name = _folderName
        ..mimeType = _folderMime,
    );
    return folder.id!;
  }

  /// Returns (fileId, isNew)
  Future<(String, bool)> findOrCreateFile() async {
    final api = await _getApi();
    final folderId = await _findOrCreateFolder(api);

    final result = await api.files.list(
      q: "name='$_fileName' and '$folderId' in parents and trashed=false",
      spaces: 'drive',
      $fields: 'files(id)',
    );
    if (result.files != null && result.files!.isNotEmpty) {
      return (result.files!.first.id!, false);
    }

    final file = await api.files.create(
      drive.File()
        ..name = _fileName
        ..parents = [folderId]
        ..mimeType = _xlsxMime,
    );
    return (file.id!, true);
  }

  Future<Uint8List> downloadFile(String fileId) async {
    final api = await _getApi();
    final response = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final chunks = <int>[];
    await for (final chunk in response.stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  Future<void> uploadFile(String fileId, Uint8List bytes) async {
    final api = await _getApi();
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: _xlsxMime,
    );
    await api.files.update(
      drive.File(),
      fileId,
      uploadMedia: media,
    );
  }
}
