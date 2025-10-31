import 'package:flutter/material.dart';

class ProgressTracker extends StatefulWidget {
  /// Pass one bool per field you want to count toward completion.
  /// Example: [nameOk, emailOk, passwordOk, dobOk, avatarOk]
  final List<bool> steps;

  /// Optional: control animation speed of the bar and message.
  final Duration progressAnim;
  final Duration messageAnim;

  const ProgressTracker({
    super.key,
    required this.steps,
    this.progressAnim = const Duration(milliseconds: 400),
    this.messageAnim = const Duration(milliseconds: 250),
  });

  @override
  State<ProgressTracker> createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker> {
  static const _milestones = [0.25, 0.50, 0.75, 1.00];
  static const _messages = [
    "Great start!",
    "Halfway there!",
    "Almost done!",
    "Ready for adventure!",
  ];

  int _lastMilestoneIndexShown = -1;

  double get _progress {
    if (widget.steps.isEmpty) return 0;
    final done = widget.steps.where((e) => e).length;
    return done / widget.steps.length;
  }

  String? get _currentMilestoneMessage {
    for (int i = _milestones.length - 1; i >= 0; i--) {
      if (_progress >= _milestones[i]) {
        return _messages[i];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final message = _currentMilestoneMessage;

    // Update the last milestone index so we don't “jump backward”
    final idx = message == null ? -1 : _messages.indexOf(message);
    if (idx > _lastMilestoneIndexShown) {
      _lastMilestoneIndexShown = idx;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _progress.clamp(0, 1)),
          duration: widget.progressAnim,
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            final percent = (value * 100).round();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: Colors.deepPurple.withOpacity(0.15),
                    color: Color.lerp(Colors.red, Colors.green, value),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$percent%",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.deepPurple[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),

        // Milestone message (appears only when hitting 25/50/75/100)
        AnimatedSwitcher(
          duration: widget.messageAnim,
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: _lastMilestoneIndexShown >= 0
              ? Text(
                  _messages[_lastMilestoneIndexShown],
                  key: ValueKey(_lastMilestoneIndexShown),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
