
class DetectionEvent {
  final DateTime timestamp;
  final double confidence; // 0.0 – 1.0
  final String level; // 'low', 'medium', 'high'
  final double peakFrequencyHz;
  final double relativeLoudness;

  DetectionEvent({
    required this.timestamp,
    required this.confidence,
    required this.level,
    required this.peakFrequencyHz,
    required this.relativeLoudness,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'confidence': confidence,
        'level': level,
        'peakFrequencyHz': peakFrequencyHz,
        'relativeLoudness': relativeLoudness,
      };

  factory DetectionEvent.fromJson(Map<String, dynamic> json) => DetectionEvent(
        timestamp: DateTime.parse(json['timestamp']),
        confidence: (json['confidence'] as num).toDouble(),
        level: json['level'],
        peakFrequencyHz: (json['peakFrequencyHz'] as num).toDouble(),
        relativeLoudness: (json['relativeLoudness'] as num).toDouble(),
      );
}
