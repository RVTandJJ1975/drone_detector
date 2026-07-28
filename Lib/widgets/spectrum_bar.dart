 
import 'package:flutter/material.dart';

class SpectrumBar extends StatelessWidget {
  final List<double> spectrum;

  const SpectrumBar({super.key, required this.spectrum});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(spectrum.length, (i) {
          final v = spectrum[i].clamp(0.0, 1.0);
          final color = Color.lerp(
            const Color(0xFF00E5FF),
            const Color(0xFFFF3D00),
            v,
          )!;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 60),
                height: 8 + v * 70,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
