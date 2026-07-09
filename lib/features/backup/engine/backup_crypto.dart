import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:spendsense/features/backup/domain/backup_exception.dart';

class BackupCrypto {
  static const _pbkdf2Iterations = 100000;
  static const _macLength = 16;
  static const _nonceLength = 12;
  static const _saltLength = 16;

  static Future<Uint8List> encrypt(Uint8List plaintext, String password) async {
    final salt = _randomBytes(_saltLength);
    final secretKey = await _deriveKey(password, salt);
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final box = await algorithm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: nonce,
    );

    final output = BytesBuilder();
    output.add(utf8.encode('SSB1'));
    output.addByte(1);
    output.add(salt);
    output.add(box.nonce);
    output.add(box.mac.bytes);
    output.add(box.cipherText);
    return output.toBytes();
  }

  static Future<Uint8List> decrypt(
    Uint8List fileBytes,
    String password, {
    required String fileName,
  }) async {
    if (fileBytes.length < 4 + 1 + _saltLength + _nonceLength + _macLength) {
      throw BackupCorruptFileException(fileName, reason: 'file is too short');
    }

    final magic = utf8.decode(fileBytes.sublist(0, 4));
    if (magic != 'SSB1') {
      throw BackupCorruptFileException(fileName, reason: 'invalid file header');
    }

    final version = fileBytes[4];
    if (version != 1) {
      throw BackupCorruptFileException(fileName, reason: 'unsupported version');
    }

    var offset = 5;
    final salt = fileBytes.sublist(offset, offset + _saltLength);
    offset += _saltLength;
    final nonce = fileBytes.sublist(offset, offset + _nonceLength);
    offset += _nonceLength;
    final mac = Mac(fileBytes.sublist(offset, offset + _macLength));
    offset += _macLength;
    final cipherText = fileBytes.sublist(offset);

    final secretKey = await _deriveKey(password, salt);
    final algorithm = AesGcm.with256bits();

    try {
      final decrypted = await algorithm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: secretKey,
      );
      return Uint8List.fromList(decrypted);
    } on SecretBoxAuthenticationError {
      throw BackupWrongPasswordException(fileName);
    }
  }

  static Future<SecretKey> _deriveKey(String password, Uint8List salt) {
    return Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pbkdf2Iterations,
      bits: 256,
    ).deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}
