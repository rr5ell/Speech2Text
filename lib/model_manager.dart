// 模型管理：SenseVoice 的下载、解压、校验与本地路径。
import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'app_strings.dart';

class SherpaModelManager {
  static const _senseVoiceDir =
      'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17';
  static const _senseVoiceArchive = '$_senseVoiceDir.tar.bz2';
  static const _senseVoiceUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/$_senseVoiceArchive';
  static const _senseVoiceSizeMB = 155;

  static const _vadFile = 'silero_vad.onnx';
  static const _vadUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/$_vadFile';

  String? _modelsDirPath;
  AppStrings _strings = AppStrings(AppUiLanguage.zh);

  String modelDisplayName(String langCode) {
    return _strings.modelDisplayName(langCode);
  }

  void setStrings(AppStrings strings) => _strings = strings;

  int totalSizeMB(String langCode) => _senseVoiceSizeMB + 2;

  Future<String> _getModelsDir() async {
    if (_modelsDirPath != null) return _modelsDirPath!;
    final appDir = await getApplicationDocumentsDirectory();
    _modelsDirPath = '${appDir.path}/sherpa_models';
    await Directory(_modelsDirPath!).create(recursive: true);
    return _modelsDirPath!;
  }

  Future<bool> isReadyFor(String langCode) async {
    if (!await isVadDownloaded()) return false;
    return await isSenseVoiceDownloaded();
  }

  Future<bool> isSenseVoiceDownloaded() async {
    final dir = await _getModelsDir();
    final modelPath = '$dir/$_senseVoiceDir/model.int8.onnx';
    final tokensPath = '$dir/$_senseVoiceDir/tokens.txt';
    return File(modelPath).existsSync() && File(tokensPath).existsSync();
  }

  Future<bool> isVadDownloaded() async {
    final dir = await _getModelsDir();
    return File('$dir/$_vadFile').existsSync();
  }

  Future<String> getSenseVoiceModelPath() async {
    final dir = await _getModelsDir();
    return '$dir/$_senseVoiceDir/model.int8.onnx';
  }

  Future<String> getSenseVoiceTokensPath() async {
    final dir = await _getModelsDir();
    return '$dir/$_senseVoiceDir/tokens.txt';
  }

  Future<String> getVadModelPath() async {
    final dir = await _getModelsDir();
    return '$dir/$_vadFile';
  }

  Future<void> downloadFor(
    String langCode,
    void Function(double progress, String statusText) onProgress, {
    AppStrings? strings,
  }) async {
    if (strings != null) _strings = strings;

    if (!await isVadDownloaded()) {
      await _downloadVad(onProgress);
    }

    if (!await isSenseVoiceDownloaded()) {
      await _downloadSenseVoice(onProgress);
    }

    onProgress(1.0, _strings.allModelsReady);
  }

  Future<void> _downloadVad(
    void Function(double progress, String statusText) onProgress,
  ) async {
    final dir = await _getModelsDir();
    final targetPath = '$dir/$_vadFile';

    onProgress(0.0, _strings.downloadVadModel);
    await _downloadFile(
      url: _vadUrl,
      savePath: targetPath,
      onProgress: (received, total) {
        if (total > 0) {
          final pct = (received / total * 0.05).clamp(0.0, 0.05);
          final mb = (received / 1024 / 1024).toStringAsFixed(1);
          onProgress(pct, _strings.downloadVadProgress(mb));
        }
      },
    );
  }

  Future<void> _downloadSenseVoice(
    void Function(double progress, String statusText) onProgress,
  ) async {
    final dir = await _getModelsDir();
    final archivePath = '$dir/$_senseVoiceArchive';
    final archiveFile = File(archivePath);

    if (await archiveFile.exists()) await archiveFile.delete();

    onProgress(0.05, _strings.connectingServer);
    await _downloadFile(
      url: _senseVoiceUrl,
      savePath: archivePath,
      onProgress: (received, total) {
        if (total > 0) {
          final pct = 0.05 + (received / total * 0.70);
          final mb = (received / 1024 / 1024).toStringAsFixed(1);
          final totalMb = (total / 1024 / 1024).toStringAsFixed(1);
          onProgress(pct, _strings.downloadSenseVoiceProgress(mb, totalMb));
        } else {
          final mb = (received / 1024 / 1024).toStringAsFixed(1);
          onProgress(0.10, _strings.downloadSenseVoiceIndeterminate(mb));
        }
      },
    );

    onProgress(0.78, _strings.extractingSenseVoice);
    await _extractArchive(archiveFile, dir);

    onProgress(0.95, _strings.cleaning);
    if (await archiveFile.exists()) await archiveFile.delete();

    final modelPath = '$dir/$_senseVoiceDir/model.int8.onnx';
    final tokensPath = '$dir/$_senseVoiceDir/tokens.txt';
    if (!File(modelPath).existsSync() || !File(tokensPath).existsSync()) {
      final modelDir = Directory('$dir/$_senseVoiceDir');
      if (await modelDir.exists()) await modelDir.delete(recursive: true);
      throw Exception(_strings.senseVoiceIncomplete);
    }

    onProgress(0.98, _strings.senseVoiceReady);
  }

  Future<void> _extractArchive(File archiveFile, String dir) async {
    try {
      final bytes = await archiveFile.readAsBytes();
      await compute(_extractTarBz2InIsolate, [bytes, dir]);
    } catch (e) {
      if (await archiveFile.exists()) await archiveFile.delete();
      throw Exception(_strings.extractFailed(e));
    }
  }

  Future<void> _downloadFile({
    required String url,
    required String savePath,
    required void Function(int received, int total) onProgress,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 60),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'User-Agent': 'SpeechToText/2.0 (Android)',
          'Accept': '*/*',
        },
        followRedirects: true,
        maxRedirects: 10,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        return HttpClient()
          ..connectionTimeout = const Duration(seconds: 30)
          ..idleTimeout = const Duration(seconds: 120)
          ..autoUncompress = false;
      };
    }

    try {
      await dio.download(
        url,
        savePath,
        deleteOnError: true,
        onReceiveProgress: onProgress,
      );
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
          throw Exception(_strings.connectionTimeout);
        case DioExceptionType.receiveTimeout:
          throw Exception(_strings.downloadTimeout);
        case DioExceptionType.connectionError:
          throw Exception(_strings.cannotConnectServer(e.message ?? ''));
        default:
          throw Exception(e.message ?? _strings.networkRequestFailed);
      }
    } finally {
      dio.close(force: true);
    }
  }

  Future<void> deleteAll() async {
    final dir = await _getModelsDir();
    final d = Directory(dir);
    if (await d.exists()) await d.delete(recursive: true);
    _modelsDirPath = null;
  }
}

void _extractTarBz2InIsolate(List<dynamic> args) {
  final bytes = args[0] as Uint8List;
  final targetDir = args[1] as String;

  final decompressed = BZip2Decoder().decodeBytes(bytes);
  final archive = TarDecoder().decodeBytes(decompressed);

  for (final file in archive) {
    final filePath = '$targetDir/${file.name}';
    if (file.isFile) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(file.content as List<int>);
    } else {
      Directory(filePath).createSync(recursive: true);
    }
  }
}
