import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/case_item.dart';
import '../models/user_progress.dart';
import 'case_repository.dart';

class AiCaseRepository implements CaseRepository {
  final String functionUrl;
  final Random _rng = Random();

  AiCaseRepository({required this.functionUrl});

  static const List<String> _categories = [
    'health',
    'technology',
    'school',
    'weather',
    'sports',
    'science',
    'travel',
    'community',
  ];

  @override
  Future<List<CaseItem>> loadInitialCases() async {
    return <CaseItem>[];
  }

  @override
  Future<CaseItem?> generateCase({
    required UserProgress progress,
    required int targetDifficulty,
  }) async {
    final difficulty = targetDifficulty.clamp(1, 3);
    final category = _categories[_rng.nextInt(_categories.length)];

    final uri = Uri.parse(functionUrl).replace(queryParameters: {
      'difficulty': '$difficulty',
      'category': category,
      'r': '${_rng.nextInt(1 << 30)}', // reduce caching
    });

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 7));
      if (resp.statusCode != 200) return null;

      final data = jsonDecode(resp.body);
      if (data is! Map<String, dynamic>) return null;

      int toInt(dynamic v, int fallback) {
        if (v is int) return v;
        if (v is num) return v.toInt();
        return fallback;
      }

      final tagsRaw = (data['tags'] as List?) ?? const [];
      final tags = tagsRaw.map((e) => e.toString()).toList();

      final title = (data['title'] as String?)?.trim() ?? '';
      final snippet = (data['snippet'] as String?)?.trim() ?? '';
      final explanation = (data['explanation'] as String?)?.trim() ?? '';

      if (title.isEmpty || snippet.isEmpty || explanation.isEmpty) return null;

      return CaseItem(
        id: (data['id'] as String?) ??
            'ai_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        snippet: snippet,
        sourceName: (data['sourceName'] as String?) ?? 'AI Generator',
        isFake: (data['isFake'] as bool?) ?? false,
        explanation: explanation,
        tags: tags,
        difficulty: toInt(data['difficulty'], difficulty),
        domainHint: data['domainHint'] == null ? null : data['domainHint'].toString(),
      );
    } catch (_) {
      // timeout / network error -> let hybrid fall back to generator
      return null;
    }
  }
}
