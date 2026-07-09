import 'dart:convert';
import 'dart:typed_data';

import 'package:spendsense/features/backup/domain/backup_exception.dart';
import 'package:spendsense/features/backup/domain/backup_metadata.dart';
import 'package:spendsense/features/backup/engine/backup_crypto.dart';

class BackupFileCodec {
  static Future<Uint8List> encode({
    required DateTime exportedAt,
    required int schemaVersion,
    required Uint8List databaseBytes,
    required String password,
  }) async {
    final payload = jsonEncode({
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'schemaVersion': schemaVersion,
      'databaseBase64': base64Encode(databaseBytes),
    });
    return BackupCrypto.encrypt(
      Uint8List.fromList(utf8.encode(payload)),
      password,
    );
  }

  static Future<({BackupMetadata metadata, Uint8List databaseBytes})> decode({
    required Uint8List fileBytes,
    required String password,
    required String fileName,
  }) async {
    final decrypted = await BackupCrypto.decrypt(
      fileBytes,
      password,
      fileName: fileName,
    );

    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
    } on FormatException {
      throw BackupCorruptFileException(fileName, reason: 'invalid payload');
    }

    final exportedAtRaw = payload['exportedAt'];
    final schemaVersion = payload['schemaVersion'];
    final databaseBase64 = payload['databaseBase64'];

    if (exportedAtRaw is! String ||
        schemaVersion is! int ||
        databaseBase64 is! String) {
      throw BackupCorruptFileException(fileName, reason: 'missing fields');
    }

    final exportedAt = DateTime.tryParse(exportedAtRaw);
    if (exportedAt == null) {
      throw BackupCorruptFileException(fileName, reason: 'invalid export date');
    }

    Uint8List databaseBytes;
    try {
      databaseBytes = Uint8List.fromList(base64Decode(databaseBase64));
    } on FormatException {
      throw BackupCorruptFileException(fileName, reason: 'invalid database data');
    }

    return (
      metadata: BackupMetadata(
        exportedAt: exportedAt.toLocal(),
        schemaVersion: schemaVersion,
      ),
      databaseBytes: databaseBytes,
    );
  }
}
