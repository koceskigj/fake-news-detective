import '../models/case_item.dart';
import '../models/user_progress.dart';
import 'case_repository.dart';
import 'generated_case_repository.dart';
import 'sample_case_repository.dart';

class HybridCaseRepository implements CaseRepository {
  final SampleCaseRepository _sample = SampleCaseRepository();
  final GeneratedCaseRepository _gen = GeneratedCaseRepository();

  @override
  Future<List<CaseItem>> loadInitialCases() async {
    return _sample.loadInitialCases();
  }

  @override
  Future<CaseItem?> generateCase({
    required UserProgress progress,
    required int targetDifficulty,
  }) {
    return _gen.generateCase(progress: progress, targetDifficulty: targetDifficulty);
  }
}
