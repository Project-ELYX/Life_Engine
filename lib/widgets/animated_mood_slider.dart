import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedMoodSlider extends StatefulWidget {
  final String mood;
  final double value;
  final Color color;

  const AnimatedMoodSlider({
    super.key,
    required this.mood,
    required this.value,
    required this.color,
  });

  @override
  State<AnimatedMoodSlider> createState() => _AnimatedMoodSliderState();
}

class _AnimatedMoodSliderState extends State<AnimatedMoodSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (500 - widget.value * 3).clamp(100, 500).toInt()),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AnimatedMoodSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.duration = Duration(milliseconds: (500 - widget.value * 3).clamp(100, 500).toInt());
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double wave = sin(_controller.value * 2 * pi);
        return ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            colors: [
              widget.color.withAlpha(255),
              widget.color.withAlpha((120 + wave * 60).toInt().clamp(0, 255)),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect),
          blendMode: BlendMode.srcATop,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.color,
              inactiveTrackColor: widget.color.withAlpha(77),
              thumbColor: widget.color,
              overlayColor: widget.color.withAlpha(51),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: widget.value,
              onChanged: null,
              min: 0,
              max: 100,
              divisions: 10,
              label: widget.value.round().toString(),
            ),
          ),
        );
      },
    );
  }
}
