import '../models/case_item.dart';
import '../models/user_progress.dart';

abstract class CaseRepository {
  /// Returns the initial pool of cases available on this device/session.
  Future<List<CaseItem>> loadInitialCases();

  /// Optionally: future repositories can fetch/generate a single new case.
  Future<CaseItem?> generateCase({
    required UserProgress progress,
    required int targetDifficulty,
  });
}
