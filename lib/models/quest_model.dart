class Quest {
  final String title;
  final String imagePath;
  final double latitude;
  final double longitude;
  final double progress;
  final QuestStatus status;
  final String description;

  Quest({
    required this.title,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    this.progress = 0.0,
    this.status = QuestStatus.active,
    this.description = '',
  });
}

enum QuestStatus { active, completed, upcoming }

class QuestMarker {
  final double latitude;
  final double longitude;
  final String title;
  final bool isCompleted;

  const QuestMarker({
    required this.latitude,
    required this.longitude,
    required this.title,
    this.isCompleted = false,
  });
}
