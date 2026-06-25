import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/enums.dart';

// ── AI 服務的請求 / 回應型別（介面預留；接 AI 時再細化）──

/// 生成課表的輸入。
class AiPlanRequest {
  const AiPlanRequest({
    required this.goal,
    required this.experience,
    required this.daysPerWeek,
    this.minutesPerSession,
    this.heightCm,
    this.age,
    this.weightKg,
    this.equipment = const [],
  });

  final TrainingGoal goal;
  final TrainingExperience experience;
  final int daysPerWeek;
  final int? minutesPerSession;
  final double? heightCm;
  final int? age;
  final double? weightKg;

  /// 第二圈：限定 AI 只能用清單內器材排課。
  final List<String> equipment;
}

/// AI 生成的單一動作。
class AiPlannedExercise {
  const AiPlannedExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.weightKg,
  });

  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final double? weightKg;
}

/// AI 生成課表的一天（推日 / 拉日 / 休息日…）。
class AiPlanDay {
  const AiPlanDay({
    required this.name,
    this.subtitle,
    this.isRest = false,
    this.exercises = const [],
  });

  final String name;
  final String? subtitle;
  final bool isRest;
  final List<AiPlannedExercise> exercises;
}

/// 讀 InBody 照片抽出的數值。
class AiBodyReading {
  const AiBodyReading({this.weightKg, this.bodyFatPct, this.muscleMassKg});

  final double? weightKg;
  final double? bodyFatPct;
  final double? muscleMassKg;
}

/// 週期回顧結果：說明 + 調整後課表。
class AiCycleReview {
  const AiCycleReview({required this.summary, required this.adjustedPlan});

  final String summary;
  final List<AiPlanDay> adjustedPlan;
}

/// AI 呼叫層抽象。
///
/// 今天底下接 Gemini，未來換 Claude / 加成本控制 / 加防呆只改實作，不動其他程式碼。
/// 所有輸出一律走「AI 預填 → 使用者確認 → 存檔」，呼叫端不可直接信任結果。
abstract interface class AiService {
  /// 生成課表（文字生成）。
  Future<List<AiPlanDay>> generateWorkoutPlan(AiPlanRequest request);

  /// 週期回顧：分析訓練記錄與體組成變化，回傳調整建議。
  /// TODO(step 8): 接 AI 時帶入週訓練記錄 + 體組成變化。
  Future<AiCycleReview> reviewCycle();

  /// 讀 InBody 照片抽數值（Vision）。
  Future<AiBodyReading> readInBodyPhoto(Uint8List image);

  /// 讀健身房照片辨識器材（Vision），回傳器材名稱清單。
  Future<List<String>> readEquipmentPhoto(Uint8List image);
}

/// 尚未接上 AI 的佔位實作。所有方法丟 UnimplementedError。
///
/// TODO(step 5+): 改用 GeminiAiService（含 JSON parse、防呆、隱私付費層）。
class StubAiService implements AiService {
  const StubAiService();

  Never _todo(String feature) => throw UnimplementedError(
        'AiService.$feature 尚未實作（step 5+ 接 Gemini）',
      );

  @override
  Future<List<AiPlanDay>> generateWorkoutPlan(AiPlanRequest request) async =>
      _todo('generateWorkoutPlan');

  @override
  Future<AiCycleReview> reviewCycle() async => _todo('reviewCycle');

  @override
  Future<AiBodyReading> readInBodyPhoto(Uint8List image) async =>
      _todo('readInBodyPhoto');

  @override
  Future<List<String>> readEquipmentPhoto(Uint8List image) async =>
      _todo('readEquipmentPhoto');
}

/// 預設 Stub；接 AI 後改為注入 GeminiAiService。
final aiServiceProvider = Provider<AiService>((ref) => const StubAiService());
