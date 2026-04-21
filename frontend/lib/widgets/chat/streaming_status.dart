import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/agent_phase.dart';
import '../../theme/app_theme.dart';

class StreamingStatusIndicator extends StatelessWidget {
  const StreamingStatusIndicator({super.key, required this.phase});

  final AgentPhase phase;

  String get _label => switch (phase) {
        AgentPhaseThinking() => 'Thinking…',
        AgentPhaseToolRunning(tool: 'search_items_tool') => 'Searching your library…',
        AgentPhaseToolRunning(tool: 'list_items_tool') => 'Browsing your items…',
        AgentPhaseToolRunning(:final tool) => 'Running $tool…',
        _ => '',
      };

  IconData get _icon => switch (phase) {
        AgentPhaseThinking() => Icons.psychology_rounded,
        AgentPhaseToolRunning(tool: 'search_items_tool') => Icons.search_rounded,
        AgentPhaseToolRunning(tool: 'list_items_tool') => Icons.list_rounded,
        AgentPhaseToolRunning() => Icons.build_circle_outlined,
        _ => Icons.auto_awesome_rounded,
      };

  @override
  Widget build(BuildContext context) {
    if (phase is AgentPhaseTyping || phase is AgentPhaseIdle) {
      return _DotsIndicator();
    }

    final label = _label;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 6),
        _DotsIndicator(),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(
                delay: Duration(milliseconds: i * 150),
                duration: const Duration(milliseconds: 400),
              )
              .then()
              .fadeOut(duration: const Duration(milliseconds: 400)),
        );
      }),
    );
  }
}
