// UI 语言上下文：通过 InheritedWidget 向子树传递当前语言与切换回调。
import 'package:flutter/material.dart';

import 'app_strings.dart';

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.strings,
    required this.onLanguageChanged,
    required super.child,
  });

  final AppStrings strings;
  final ValueChanged<AppUiLanguage> onLanguageChanged;

  static AppStrings of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found in context');
    return scope!.strings;
  }

  static void changeLanguage(BuildContext context, AppUiLanguage language) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found in context');
    scope!.onLanguageChanged(language);
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return oldWidget.strings.language != strings.language;
  }
}
