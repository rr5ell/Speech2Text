// 支持语言枚举：各识别语言的显示名称、国旗 emoji 与语言代码。
enum SupportedLanguage {
  chinese(name: '中文', flag: '🇨🇳', code: 'zh'),
  english(name: 'English', flag: '🇺🇸', code: 'en'),
  korean(name: '한국어', flag: '🇰🇷', code: 'ko'),
  japanese(name: '日本語', flag: '🇯🇵', code: 'ja');

  const SupportedLanguage({
    required this.name,
    required this.flag,
    required this.code,
  });

  final String name;
  final String flag;
  final String code;
}
