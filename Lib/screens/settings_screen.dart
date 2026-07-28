
import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _sensitivity;
  late bool _vibration;
  late bool _sound;
  late int _consecutive;

  @override
  void initState() {
    super.initState();
    _sensitivity = SettingsService.sensitivity;
    _vibration = SettingsService.vibrationEnabled;
    _sound = SettingsService.soundAlertEnabled;
    _consecutive = SettingsService.consecutiveRequired;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Detection',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF1A1A1A),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Sensitivity'),
                      const Spacer(),
                      Text(
                        _sensitivity < 0.35
                            ? 'Strict'
                            : _sensitivity > 0.7
                                ? 'High'
                                : 'Balanced',
                        style: const TextStyle(color: Color(0xFF00E5FF)),
                      ),
                    ],
                  ),
                  Slider(
                    value: _sensitivity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: _sensitivity.toStringAsFixed(2),
                    onChanged: (v) {
                      setState(() => _sensitivity = v);
                      SettingsService.sensitivity = v;
                    },
                  ),
                  const Text(
                    'Higher = more detections (also more false alarms)',
                    style: TextStyle(fontSize: 12, color: Colors.white38),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Consecutive windows required'),
                      const Spacer(),
                      Text('$_consecutive',
                          style: const TextStyle(color: Color(0xFF00E5FF))),
                    ],
                  ),
                  Slider(
                    value: _consecutive.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: '$_consecutive',
                    onChanged: (v) {
                      setState(() => _consecutive = v.round());
                      SettingsService.consecutiveRequired = v.round();
                    },
                  ),
                  const Text(
                    'Higher value reduces false positives',
                    style: TextStyle(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Alerts',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF1A1A1A),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Vibration'),
                  value: _vibration,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (v) {
                    setState(() => _vibration = v);
                    SettingsService.vibrationEnabled = v;
                  },
                ),
                SwitchListTile(
                  title: const Text('Sound alert'),
                  subtitle: const Text('Coming in next version'),
                  value: _sound,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (v) {
                    setState(() => _sound = v);
                    SettingsService.soundAlertEnabled = v;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Notes',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Best results in quiet outdoor environments.\n'
            '• Phone microphones have limited range (typically tens of metres).\n'
            '• Fans, leaf blowers and some motors can trigger false positives.\n'
            '• This version uses a fast rule-based detector. A machine-learning model will be added later for higher accuracy.',
            style: TextStyle(color: Colors.white60, height: 1.5),
          ),
        ],
      ),
    );
  }
}
