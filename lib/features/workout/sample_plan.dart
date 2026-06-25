import '../../core/data/workout_repository.dart';

/// 開發階段的假課表（PLAN step 3：先用假資料把訓練流程跑通，之後由 AI 取代）。
const String sampleWorkoutTitle = '推日 · 胸肩三頭';

const List<PlannedSnapshot> sampleWorkoutPlan = [
  PlannedSnapshot(name: '槓鈴臥推', sets: 2, reps: 5, weightKg: 60, restSeconds: 90),
  PlannedSnapshot(name: '啞鈴肩推', sets: 2, reps: 8, weightKg: 22, restSeconds: 75),
  PlannedSnapshot(name: '三頭下壓', sets: 2, reps: 12, weightKg: 25, restSeconds: 60),
];
