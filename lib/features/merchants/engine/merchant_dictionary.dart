const miscellaneousCategory = 'Miscellaneous';

const _merchantCategoryEntries = <String, String>{
  'ZOMATO': 'Food',
  'SWIGGY': 'Food',
  'INDIAN OIL': 'Fuel',
  'BPCL': 'Fuel',
  'HPCL': 'Fuel',
  'IOCL': 'Fuel',
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
