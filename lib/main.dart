// 应用入口：初始化网络超时、Material 主题与 UI 语言状态，挂载主界面。
import 'dart:io';

import 'package:flutter/material.dart';

import 'app_locale_scope.dart';
import 'app_strings.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _AppHttpOverrides();
  runApp(const SpeechToTextApp());
}

class _AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 20)
      ..idleTimeout = const Duration(seconds: 60);
  }
}

class SpeechToTextApp extends StatefulWidget {
  const SpeechToTextApp({super.key});

  @override
  State<SpeechToTextApp> createState() => _SpeechToTextAppState();
}

class _SpeechToTextAppState extends State<SpeechToTextApp> {
  AppUiLanguage _uiLanguage = AppUiLanguage.zh;

  void _setUiLanguage(AppUiLanguage language) {
    setState(() => _uiLanguage = language);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(_uiLanguage);

    return AppLocaleScope(
      strings: strings,
      onLanguageChanged: _setUiLanguage,
      child: MaterialApp(
        title: strings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A73E8),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A73E8),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
