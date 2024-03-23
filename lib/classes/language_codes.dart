class LanguageCodes {
  final Map<String, String> namesToCodes = {
    'russian': 'ru',
    'english': 'en',
    'spanish': 'es',
    'french': 'fr',
    'german': 'de',
    'italian': 'it',
    'japanese': 'jp',
  };

  String? getCode(String name) {
    return namesToCodes[name];
  }
}