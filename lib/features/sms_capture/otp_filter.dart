final _otpPattern = RegExp(r'\b(otp|one[\s-]?time[\s-]?password)\b', caseSensitive: false);

bool isOtpSms(String sms) => _otpPattern.hasMatch(sms);
