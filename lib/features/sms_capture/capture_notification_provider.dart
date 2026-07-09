import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';

final captureNotificationProvider =
    StateProvider<CaptureNotificationEvent?>((ref) => null);

final reviewedTransactionTapProvider =
    StateProvider<int?>((ref) => null);
