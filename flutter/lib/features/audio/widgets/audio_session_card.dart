import 'package:flutter/material.dart';
import 'package:pc_remote_control/features/audio/models/audio_session.dart';
import 'package:pc_remote_control/features/audio/theme/theme_context.dart';
import 'package:pc_remote_control/features/audio/widgets/audio_panel_card.dart';

class AudioSessionCard extends StatelessWidget {
  final AudioSession session;
  final String activeLabel;
  final String inactiveLabel;
  final String expiredLabel;
  final String mutedLabel;
  final String unmutedLabel;

  const AudioSessionCard({
    required this.session,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.expiredLabel,
    required this.mutedLabel,
    required this.unmutedLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateColor = switch (session.state) {
      AudioSessionState.active => context.audioTheme.signal,
      AudioSessionState.inactive => context.audioTheme.warning,
      AudioSessionState.expired => theme.colorScheme.error,
    };
    final stateLabel = switch (session.state) {
      AudioSessionState.active => activeLabel,
      AudioSessionState.inactive => inactiveLabel,
      AudioSessionState.expired => expiredLabel,
    };
    final volume = session.volumeLevel.clamp(0, 100).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        final volumeSectionWidth = isCompact
            ? double.infinity
            : constraints.maxWidth * 0.42;
        final volumeLabelColor = session.muted
            ? theme.colorScheme.error
            : context.audioTheme.signal;
        final leading = Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.audioTheme.background.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.audioTheme.border.withValues(alpha: 0.8),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            session.muted
                ? Icons.volume_off_rounded
                : Icons.multitrack_audio_rounded,
            color: context.audioTheme.mutedText,
            size: 19,
          ),
        );
        final volumePanel = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${volume.toStringAsFixed(0)}%',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Volume atual',
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.audioTheme.mutedText,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: SizedBox(
                height: 7,
                child: LinearProgressIndicator(
                  value: volume / 100,
                  color: stateColor,
                  backgroundColor: context.audioTheme.surface,
                ),
              ),
            ),
          ],
        );
        final header = isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leading,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: volumeSectionWidth,
                    child: volumePanel,
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: volumeSectionWidth,
                    child: volumePanel,
                  ),
                ],
              );

        return AudioPanelCard(
          padding: EdgeInsets.all(isCompact ? 16 : 18),
          backgroundColor: context.audioTheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SessionBadge(label: stateLabel, foreground: stateColor),
                  _SessionBadge(
                    label: session.muted ? mutedLabel : unmutedLabel,
                    foreground: volumeLabelColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SessionBadge extends StatelessWidget {
  final String label;
  final Color foreground;

  const _SessionBadge({
    required this.label,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
