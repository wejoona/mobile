/// Maps iOS machine identifiers to marketing names.
/// Source: https://gist.github.com/adamawolf/3048717
String iosModelName(String machine) {
  const map = {
    // iPhone
    'iPhone10,1': 'iPhone 8', 'iPhone10,4': 'iPhone 8',
    'iPhone10,2': 'iPhone 8 Plus', 'iPhone10,5': 'iPhone 8 Plus',
    'iPhone10,3': 'iPhone X', 'iPhone10,6': 'iPhone X',
    'iPhone11,2': 'iPhone XS',
    'iPhone11,4': 'iPhone XS Max', 'iPhone11,6': 'iPhone XS Max',
    'iPhone11,8': 'iPhone XR',
    'iPhone12,1': 'iPhone 11',
    'iPhone12,3': 'iPhone 11 Pro',
    'iPhone12,5': 'iPhone 11 Pro Max',
    'iPhone12,8': 'iPhone SE (2nd)',
    'iPhone13,1': 'iPhone 12 mini',
    'iPhone13,2': 'iPhone 12',
    'iPhone13,3': 'iPhone 12 Pro',
    'iPhone13,4': 'iPhone 12 Pro Max',
    'iPhone14,4': 'iPhone 13 mini',
    'iPhone14,5': 'iPhone 13',
    'iPhone14,2': 'iPhone 13 Pro',
    'iPhone14,3': 'iPhone 13 Pro Max',
    'iPhone14,6': 'iPhone SE (3rd)',
    'iPhone14,7': 'iPhone 14',
    'iPhone14,8': 'iPhone 14 Plus',
    'iPhone15,2': 'iPhone 14 Pro',
    'iPhone15,3': 'iPhone 14 Pro Max',
    'iPhone15,4': 'iPhone 15',
    'iPhone15,5': 'iPhone 15 Plus',
    'iPhone16,1': 'iPhone 15 Pro',
    'iPhone16,2': 'iPhone 15 Pro Max',
    'iPhone16,3': 'iPhone 16',
    'iPhone16,4': 'iPhone 16 Plus',
    'iPhone17,1': 'iPhone 16 Pro',
    'iPhone17,2': 'iPhone 16 Pro Max',
    'iPhone17,3': 'iPhone 16e',
    // iPad
    'iPad13,18': 'iPad (10th)', 'iPad13,19': 'iPad (10th)',
    'iPad14,1': 'iPad mini (6th)', 'iPad14,2': 'iPad mini (6th)',
    'iPad14,3': 'iPad Pro 11" (4th)', 'iPad14,4': 'iPad Pro 11" (4th)',
    'iPad14,5': 'iPad Pro 12.9" (6th)', 'iPad14,6': 'iPad Pro 12.9" (6th)',
    'iPad14,8': 'iPad Air (M2)', 'iPad14,9': 'iPad Air (M2)',
    'iPad14,10': 'iPad Air 13" (M2)', 'iPad14,11': 'iPad Air 13" (M2)',
    'iPad16,1': 'iPad mini (A17)', 'iPad16,2': 'iPad mini (A17)',
    'iPad16,3': 'iPad Pro 11" (M4)', 'iPad16,4': 'iPad Pro 11" (M4)',
    'iPad16,5': 'iPad Pro 13" (M4)', 'iPad16,6': 'iPad Pro 13" (M4)',
  };

  return map[machine] ?? machine;
}

/// For Android, brand + model is usually good enough.
/// Capitalize brand if needed.
String androidModelName(String brand, String model) {
  final b = brand.isNotEmpty
      ? '${brand[0].toUpperCase()}${brand.substring(1)}'
      : '';
  if (model.toLowerCase().startsWith(brand.toLowerCase())) {
    return model; // e.g. "Samsung Galaxy S24"
  }
  return '$b $model'.trim();
}
