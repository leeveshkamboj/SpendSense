import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/linking/data/linking_repository.dart';
import 'package:spendsense/features/location/data/geolocation_service.dart';
import 'package:spendsense/features/location/data/sms_location_capture.dart';
import 'package:spendsense/features/location/location_permission_gateway.dart';
import 'package:spendsense/features/merchants/data/merchant_repository.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_service.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class SmsCaptureRuntime {
  SmsCaptureRuntime._({
    required AppDatabase database,
    required this.service,
    required CaptureNotificationService notifications,
    required bool ownsDatabase,
  })  : _database = database,
        _ownsDatabase = ownsDatabase;

  final AppDatabase _database;
  final SmsCaptureService service;
  final bool _ownsDatabase;

  AppDatabase get database => _database;

  static SmsCaptureRuntime? _cached;
  static Future<SmsCaptureRuntime>? _opening;

  static Future<SmsCaptureRuntime> open() {
    final cached = _cached;
    if (cached != null) {
      return Future.value(cached);
    }

    return _opening ??= _create().then((runtime) {
      _cached = runtime;
      return runtime;
    });
  }

  static Future<SmsCaptureRuntime> _create() async {
    final database = AppDatabase();
    final notifications = await CaptureNotificationService.create();
    final service = _buildService(database, notifications);
    return SmsCaptureRuntime._(
      database: database,
      service: service,
      notifications: notifications,
      ownsDatabase: true,
    );
  }

  static SmsCaptureRuntime testing({
    required AppDatabase database,
    required SmsCaptureService service,
    required CaptureNotificationService notifications,
  }) {
    return SmsCaptureRuntime._(
      database: database,
      service: service,
      notifications: notifications,
      ownsDatabase: false,
    );
  }

  static SmsCaptureService _buildService(
    AppDatabase database,
    CaptureNotificationService notifications,
  ) {
    final creditCards = CreditCardRepository(database);
    final cardTransactions = CardTransactionRepository(database);
    final bankAccounts = BankAccountRepository(database);
    final bankAccountTransactions = BankAccountTransactionRepository(database);
    final permissionGateway = PlatformLocationPermissionGateway();
    final locationCapture = SmsLocationCapture(
      permissionGateway: permissionGateway,
      geolocation: GeolocationService(permissionGateway: permissionGateway),
    );

    return SmsCaptureService(
      creditCards: creditCards,
      cardTransactions: cardTransactions,
      bankAccounts: bankAccounts,
      bankAccountTransactions: bankAccountTransactions,
      merchants: MerchantRepository(database),
      tags: TagRepository(database),
      linking: LinkingRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: cardTransactions,
      ),
      onCaptured: notifications.showCapture,
      onManualAddSuggested: (_) => notifications.showManualAddSuggestion(),
      resolveLocation: locationCapture.captureSerialized,
    );
  }

  Future<void> markReviewed({
    required int transactionId,
    required bool isBankAccount,
  }) async {
    if (isBankAccount) {
      await BankAccountTransactionRepository(_database).markReviewed(
        transactionId,
      );
      return;
    }

    await CardTransactionRepository(_database).markReviewed(transactionId);
  }

  Future<void> close() async {
    if (!_ownsDatabase) {
      return;
    }

    _cached = null;
    _opening = null;
    await _database.close();
  }
}
