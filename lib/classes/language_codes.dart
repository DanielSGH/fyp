class LanguageCodes {
  static final Map<String, String> namesToCodes = {
    'russian': 'ru',
    'english': 'gb',
    'spanish': 'es',
    'french': 'fr',
    'german': 'de',
    'italian': 'it',
    'japanese': 'jp',
  };

  static String? getCode(String name) {
    return namesToCodes[name];
  }

  static String getFullName(String code) {
    return namesToCodes.keys.firstWhere((key) => namesToCodes[key] == code);
  }
}