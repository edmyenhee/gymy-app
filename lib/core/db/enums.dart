/// 資料模型用的列舉。以 Drift `textEnum` 存成可讀字串（存 `.name`）。
library;

/// 性別。
enum Gender { male, female, other }

/// 訓練經驗。
enum TrainingExperience { beginner, intermediate, advanced }

/// 目標：增肌 / 減脂 / 維持。
enum TrainingGoal { gain, cut, maintain }

/// 體組成資料來源：手動 / InBody 匯入。
enum MetricSource { manual, inbody }

/// 一次訓練的狀態。
enum SessionStatus { inProgress, completed }

/// 訓練中單一動作的完成狀態。
enum ExerciseStatus { notStarted, inProgress, completed }
