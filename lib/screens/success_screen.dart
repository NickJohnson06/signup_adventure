import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';

class SuccessScreen extends StatefulWidget {
  final String userName;
  final String avatarEmoji;
  final List<String> badges;

  const SuccessScreen({
    super.key,
    required this.userName,
    required this.avatarEmoji,
    this.badges = const [],
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _badgeEmoji(String badge) {
    switch (badge) {
      case 'Strong Password Master':
        return '🏆';
      case 'The Early Bird Special':
        return '🌅';
      case 'Profile Completer':
        return '💫';
      default:
        return '🎖️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.deepPurple,
                Colors.purple,
                Colors.blue,
                Colors.green,
                Colors.orange,
              ],
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  Text(widget.avatarEmoji, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),

                  // Celebration Icon
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.celebration, color: Colors.white, size: 80),
                  ),
                  const SizedBox(height: 40),

                  // Personalized Welcome
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Welcome, ${widget.userName}! 🎉',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),

                  const SizedBox(height: 20),
                  const Text('Your adventure begins now!',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),

                  // Badges
                  if (widget.badges.isNotEmpty) ...[
                    Text(
                      'Achievements Unlocked',
                      style: TextStyle(
                        color: Colors.deepPurple[800],
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: widget.badges.map((b) {
                        return Chip(
                          avatar: Text(_badgeEmoji(b), style: const TextStyle(fontSize: 18)),
                          label: Text(b),
                          backgroundColor: Colors.deepPurple[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.deepPurple.shade200),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // More Celebration Button
                  ElevatedButton(
                    onPressed: () => _confettiController.play(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('More Celebration!',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
