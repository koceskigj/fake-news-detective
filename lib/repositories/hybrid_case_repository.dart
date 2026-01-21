import '../models/case_item.dart';
import '../models/user_progress.dart';
import 'case_repository.dart';
import 'firestore_case_repository.dart';
import 'generated_case_repository.dart';
import 'sample_case_repository.dart';

class HybridCaseRepository implements CaseRepository {
  final FirestoreCaseRepository _fire = FirestoreCaseRepository();
  final SampleCaseRepository _sample = SampleCaseRepository();
  final GeneratedCaseRepository _gen = GeneratedCaseRepository();

  @override
  Future<List<CaseItem>> loadInitialCases() async {
    // Try Firestore first
    try {
      final remote = await _fire.loadInitialCases();
      if (remote.isNotEmpty) return remote;
    } catch (_) {
      // ignore and fall back
    }

    // Fall back to local built-in dataset
    return _sample.loadInitialCases();
  }

  @override
  Future<CaseItem?> generateCase({
    required UserProgress progress,
    required int targetDifficulty,
  }) async {
    return _gen.generateCase(progress: progress, targetDifficulty: targetDifficulty);
  }
}
