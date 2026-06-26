// 历史记录管理：识别结果的本地 JSON 读写，最多保留 100 条。
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'history_record.dart';

class HistoryManager {
  static const _maxRecords = 100;
  List<HistoryRecord>? _cache;
  String? _filePath;

  Future<String> _getFilePath() async {
    if (_filePath != null) return _filePath!;
    final dir = await getApplicationDocumentsDirectory();
    _filePath = '${dir.path}/history.json';
    return _filePath!;
  }

  Future<List<HistoryRecord>> loadAll() async {
    if (_cache != null) return _cache!;
    final file = File(await _getFilePath());
    if (!await file.exists()) {
      _cache = [];
      return _cache!;
    }

    try {
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      _cache = list
          .map((e) => HistoryRecord.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return _cache!;
    } catch (_) {
      _cache = [];
      return _cache!;
    }
  }

  Future<void> add(HistoryRecord record) async {
    final records = await loadAll();
    records.insert(0, record);
    if (records.length > _maxRecords) {
      records.removeRange(_maxRecords, records.length);
    }
    await _save(records);
  }

  Future<void> delete(String id) async {
    final records = await loadAll();
    records.removeWhere((r) => r.id == id);
    await _save(records);
  }

  Future<void> clearAll() async {
    _cache = [];
    final file = File(await _getFilePath());
    if (await file.exists()) await file.delete();
  }

  Future<void> _save(List<HistoryRecord> records) async {
    _cache = List.from(records);
    final file = File(await _getFilePath());
    await file.writeAsString(
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }
}
