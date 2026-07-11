const miscellaneousCategory = 'Miscellaneous';

const _merchantCategoryEntries = <String, String>{
  'ZOMATO': 'Food',
  'SWIGGY': 'Food',
  'DOMINOS': 'Food',
  'DOMINO': 'Food',
  'MCDONALD': 'Food',
  'KFC': 'Food',
  'BLINKIT': 'Groceries',
  'ZEPTO': 'Groceries',
  'INSTAMART': 'Groceries',
  'BIGBASKET': 'Groceries',
  'DMART': 'Groceries',
  'INDIAN OIL': 'Fuel',
  'BPCL': 'Fuel',
  'HPCL': 'Fuel',
  'IOCL': 'Fuel',
  'RELIANCE JIO': 'Utilities',
  'JIOMART': 'Groceries',
  'JIO': 'Utilities',
  'AIRTEL': 'Utilities',
  'VODAFONE': 'Utilities',
  'VI-': 'Utilities',
  'BESCOM': 'Utilities',
  'TATA POWER': 'Utilities',
  'BSES': 'Utilities',
  'NETFLIX': 'Subscription',
  'SPOTIFY': 'Subscription',
  'YOUTUBE': 'Subscription',
  'PRIME VIDEO': 'Subscription',
  'HOTSTAR': 'Subscription',
  'SONYLIV': 'Subscription',
  'APPLE.COM/BILL': 'Subscription',
  'GOOGLE *': 'Subscription',
  'IRCTC': 'Travel',
  'MAKEMYTRIP': 'Travel',
  'GOIBIBO': 'Travel',
  'UBER': 'Travel',
  'OLA': 'Travel',
  'RAPIDO': 'Travel',
  'BOOKMYSHOW': 'Entertainment',
  'PVR': 'Entertainment',
  'INOX': 'Entertainment',
  'APOLLO': 'Medical',
  'PHARMEASY': 'Medical',
  '1MG': 'Medical',
  'NETMEDS': 'Medical',
  'LIC ': 'Insurance',
  'HDFC LIFE': 'Insurance',
  'ICICI PRU': 'Insurance',
  'BAJAJ FINSERV': 'EMI',
  'BAJAJ FINANCE': 'EMI',
  'HOME CREDIT': 'EMI',
  'TVS CREDIT': 'EMI',
};

String lookupMerchantCategory(String rawMerchantName) {
  final normalized = rawMerchantName.trim().toUpperCase();

  for (final entry in _merchantCategoryEntries.entries) {
    if (normalized.contains(entry.key)) {
      return entry.value;
    }
  }

  return miscellaneousCategory;
}
