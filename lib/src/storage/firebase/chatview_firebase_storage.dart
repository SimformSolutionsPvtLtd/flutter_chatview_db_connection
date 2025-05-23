import 'dart:io';

import 'package:chatview_utils/chatview_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../extensions.dart';
import '../storage_service.dart';
import 'chatview_firebase_storage_refs.dart';

/// provides methods for uploading and deleting images from Firebase Storage.
final class ChatViewFirebaseStorage implements StorageService {
  static final _firebaseStorage = FirebaseStorage.instance.ref();

  Reference _imageRef(String chatId) =>
      _firebaseStorage.child(ChatViewFirebaseStorageRefs.getImageRef(chatId));

  Reference _voiceRef(String chatId) =>
      _firebaseStorage.child(ChatViewFirebaseStorageRefs.getVoiceRef(chatId));

  @override
  Future<String?> uploadMedia({
    required int retry,
    required Message message,
    required String chatId,
    String? path,
    String? fileName,
  }) async {
    switch (message.messageType) {
      case MessageType.image:
        return _uploadFile(
          retry: retry,
          message: message,
          ref: _imageRef(chatId),
          uploadPath: path,
          fileName: fileName,
        );
      case MessageType.voice:
        return _uploadFile(
          retry: retry,
          message: message,
          ref: _voiceRef(chatId),
          uploadPath: path,
          fileName: fileName,
        );
      case MessageType.text || MessageType.custom:
        return null;
    }
  }

  @override
  Future<bool> deleteMedia(Message message) async {
    switch (message.messageType) {
      case MessageType.image:
        return _deleteFile(message.message.firebaseStorageDocumentPath);
      case MessageType.voice:
        return _deleteFile(message.message.firebaseStorageDocumentPath);
      case MessageType.text || MessageType.custom:
        return false;
    }
  }

  /// {@template chatview_connect.StorageService.getFileName}
  /// by default it will follow below pattern from [Message].
  /// Example:
  /// ```dart
  /// Message(
  ///   id: '1',
  ///   message: "Hi!",
  ///   createdAt: DateTime(2024, 6, 25),
  ///   sendBy: '1',
  ///   status: MessageStatus.read,
  /// );
  /// Pattern: 'id_sendBy_createdAtTimestamp_fileName.fileExtension'
  /// Output: 1_1_1719253800000000_my_image.jpg
  /// ```
  /// {@endtemplate}
  String _getFileName(Message message) {
    final fileExtension = path.extension(message.message);
    final fileName = path.basenameWithoutExtension(message.message);
    final timestamp = message.createdAt.microsecondsSinceEpoch;
    final messageIdWithSendBy = '${message.id}_${message.sentBy}';
    return '${messageIdWithSendBy}_${timestamp}_$fileName$fileExtension';
  }

  Future<String?> _uploadFile({
    required int retry,
    required Message message,
    required Reference ref,
    String? filePath,
    String? uploadPath,
    String? fileName,
  }) async {
    try {
      final name = fileName ?? _getFileName(message);
      final directoryPath = uploadPath == null ? name : '$uploadPath/$name';
      final fileRef = ref.child(directoryPath);
      // TODO(YASH): audio_waveforms currently supports only Android & iOS.
      //  On the web, only image upload is handled.
      //  Update this once audio_waveforms adds web support.
      if (message.messageType.isImage && kIsWeb) {
        final bytes = await http.readBytes(Uri.parse(message.message));
        await fileRef.putData(bytes);
        return fileRef.getDownloadURL();
      } else {
        final file = File(filePath ?? message.message);
        final isFileExist = file.existsSync();
        if (!isFileExist) throw Exception('File Not Exist!');
        await fileRef.putFile(file);
        return fileRef.getDownloadURL();
      }
    } catch (_) {
      if (retry == 0) rethrow;
      return _uploadFile(
        retry: --retry,
        ref: ref,
        message: message,
        filePath: filePath,
        uploadPath: uploadPath,
        fileName: fileName,
      );
    }
  }

  Future<bool> _deleteFile(String? path) async {
    if (path == null) {
      throw Exception('chatview: Unable to get path from message');
    }
    await _firebaseStorage.child(path).delete();
    return true;
  }

  @override
  Future<bool> deleteAllMedia(String chatId) async {
    final values = await Future.wait([
      _imageRef(chatId)
          .listAll()
          .then((value) => _deleteFromReferences(value.items)),
      _voiceRef(chatId)
          .listAll()
          .then((value) => _deleteFromReferences(value.items)),
    ]);

    final isImagesDeleted = values.firstOrNull ?? true;
    final isVoicesDeleted = values.lastOrNull ?? true;
    return isImagesDeleted && isVoicesDeleted;
  }

  Future<bool> _deleteFromReferences(List<Reference> references) async {
    if (references.isEmpty) return true;
    final messagesLength = references.length;
    await Future.wait([
      for (var i = 0; i < messagesLength; i++) references[i].delete(),
    ]);
    return true;
  }
}
