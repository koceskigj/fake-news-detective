import 'dart:math';
import '../data/sample_cases.dart';
import '../models/case_item.dart';
import '../models/user_progress.dart';
import 'case_repository.dart';

class SampleCaseRepository implements CaseRepository {
  @override
  Future<List<CaseItem>> loadInitialCases() async {
    // In future, could be reading from local JSON, sqlite, etc.
    return List.of(sampleCases);
  }

  @override
  Future<CaseItem?> generateCase({
    required UserProgress progress,
    required int targetDifficulty,
  }) async {
    // For the sample repo, we don't truly "generate".
    // Return null so the app relies on the initial pool.
    return null;
  }

  /// Optional helper: shuffle in one place
  List<CaseItem> shuffledPool() {
    final list = List.of(sampleCases);
    list.shuffle(Random());
    return list;
  }
}
