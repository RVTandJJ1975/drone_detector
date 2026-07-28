
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/detection_event.dart';
import '../services/audio_detector_service.dart';
import '../services/settings_service.dart';
import '../widgets/spectrum_bar.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioDetectorService _detector = AudioDetectorService();
  final List<DetectionEvent> _events = [];

  DetectorStatus _status = DetectorStatus.stopped;
  List<double> _spectrum = List.filled(64, 0.0);
  double _confidence = 0.0;
  double _rms = 0.0;

  StreamSubscription? _statusSub;
  StreamSubscription? _spectrumSub;
  StreamSubscription? _detectionSub;

  @override
  void initState() {
    super.initState();
    _statusSub = _detector.onStatus.listen((s) {
      if (mounted) {
        setState(() {
          _status = s;
          _confidence = s.confidence;
          _rms = s.rms;
        });
      }
    });
    _spectrumSub = _detector.onSpectrum.listen((spec) {
      if (mounted) setState(() => _spectrum = spec);
    });
    _detectionSub = _detector.onDetection.listen(_onDetection);
  }

  void _onDetection(DetectionEvent event) {
    setState(() {
      _events.insert(0, event);
      if (_events.length > 50) _events.removeLast();
    });

    if (SettingsService.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _toggleListening() async {
    if (_detector.isListening) {
      await _detector.stop();
    } else {
      await _detector.start();
    }
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _spectrumSub?.cancel();
    _detectionSub?.cancel();
    _detector.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (_status.state == DetectorState.permissionDenied ||
        _status.state == DetectorState.error) {
      return Colors.redAccent;
    }
    if (!_detector.isListening) return Colors.grey;
    if (_confidence > 0.7) return const Color(0xFFFF3D00);
    if (_confidence > 0.45) return const Color(0xFFFFAB00);
    return const Color(0xFF00E676);
  }

  String get _statusText {
    switch (_status.state) {
      case DetectorState.permissionDenied:
        return 'MICROPHONE PERMISSION REQUIRED';
      case DetectorState.error:
        return 'ERROR – CHECK MIC';
      case DetectorState.stopped:
        return 'READY';
      case DetectorState.listening:
        if (_confidence > 0.7) return 'DRONE LIKELY';
        if (_confidence > 0.45) return 'POSSIBLE DRONE';
        return 'LISTENING';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drone Detector',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _statusColor.withOpacity(0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _statusColor.withOpacity(0.25),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Confidence', style: TextStyle(color: Colors.white70)),
                      const Spacer(),
                      Text(
                        '${(_confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _confidence,
                      minHeight: 10,
                      backgroundColor: Colors.white12,
                      color: _statusColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Level: ${(_rms * 100).toStringAsFixed(1)}%  •  Mic RMS',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SpectrumBar(spectrum: _spectrum),
            ),
            const SizedBox(height: 8),
            const Text(
              'Frequency spectrum (approx 0–8 kHz)',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _detector.isListening
                      ? const Color(0xFFFF3D00)
                      : const Color(0xFF00E5FF),
                  boxShadow: [
                    BoxShadow(
                      color: (_detector.isListening
                              ? const Color(0xFFFF3D00)
                              : const Color(0xFF00E5FF))
                          .withOpacity(0.45),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _detector.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 48,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _detector.isListening ? 'Tap to stop' : 'Tap to start listening',
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Detection Log',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
                  ),
                  const Spacer(),
                  if (_events.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() => _events.clear()),
                      child: const Text('Clear', style: TextStyle(fontSize: 13)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _events.isEmpty
                  ? const Center(
                      child: Text(
                        'No detections yet',
                        style: TextStyle(color: Colors.white30),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final e = _events[index];
                        final time = DateFormat('HH:mm:ss').format(e.timestamp);
                        Color levelColor;
                        switch (e.level) {
                          case 'high':
                            levelColor = const Color(0xFFFF3D00);
                            break;
                          case 'medium':
                            levelColor = const Color(0xFFFFAB00);
                            break;
                          default:
                            levelColor = const Color(0xFF00E676);
                        }
                        return Card(
                          color: const Color(0xFF1A1A1A),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 8,
                              backgroundColor: levelColor,
                            ),
                            title: Text(
                              '${e.level.toUpperCase()}  •  ${(e.confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '$time  •  ~${e.peakFrequencyHz.toStringAsFixed(0)} Hz',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
